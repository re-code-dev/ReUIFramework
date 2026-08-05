require "ReUI/components/ReUIWindow"
require "ReUI/components/ReUIButton"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUIInspector"
require "ReUI/designer/ReUIDesignNode"
require "ReUI/managers/ReUIWindowManager"
require "ReUI/core/ReUITheme"

-- In-game WYSIWYG layout editor: drag ReUIDesignNode placeholders from a
-- palette onto a canvas, move/resize/label them, then export a ready-to-run
-- Lua snippet (real ReUI.* constructor calls) to Zomboid/Lua/ReUI_Export.lua
-- via getFileWriter. Placed nodes are design-time stand-ins, not live
-- widgets — see ReUIDesignNode for why. Nodes dropped inside a VBox/HBox
-- node's bounds are exported nested inside it (container:add(...)) rather
-- than as flat parent:addChild(...) siblings.
--
-- Save/Load use a separate plain-data file (ReUI_Layout.txt, tab-delimited
-- one line per node) so a layout can be reopened for further editing — the
-- exported Lua is generated code, not something we parse back.
local DesignerWindow = ReUIWindow:derive("ReUIDesignerWindow")
ReUI.Designer = ReUI.Designer or {}
ReUI.Designer.instance = nil

local PALETTE_TYPES = {
    "VBox", "HBox", "Button", "Label", "Panel", "Checkbox", "Switch",
    "Slider", "TextBox", "ProgressBar", "Image", "NumberBox", "Dropdown"
}

local CONTAINER_TYPES = { VBox = true, HBox = true }

local function esc(text)
    return tostring(text or ""):gsub('"', '\\"')
end

-- Each template returns the *declaration* lines only (constructor +
-- initialise + instantiate); generateCode() appends the parent-attach line
-- (parent:addChild(v) or container:add(v, {...})) itself.
local TEMPLATES = {}

local function simpleOptionsTemplate(className, extraOption)
    return function(v, n)
        local optionsText = extraOption and string.format('%s = "%s"', extraOption, esc(n.label)) or ""
        return {
            string.format('local %s = ReUI.%s:new(%d, %d, %d, %d, { %s })',
                v, className, n.x, n.y, n.width, n.height, optionsText),
            v .. ":initialise()",
            v .. ":instantiate()"
        }
    end
end

TEMPLATES.VBox = simpleOptionsTemplate("VBox", nil)
TEMPLATES.HBox = simpleOptionsTemplate("HBox", nil)

TEMPLATES.Button = function(v, n)
    return {
        string.format('local %s = ReUI.Button:new(%d, %d, %d, %d, "%s", nil, nil)',
            v, n.x, n.y, n.width, n.height, esc(n.label)),
        v .. ":initialise()",
        v .. ":instantiate()"
    }
end

TEMPLATES.Label = function(v, n)
    return {
        string.format('local %s = ReUI.Label:new(%d, %d, %d, %d, "%s", {})',
            v, n.x, n.y, n.width, n.height, esc(n.label)),
        v .. ":initialise()",
        v .. ":instantiate()"
    }
end
TEMPLATES.Panel = simpleOptionsTemplate("Panel", nil)
TEMPLATES.Checkbox = function(v, n)
    return {
        string.format('local %s = ReUI.Checkbox:new(%d, %d, %d, %d, "%s", {})',
            v, n.x, n.y, n.width, n.height, esc(n.label)),
        v .. ":initialise()",
        v .. ":instantiate()"
    }
end
TEMPLATES.Switch = function(v, n)
    return {
        string.format('local %s = ReUI.Switch:new(%d, %d, %d, %d, "%s", {})',
            v, n.x, n.y, n.width, n.height, esc(n.label)),
        v .. ":initialise()",
        v .. ":instantiate()"
    }
end
TEMPLATES.TextBox = simpleOptionsTemplate("TextBox", "placeholder")
TEMPLATES.ProgressBar = simpleOptionsTemplate("ProgressBar", nil)
TEMPLATES.Image = simpleOptionsTemplate("Image", nil)
TEMPLATES.NumberBox = simpleOptionsTemplate("NumberBox", nil)
TEMPLATES.Dropdown = simpleOptionsTemplate("Dropdown", "placeholder")

TEMPLATES.Slider = function(v, n)
    return {
        string.format('local %s = ReUI.Slider:new(%d, %d, %d, %d, 0, 100, 50, nil, nil)',
            v, n.x, n.y, n.width, n.height)
    }
end

function DesignerWindow:new()
    local o = ReUIWindow.new(self, 0, 0, 920, 640, "Re:UI Visual Designer")
    o.subtitle = "Layout Editor"
    o.selectedNode = nil
    o.nextOffset = 0
    o.lastExportMessage = nil
    return o
end

