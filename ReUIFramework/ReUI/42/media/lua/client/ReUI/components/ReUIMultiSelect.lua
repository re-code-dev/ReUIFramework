require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- Closed-by-default multi-select box (ReUIDropdown's single-select sibling):
-- opening spawns a top-level popup with a checkbox-style row per option;
-- toggling doesn't close the popup, only an outside click does.
ReUIMultiSelect = ISPanel:derive("ReUIMultiSelect")

local ReUIMultiSelectPopup = ISPanel:derive("ReUIMultiSelectPopup")

function ReUIMultiSelectPopup:new(x, y, width, height, owner)
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.owner = owner
    o.rowHeight = 26
    o.hoverIndex = nil
    return o
end

function ReUIMultiSelectPopup:rowAt(y)
    local index = math.floor(y / self.rowHeight) + 1
    if index < 1 or index > #self.owner.options then return nil end
    return index
end

function ReUIMultiSelectPopup:onMouseMove(dx, dy)
    self.hoverIndex = self:rowAt(self:getMouseY())
end

function ReUIMultiSelectPopup:onMouseDown(x, y)
    local index = self:rowAt(y)
    if index then self.owner:toggle(index) end
    return true
end

function ReUIMultiSelectPopup:onMouseUpOutside(x, y)
    self.owner:closePopup()
end

function ReUIMultiSelectPopup:prerender()
    local bg = ReUITheme.color("surfaceAlt")
    local border = ReUITheme.color("border")
    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    for i, option in ipairs(self.owner.options) do
        local rowY = (i - 1) * self.rowHeight
        if i == self.hoverIndex then
            local hover = ReUITheme.color("surfaceRaised")
            self:drawRect(0, rowY, self.width, self.rowHeight, hover.a, hover.r, hover.g, hover.b)
        end

        local boxSize = 14
        local boxY = rowY + (self.rowHeight - boxSize) / 2
        local border2 = ReUITheme.color("border")
        self:drawRectBorder(8, boxY, boxSize, boxSize, border2.a, border2.r, border2.g, border2.b)
        if self.owner.selected[i] then
            local primary = ReUITheme.color("primary")
            self:drawRect(10, boxY + 2, boxSize - 4, boxSize - 4, primary.a, primary.r, primary.g, primary.b)
        end

        local text = ReUITheme.color("text")
        self:drawText(option.label, 8 + boxSize + 8, ReUITheme.textY(UIFont.Small, rowY, self.rowHeight),
            text.r, text.g, text.b, text.a, UIFont.Small)
    end
end

function ReUIMultiSelect:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 200, height or 30)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.options = {}
    for _, entry in ipairs(options.options or {}) do
        if type(entry) == "table" then
            table.insert(o.options, { label = tostring(entry.label or entry.value), value = entry.value })
        else
            table.insert(o.options, { label = tostring(entry), value = entry })
        end
    end

    o.selected = {}
    o.placeholder = tostring(options.placeholder or "Select...")
    o.target = options.target
    o.onChange = options.onChange
    o.popup = nil
    o.hovered = false

    ReUIComponent.apply(o, options)
    return o
end

function ReUIMultiSelect:toggle(index, notify)
    self.selected[index] = not self.selected[index] or nil
    if notify ~= false then
        local values = self:getSelectedValues()
        if self.emit then self:emit("change", values) end
        if self.onChange then
            if self.target then self.onChange(self.target, self, values) else self.onChange(self, values) end
        end
    end
    return self
end

function ReUIMultiSelect:getSelectedValues()
    local values = {}
    for i, option in ipairs(self.options) do
        if self.selected[i] then table.insert(values, option.value) end
    end
    return values
end

function ReUIMultiSelect:getSelectedLabels()
    local labels = {}
    for i, option in ipairs(self.options) do
        if self.selected[i] then table.insert(labels, option.label) end
    end
    return labels
end

function ReUIMultiSelect:openPopup()
    if self.popup or #self.options == 0 then return end
    local popupHeight = math.min(#self.options * 26, 8 * 26)
    self.popup = ReUIMultiSelectPopup:new(
        self:getAbsoluteX(), self:getAbsoluteY() + self.height, self.width, popupHeight, self)
    self.popup:initialise()
    self.popup:instantiate()
    self.popup:addToUIManager()
    self.popup:bringToTop()
end

function ReUIMultiSelect:closePopup()
    if not self.popup then return end
    self.popup:removeFromUIManager()
    self.popup = nil
end

function ReUIMultiSelect:togglePopup()
    if self.popup then self:closePopup() else self:openPopup() end
end

function ReUIMultiSelect:onMouseDown(x, y)
    self:togglePopup()
    return true
end

function ReUIMultiSelect:onMouseMove(dx, dy)
    self.hovered = true
    return ISPanel.onMouseMove(self, dx, dy)
end

function ReUIMultiSelect:onMouseMoveOutside(dx, dy)
    self.hovered = false
end

function ReUIMultiSelect:prerender()
    local bg = ReUITheme.color(self.hovered and "surfaceRaised" or "surfaceAlt")
    local border = ReUITheme.color(self.popup and "primary" or "border")
    local text = ReUITheme.color("text")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    local labels = self:getSelectedLabels()
    local summary = #labels == 0 and self.placeholder
        or (#labels == 1 and labels[1] or (#labels .. " selected"))
    local color = #labels == 0 and ReUITheme.color("textMuted") or text

    self:drawText(summary, 8, ReUITheme.textY(UIFont.Small, 0, self.height),
        color.r, color.g, color.b, color.a, UIFont.Small)

    local arrow = self.popup and "^" or "v"
    self:drawText(arrow, self.width - 18, ReUITheme.textY(UIFont.Small, 0, self.height),
        text.r, text.g, text.b, text.a, UIFont.Small)
end

function ReUIMultiSelect:render()
end
