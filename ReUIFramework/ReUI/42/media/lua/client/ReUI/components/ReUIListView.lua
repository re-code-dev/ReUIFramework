require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/core/ReUITheme"

-- A scrollable, selectable row list. Built on ReUIScrollContainer so it
-- inherits its clipping/scrollbar behavior for free.
ReUIListView = ReUIScrollContainer:derive("ReUIListView")

function ReUIListView:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIScrollContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.items = {}
    o.rowHeight = tonumber(options.rowHeight) or 28
    o.selectedIndex = nil
    o.target = options.target
    o.onSelect = options.onSelect

    return o
end

function ReUIListView:addItem(label, data)
    local content = self:getContent()
    local index = #self.items + 1
    local viewportWidth = self:getViewportWidth()

    local row = ReUIPanel:new(0, (index - 1) * self.rowHeight, viewportWidth, self.rowHeight, {
        drawBackground = false, drawBorder = false, backgroundRole = "primaryMuted"
    })
    row:initialise()
    row:instantiate()
    content:addChild(row)

    local rowLabel = ReUILabel:new(8, 0, math.max(0, viewportWidth - 16), self.rowHeight,
        tostring(label), { colorRole = "text" })
    rowLabel:initialise()
    rowLabel:instantiate()
    row:addChild(rowLabel)

    row.onMouseDown = function()
        self:selectIndex(index)
        return true
    end

    table.insert(self.items, { label = tostring(label), data = data, row = row, rowLabel = rowLabel })
    self:setContentHeight(#self.items * self.rowHeight)

    return self.items[index]
end

function ReUIListView:selectIndex(index, notify)
    if index < 1 or index > #self.items then return self end

    self.selectedIndex = index
    for i, item in ipairs(self.items) do
        item.row.drawBackground = (i == index)
    end

    if notify ~= false then
        local item = self.items[index]
        if self.emit then self:emit("select", item.data, item.label, index) end
        if self.onSelect then
            if self.target then
                self.onSelect(self.target, self, item.data, item.label, index)
            else
                self.onSelect(self, item.data, item.label, index)
            end
        end
    end

    return self
end

function ReUIListView:getSelected()
    return self.selectedIndex and self.items[self.selectedIndex] or nil
end

function ReUIListView:clear()
    local content = self:getContent()
    for _, item in ipairs(self.items) do
        content:removeChild(item.row)
    end
    self.items = {}
    self.selectedIndex = nil
    self:setContentHeight(0)
    return self
end