function DesignerWindow:createChildren()
    ReUIWindow.createChildren(self)

    local top = self:getTitleBarHeight() + 26
    local paletteWidth = 140
    local propertiesWidth = 240
    local canvasX = paletteWidth + 20
    local canvasWidth = math.max(200, self.width - paletteWidth - propertiesWidth - 40)
    local bottomHeight = self.height - top - 10

    self.palette = ReUIPanel:new(10, top, paletteWidth, bottomHeight, {
        backgroundRole = "surface", borderRole = "border"
    })
    self.palette:initialise()
    self.palette:instantiate()
    self:addChild(self.palette)

    self.canvas = ReUIPanel:new(canvasX, top, canvasWidth, bottomHeight, {
        backgroundRole = "background", borderRole = "border"
    })
    self.canvas:initialise()
    self.canvas:instantiate()
    self:addChild(self.canvas)
    self.canvas.designNodes = {}

    self.properties = ReUIInspector:new(canvasX + canvasWidth + 10, top, propertiesWidth, bottomHeight - 82, {
        labelWidth = 90
    })
    self.properties:initialise()
    self.properties:instantiate()
    self:addChild(self.properties)
    self.properties:on("change", function(control, key, value)
        if key == "label" and self.selectedNode then
            self.selectedNode.label = tostring(value)
        end
    end)

    local buttonY = top + bottomHeight - 78
    self.deleteButton = ReUIButton:new(canvasX + canvasWidth + 10, buttonY, 110, 32,
        "Delete", self, DesignerWindow.onDeleteSelected)
    self.deleteButton:setVariant("danger")
    self.deleteButton:initialise()
    self.deleteButton:instantiate()
    self:addChild(self.deleteButton)

    self.exportButton = ReUIButton:new(canvasX + canvasWidth + 130, buttonY, propertiesWidth - 130, 32,
        "Export", self, DesignerWindow.onExport)
    self.exportButton:setVariant("primary")
    self.exportButton:initialise()
    self.exportButton:instantiate()
    self:addChild(self.exportButton)

    self.saveButton = ReUIButton:new(canvasX + canvasWidth + 10, buttonY + 38, 110, 32,
        "Save", self, DesignerWindow.onSave)
    self.saveButton:setVariant("secondary")
    self.saveButton:initialise()
    self.saveButton:instantiate()
    self:addChild(self.saveButton)

    self.loadButton = ReUIButton:new(canvasX + canvasWidth + 130, buttonY + 38, propertiesWidth - 130, 32,
        "Load", self, DesignerWindow.onLoad)
    self.loadButton:setVariant("secondary")
    self.loadButton:initialise()
    self.loadButton:instantiate()
    self:addChild(self.loadButton)

    self:buildPalette()
end

function DesignerWindow:buildPalette()
    local y = 8
    for _, nodeType in ipairs(PALETTE_TYPES) do
        local button = ReUIButton:new(8, y, self.palette.width - 16, 30, "+ " .. nodeType, self, DesignerWindow.onAddNode)
        button.paletteType = nodeType
        button:setVariant("ghost")
        button:setTextAlignment("left")
        button:initialise()
        button:instantiate()
        self.palette:addChild(button)
        y = y + 36
    end
end

function DesignerWindow:onAddNode(button)
    self:addNode(button.paletteType)
end

function DesignerWindow:addNode(nodeType, x, y, width, height, label)
    if not x then
        self.nextOffset = (self.nextOffset + 18) % 140
        x = 16 + self.nextOffset
        y = 16 + self.nextOffset
    end

    local isContainer = CONTAINER_TYPES[nodeType]
    local node = ReUIDesignNode:new(x, y, width or (isContainer and 220 or 140), height or (isContainer and 160 or 40),
        nodeType, { label = label or nodeType, target = self, onSelected = DesignerWindow.selectNode })
    node:initialise()
    node:instantiate()
    self.canvas:addChild(node)
    table.insert(self.canvas.designNodes, node)
    self:selectNode(node)
    return node
end

function DesignerWindow:selectNode(node)
    if self.selectedNode then
        self.selectedNode:setSelected(false)
    end
    self.selectedNode = node
    node:setSelected(true)

    self.properties:inspect(node)
    self.properties:addProperty("label", "Label", "text", node.label)
end

function DesignerWindow:onDeleteSelected()
    if not self.selectedNode then return end

    self.canvas:removeChild(self.selectedNode)
    for i, node in ipairs(self.canvas.designNodes) do
        if node == self.selectedNode then
            table.remove(self.canvas.designNodes, i)
            break
        end
    end

    self.selectedNode = nil
    self.properties:clear()
end

function DesignerWindow:clearCanvas()
    for _, node in ipairs(self.canvas.designNodes) do
        self.canvas:removeChild(node)
    end
    self.canvas.designNodes = {}
    self.selectedNode = nil
    self.properties:clear()
end

-- A node "belongs" to the first container (VBox/HBox) whose bounds contain
-- its center point. Containers never nest inside each other (one level).
local function findContainer(node, allNodes)
    local centerX = node.x + node.width / 2
    local centerY = node.y + node.height / 2

    for _, candidate in ipairs(allNodes) do
        if candidate ~= node and CONTAINER_TYPES[candidate.nodeType] then
            if centerX >= candidate.x and centerX <= candidate.x + candidate.width
                and centerY >= candidate.y and centerY <= candidate.y + candidate.height then
                return candidate
            end
        end
    end
    return nil
