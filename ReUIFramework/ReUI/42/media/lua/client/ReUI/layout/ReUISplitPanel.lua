require "ReUI/components/ReUIPanel"
require "ReUI/core/ReUITheme"

-- Two panes divided by a draggable splitter. `orientation`: "horizontal"
-- (side-by-side, drag left/right) or "vertical" (stacked, drag up/down).
-- Distinct from ReUIDockManager: this is a static two-pane layout inside
-- one window, not floating/dockable windows.
ReUISplitPanel = ReUIPanel:derive("ReUISplitPanel")

local SPLITTER_THICKNESS = 6

function ReUISplitPanel:new(x, y, width, height, options)
    options = options or {}
    options.drawBackground = options.drawBackground ~= false
    local o = ReUIPanel.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.orientation = options.orientation or "horizontal"
    o.splitRatio = options.splitRatio or 0.5
    o.minPaneSize = options.minPaneSize or 60
    o.dragging = false

    return o
end

function ReUISplitPanel:createChildren()
    ReUIPanel.createChildren(self)

    self.first = ReUIPanel:new(0, 0, 100, 100, { backgroundRole = "surface", borderRole = "border" })
    self.second = ReUIPanel:new(0, 0, 100, 100, { backgroundRole = "surface", borderRole = "border" })
    self.first:initialise(); self.first:instantiate(); self:addChild(self.first)
    self.second:initialise(); self.second:instantiate(); self:addChild(self.second)

    self:layoutPanes()
end

function ReUISplitPanel:getFirstPane() return self.first end
function ReUISplitPanel:getSecondPane() return self.second end

function ReUISplitPanel:getSplitterRect()
    if self.orientation == "horizontal" then
        local x = self.width * self.splitRatio - SPLITTER_THICKNESS / 2
        return { x = x, y = 0, width = SPLITTER_THICKNESS, height = self.height }
    else
        local y = self.height * self.splitRatio - SPLITTER_THICKNESS / 2
        return { x = 0, y = y, width = self.width, height = SPLITTER_THICKNESS }
    end
end

function ReUISplitPanel:layoutPanes()
    if self.orientation == "horizontal" then
        local splitX = math.floor(self.width * self.splitRatio)
        self.first:setX(0); self.first:setY(0)
        self.first:setWidth(splitX - SPLITTER_THICKNESS / 2); self.first:setHeight(self.height)
        self.second:setX(splitX + SPLITTER_THICKNESS / 2); self.second:setY(0)
        self.second:setWidth(self.width - splitX - SPLITTER_THICKNESS / 2); self.second:setHeight(self.height)
    else
        local splitY = math.floor(self.height * self.splitRatio)
        self.first:setX(0); self.first:setY(0)
        self.first:setWidth(self.width); self.first:setHeight(splitY - SPLITTER_THICKNESS / 2)
        self.second:setX(0); self.second:setY(splitY + SPLITTER_THICKNESS / 2)
        self.second:setWidth(self.width); self.second:setHeight(self.height - splitY - SPLITTER_THICKNESS / 2)
    end
end

function ReUISplitPanel:setSplitRatio(ratio)
    self.splitRatio = math.max(0.05, math.min(0.95, ratio))
    self:layoutPanes()
    return self
end

local function contains(rect, x, y)
    return x >= rect.x and y >= rect.y and x <= rect.x + rect.width and y <= rect.y + rect.height
end

function ReUISplitPanel:onMouseDown(x, y)
    if contains(self:getSplitterRect(), x, y) then
        self.dragging = true
        return true
    end
    return ReUIPanel.onMouseDown(self, x, y)
end

function ReUISplitPanel:onMouseMove(dx, dy)
    if self.dragging then
        local mouseX, mouseY = self:getMouseX(), self:getMouseY()
        local ratio
        if self.orientation == "horizontal" then
            ratio = mouseX / self.width
        else
            ratio = mouseY / self.height
        end
        self:setSplitRatio(ratio)
        return true
    end
    return ReUIPanel.onMouseMove(self, dx, dy)
end

function ReUISplitPanel:onMouseUp(x, y)
    self.dragging = false
    return ReUIPanel.onMouseUp(self, x, y)
end

function ReUISplitPanel:onMouseUpOutside(x, y)
    self.dragging = false
end

function ReUISplitPanel:prerender()
    ReUIPanel.prerender(self)
    local rect = self:getSplitterRect()
    local color = ReUITheme.color(self.dragging and "primary" or "border")
    self:drawRect(rect.x, rect.y, rect.width, rect.height, color.a, color.r, color.g, color.b)
end
