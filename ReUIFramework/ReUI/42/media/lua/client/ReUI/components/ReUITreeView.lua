require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/core/ReUITheme"

-- A hierarchical, expandable/collapsible node list. Rows are rebuilt from
-- scratch on every structural change (expand/collapse/add/select); simple
-- and correct at the scale a mod UI tree is expected to reach.
ReUITreeView = ReUIScrollContainer:derive("ReUITreeView")

local function flatten(nodes, depth, out)
    for _, node in ipairs(nodes) do
        node.depth = depth
        table.insert(out, node)
        if node.expanded and #node.children > 0 then
            flatten(node.children, depth + 1, out)
        end
    end
end

function ReUITreeView:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIScrollContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.rowHeight = tonumber(options.rowHeight) or 26
    o.roots = {}
    o.rows = {}
    o.selectedNode = nil
    o.target = options.target
    o.onSelect = options.onSelect

    return o
end

function ReUITreeView:addNode(parent, label, data)
    local node = {
        label = tostring(label),
        data = data,
        children = {},
        expanded = false,
        parent = parent
    }

    if parent then
        table.insert(parent.children, node)
    else
        table.insert(self.roots, node)
    end

    self:rebuild()
    return node
end

function ReUITreeView:toggleNode(node)
    node.expanded = not node.expanded
    self:rebuild()
    return self
end

function ReUITreeView:rebuild()
    local content = self:getContent()
    for _, row in ipairs(self.rows) do
        content:removeChild(row.panel)
    end
    self.rows = {}

    local flat = {}
    flatten(self.roots, 0, flat)

    local viewportWidth = self:getViewportWidth()

    for index, node in ipairs(flat) do
        local panel = ReUIPanel:new(0, (index - 1) * self.rowHeight, viewportWidth, self.rowHeight, {
            drawBackground = (node == self.selectedNode),
            backgroundRole = "primaryMuted",
            drawBorder = false
        })
        panel:initialise()
        panel:instantiate()
        content:addChild(panel)

        local hasChildren = #node.children > 0
        local indent = 8 + node.depth * 16
        local prefix = hasChildren and (node.expanded and "v " or "> ") or "   "

        local label = ReUILabel:new(indent, 0, math.max(0, viewportWidth - indent - 8), self.rowHeight,
            prefix .. node.label, { colorRole = "text" })
        label:initialise()
        label:instantiate()
        panel:addChild(label)

        panel.onMouseDown = function(_, x)
            if hasChildren and x < indent then
                self:toggleNode(node)
            else
                self:selectNode(node)
            end
            return true
        end

        table.insert(self.rows, { node = node, panel = panel, label = label })
    end

    self:setContentHeight(#flat * self.rowHeight)
end

function ReUITreeView:selectNode(node, notify)
    self.selectedNode = node
    self:rebuild()

    if notify ~= false then
        if self.emit then self:emit("select", node.data, node.label, node) end
        if self.onSelect then
            if self.target then
                self.onSelect(self.target, self, node.data, node.label, node)
            else
                self.onSelect(self, node.data, node.label, node)
            end
        end
    end

    return self
end

function ReUITreeView:getSelected()
    return self.selectedNode
end

function ReUITreeView:clear()
    self.roots = {}
    self.selectedNode = nil
    self:rebuild()
    return self
end