end

function DesignerWindow:generateCode()
    local lines = { "-- Generated by Re:UI Visual Designer", "" }
    local nodes = self.canvas.designNodes
    local counters = {}
    local varNames = {}

    local function nameFor(node)
        if varNames[node] then return varNames[node] end
        counters[node.nodeType] = (counters[node.nodeType] or 0) + 1
        local v = string.lower(node.nodeType) .. counters[node.nodeType]
        varNames[node] = v
        return v
    end

    local function emit(node, attachLine)
        local template = TEMPLATES[node.nodeType]
        if not template then return end
        for _, line in ipairs(template(nameFor(node), node)) do
            table.insert(lines, line)
        end
        table.insert(lines, attachLine)
        table.insert(lines, "")
    end

    -- Top-level nodes (including containers) first, so a container's
    -- variable exists before its children reference it below.
    for _, node in ipairs(nodes) do
        if not findContainer(node, nodes) then
            emit(node, "parent:addChild(" .. nameFor(node) .. ")")
        end
    end

    for _, node in ipairs(nodes) do
        local container = findContainer(node, nodes)
        if container then
            emit(node, nameFor(container) .. ":add(" .. nameFor(node) .. ", { height = " .. node.height .. " })")
        end
    end

    return lines
end

function DesignerWindow:onExport()
    local lines = self:generateCode()
    local writer = getFileWriter("ReUI_Export.lua", true, false)
    for _, line in ipairs(lines) do
        writer:write(line .. "\n")
    end
    writer:close()

    local count = #self.canvas.designNodes
    print("[Re:UI Designer] Exported " .. tostring(count) .. " node(s) to Lua/ReUI_Export.lua")
    self.lastExportMessage = "Exported " .. tostring(count) .. " node(s) to ReUI_Export.lua"
end

local FIELD_SEP = "\t"

local function encodeField(text)
    return tostring(text or ""):gsub("\t", "    ")
end

function DesignerWindow:onSave()
    local writer = getFileWriter("ReUI_Layout.txt", true, false)
    for _, node in ipairs(self.canvas.designNodes) do
        writer:write(table.concat({
            node.nodeType,
            tostring(math.floor(node.x)),
            tostring(math.floor(node.y)),
            tostring(math.floor(node.width)),
            tostring(math.floor(node.height)),
            encodeField(node.label)
        }, FIELD_SEP) .. "\n")
    end
    writer:close()

    local count = #self.canvas.designNodes
    print("[Re:UI Designer] Saved " .. tostring(count) .. " node(s) to Lua/ReUI_Layout.txt")
    self.lastExportMessage = "Saved " .. tostring(count) .. " node(s) to ReUI_Layout.txt"
end

function DesignerWindow:onLoad()
    local reader = getFileReader("ReUI_Layout.txt", true)
    self:clearCanvas()

    local loaded = 0
    local line = reader:readLine()
    while line ~= nil do
        if line ~= "" then
            local parts = {}
            for part in (line .. FIELD_SEP):gmatch("(.-)" .. FIELD_SEP) do
                table.insert(parts, part)
            end
            if #parts >= 5 then
                self:addNode(parts[1], tonumber(parts[2]), tonumber(parts[3]),
                    tonumber(parts[4]), tonumber(parts[5]), parts[6])
                loaded = loaded + 1
            end
        end
        line = reader:readLine()
    end
    reader:close()

    self.lastExportMessage = "Loaded " .. tostring(loaded) .. " node(s) from ReUI_Layout.txt"
    print("[Re:UI Designer] " .. self.lastExportMessage)
end

function DesignerWindow:render()
    ReUIWindow.render(self)

    local muted = ReUITheme.color("textMuted")
    self:drawText("PALETTE", 18, self:getTitleBarHeight() + 6, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    self:drawText("CANVAS — drag to move, bottom-right corner to resize. Drop onto a VBox/HBox to nest it.",
        self.palette.width + 30, self:getTitleBarHeight() + 6, muted.r, muted.g, muted.b, muted.a, UIFont.Small)

    if self.lastExportMessage then
        local success = ReUITheme.color("success")
        self:drawText(self.lastExportMessage, self.canvas:getX() + self.canvas.width + 20, self.height - 116,
            success.r, success.g, success.b, success.a, UIFont.Small)
    end
end

function ReUI.Designer.show()
    if ReUI.Designer.instance then
        ReUIWindowManager:open(ReUI.Designer.instance, { center = false })
        return ReUI.Designer.instance
    end

    local window = DesignerWindow:new()
    window:initialise()
    window:addToUIManager()
    window:centerOnScreen()
    ReUIWindowManager:register(window)
    ReUI.Designer.instance = window
    return window
end

function ReUI.Designer.hide()
    if ReUI.Designer.instance then
        ReUI.Designer.instance:setVisible(false)
    end
end

function ReUI.Designer.toggle()
    if ReUI.Designer.instance and ReUI.Designer.instance:getIsVisible() then
        ReUI.Designer.hide()
    else
        ReUI.Designer.show()
    end
end
