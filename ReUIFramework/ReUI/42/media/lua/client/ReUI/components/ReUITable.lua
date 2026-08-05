require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/core/ReUITheme"

-- Column-headered, sortable, selectable data table. Rows are plain Lua
-- tables keyed by column key; headers are click-to-sort (ascending, then
-- descending, then back to insertion order). Built on ReUIScrollContainer
-- for the row viewport, same as ReUIListView/ReUITreeView.
ReUITable = ReUIPanel:derive("ReUITable")

local HEADER_HEIGHT = 28
local ROW_HEIGHT = 26

function ReUITable:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIPanel.new(self, x, y, width, height, { backgroundRole = "surface", borderRole = "border" })
    setmetatable(o, self)
    self.__index = self

    o.columns = options.columns or {}          -- {key, label, width}[]
    o.rows = options.rows or {}
    o.originalOrder = {}
    for i, row in ipairs(o.rows) do o.originalOrder[i] = row end
    o.sortKey = nil
    o.sortDirection = 1
    o.selectedIndex = nil
    o.target = options.target
    o.onSelect = options.onSelect
    o.hoverHeaderIndex = nil

    return o
end

function ReUITable:createChildren()
    ReUIPanel.createChildren(self)
    self.scroll = ReUIScrollContainer:new(0, HEADER_HEIGHT, self.width, self.height - HEADER_HEIGHT, {
        backgroundRole = "surface", borderRole = "border", drawBorder = false
    })
    self.scroll:initialise()
    self.scroll:instantiate()
    self:addChild(self.scroll)
    self:rebuildRows()
end

function ReUITable:setRows(rows)
    self.rows = rows or {}
    self.originalOrder = {}
    for i, row in ipairs(self.rows) do self.originalOrder[i] = row end
    self.selectedIndex = nil
    self:rebuildRows()
end

function ReUITable:columnX(index)
    local x = 0
    for i = 1, index - 1 do x = x + (self.columns[i].width or 120) end
    return x
end

function ReUITable:sortBy(key)
    if self.sortKey == key then
        if self.sortDirection == 1 then
            self.sortDirection = -1
        else
            self.sortKey = nil
            self.rows = {}
            for i, row in ipairs(self.originalOrder) do self.rows[i] = row end
            self:rebuildRows()
            return
        end
    else
        self.sortKey = key
        self.sortDirection = 1
    end

    table.sort(self.rows, function(a, b)
        local av, bv = a[key], b[key]
        if av == bv then return false end
        if type(av) == "number" and type(bv) == "number" then
            return self.sortDirection == 1 and av < bv or av > bv
        end
        local as, bs = tostring(av), tostring(bv)
        return self.sortDirection == 1 and as < bs or as > bs
    end)
    self:rebuildRows()
end

function ReUITable:rebuildRows()
    local content = self.scroll:getContent()
    for _, rowPanel in ipairs(self.rowPanels or {}) do
        content:removeChild(rowPanel)
    end
    self.rowPanels = {}

    local viewportWidth = self.scroll:getViewportWidth()
    for rowIndex, row in ipairs(self.rows) do
        local rowPanel = ReUIPanel:new(0, (rowIndex - 1) * ROW_HEIGHT, viewportWidth, ROW_HEIGHT, {
            drawBackground = rowIndex == self.selectedIndex, backgroundRole = "primaryMuted", drawBorder = false
        })
        rowPanel:initialise(); rowPanel:instantiate(); content:addChild(rowPanel)
        table.insert(self.rowPanels, rowPanel)

        for colIndex, column in ipairs(self.columns) do
            local label = ReUILabel:new(self:columnX(colIndex) + 6, 0, (column.width or 120) - 12, ROW_HEIGHT,
                tostring(row[column.key] or ""), { colorRole = "text" })
            label:initialise(); label:instantiate(); rowPanel:addChild(label)
        end

        rowPanel.onMouseDown = function()
            self:selectRow(rowIndex)
            return true
        end
    end

    self.scroll:setContentHeight(#self.rows * ROW_HEIGHT)
end

function ReUITable:selectRow(index, notify)
    self.selectedIndex = index
    self:rebuildRows()
    if notify ~= false then
        local row = self.rows[index]
        if self.emit then self:emit("select", row, index) end
        if self.onSelect then
            if self.target then self.onSelect(self.target, self, row, index)
            else self.onSelect(self, row, index) end
        end
    end
end

local function contains(rect, x, y)
    return x >= rect.x and y >= rect.y and x <= rect.x + rect.width and y <= rect.y + rect.height
end

function ReUITable:onMouseMove(dx, dy)
    local y = self:getMouseY()
    if y <= HEADER_HEIGHT then
        local x = self:getMouseX()
        for i = 1, #self.columns do
            if contains({ x = self:columnX(i), y = 0, width = self.columns[i].width or 120, height = HEADER_HEIGHT }, x, y) then
                self.hoverHeaderIndex = i
                return
            end
        end
    end
    self.hoverHeaderIndex = nil
end

function ReUITable:onMouseMoveOutside(dx, dy)
    self.hoverHeaderIndex = nil
end

function ReUITable:onMouseDown(x, y)
    if y <= HEADER_HEIGHT then
        for i, column in ipairs(self.columns) do
            if contains({ x = self:columnX(i), y = 0, width = column.width or 120, height = HEADER_HEIGHT }, x, y) then
                self:sortBy(column.key)
                return true
            end
        end
    end
    return ReUIPanel.onMouseDown(self, x, y)
end

function ReUITable:prerender()
    ReUIPanel.prerender(self)

    local headerBg = ReUITheme.color("surfaceAlt")
    local border = ReUITheme.color("border")
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")

    self:drawRect(0, 0, self.width, HEADER_HEIGHT, headerBg.a, headerBg.r, headerBg.g, headerBg.b)
    self:drawRect(0, HEADER_HEIGHT - 1, self.width, 1, border.a, border.r, border.g, border.b)

    for i, column in ipairs(self.columns) do
        local x = self:columnX(i)
        if i == self.hoverHeaderIndex then
            local hover = ReUITheme.color("surfaceRaised")
            self:drawRect(x, 0, column.width or 120, HEADER_HEIGHT, hover.a, hover.r, hover.g, hover.b)
        end

        local color = self.sortKey == column.key and ReUITheme.color("primary") or text
        self:drawText(column.label, x + 6, ReUITheme.textY(UIFont.Small, 0, HEADER_HEIGHT),
            color.r, color.g, color.b, color.a, UIFont.Small)

        if self.sortKey == column.key then
            local arrow = self.sortDirection == 1 and "^" or "v"
            self:drawText(arrow, x + (column.width or 120) - 16, ReUITheme.textY(UIFont.Small, 0, HEADER_HEIGHT),
                color.r, color.g, color.b, color.a, UIFont.Small)
        end

        if i < #self.columns then
            self:drawRect(x + (column.width or 120) - 1, 4, 1, HEADER_HEIGHT - 8,
                border.a, border.r, border.g, border.b)
        end
    end
end
