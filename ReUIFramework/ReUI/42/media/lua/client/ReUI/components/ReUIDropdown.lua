require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A closed-by-default select box. Opening it spawns a top-level popup panel
-- (added directly to the UIManager, not as a child) listing every option;
-- picking one or clicking outside closes it again.
ReUIDropdown = ISPanel:derive("ReUIDropdown")

-- The popup is a private inner class: it draws/handles its own option rows
-- and reports the pick back to the owning ReUIDropdown.
local ReUIDropdownPopup = ISPanel:derive("ReUIDropdownPopup")

function ReUIDropdownPopup:new(x, y, width, height, owner)
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.owner = owner
    o.rowHeight = 26
    o.hoverIndex = nil
    return o
end

function ReUIDropdownPopup:rowAt(y)
    local index = math.floor(y / self.rowHeight) + 1
    if index < 1 or index > #self.owner.options then return nil end
    return index
end

function ReUIDropdownPopup:onMouseMove(dx, dy)
    self.hoverIndex = self:rowAt(self:getMouseY())
end

function ReUIDropdownPopup:onMouseDown(x, y)
    local index = self:rowAt(y)
    if index then
        self.owner:select(index)
    end
    self.owner:closePopup()
    return true
end

function ReUIDropdownPopup:onMouseUpOutside(x, y)
    self.owner:closePopup()
end

function ReUIDropdownPopup:prerender()
    local bg = ReUITheme.color("surfaceAlt")
    local border = ReUITheme.color("border")
    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    for i, option in ipairs(self.owner.options) do
        local rowY = (i - 1) * self.rowHeight
        if i == self.owner.selectedIndex then
            local sel = ReUITheme.color("primaryMuted")
            self:drawRect(0, rowY, self.width, self.rowHeight, sel.a, sel.r, sel.g, sel.b)
        elseif i == self.hoverIndex then
            local hover = ReUITheme.color("surfaceRaised")
            self:drawRect(0, rowY, self.width, self.rowHeight, hover.a, hover.r, hover.g, hover.b)
        end

        local text = ReUITheme.color("text")
        self:drawText(option.label, 8, ReUITheme.textY(UIFont.Small, rowY, self.rowHeight),
            text.r, text.g, text.b, text.a, UIFont.Small)
    end
end

function ReUIDropdown:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 160, height or 30)
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

    o.selectedIndex = nil
    o.placeholder = tostring(options.placeholder or "Select...")
    o.target = options.target
    o.onChange = options.onChange
    o.popup = nil
    o.hovered = false

    ReUIComponent.apply(o, options)

    if options.selectedIndex then
        o:select(options.selectedIndex, false)
    end

    return o
end

function ReUIDropdown:setOptions(list)
    self.options = {}
    for _, entry in ipairs(list or {}) do
        if type(entry) == "table" then
            table.insert(self.options, { label = tostring(entry.label or entry.value), value = entry.value })
        else
            table.insert(self.options, { label = tostring(entry), value = entry })
        end
    end
    self.selectedIndex = nil
    self:closePopup()
    return self
end

function ReUIDropdown:select(index, notify)
    if index < 1 or index > #self.options then return self end
    self.selectedIndex = index

    if notify ~= false then
        local option = self.options[index]
        if self.emit then self:emit("change", option.value, option, index) end
        if self.onChange then
            if self.target then
                self.onChange(self.target, self, option.value, option)
            else
                self.onChange(self, option.value, option)
            end
        end
    end
    return self
end

function ReUIDropdown:selectValue(value, notify)
    for i, option in ipairs(self.options) do
        if option.value == value then
            return self:select(i, notify)
        end
    end
    return self
end

function ReUIDropdown:getSelected()
    if not self.selectedIndex then return nil end
    return self.options[self.selectedIndex]
end

function ReUIDropdown:getSelectedValue()
    local option = self:getSelected()
    return option and option.value or nil
end

function ReUIDropdown:openPopup()
    if self.popup or #self.options == 0 then return end

    local popupHeight = math.min(#self.options * 26, 8 * 26)
    self.popup = ReUIDropdownPopup:new(
        self:getAbsoluteX(), self:getAbsoluteY() + self.height,
        self.width, popupHeight, self)
    self.popup:initialise()
    self.popup:instantiate()
    self.popup:addToUIManager()
    self.popup:bringToTop()
end

function ReUIDropdown:closePopup()
    if not self.popup then return end
    self.popup:removeFromUIManager()
    self.popup = nil
end

function ReUIDropdown:togglePopup()
    if self.popup then
        self:closePopup()
    else
        self:openPopup()
    end
end

function ReUIDropdown:onMouseDown(x, y)
    self:togglePopup()
    return true
end

function ReUIDropdown:onMouseMove(dx, dy)
    self.hovered = true
    return ISPanel.onMouseMove(self, dx, dy)
end

function ReUIDropdown:onMouseMoveOutside(dx, dy)
    self.hovered = false
end

function ReUIDropdown:prerender()
    local bg = ReUITheme.color(self.hovered and "surfaceRaised" or "surfaceAlt")
    local border = ReUITheme.color(self.popup and "primary" or "border")
    local text = ReUITheme.color("text")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    local option = self:getSelected()
    local label = option and option.label or self.placeholder
    local labelColor = option and text or ReUITheme.color("textMuted")

    self:drawText(label, 8, ReUITheme.textY(UIFont.Small, 0, self.height),
        labelColor.r, labelColor.g, labelColor.b, labelColor.a, UIFont.Small)

    local arrow = self.popup and "^" or "v"
    self:drawText(arrow, self.width - 18, ReUITheme.textY(UIFont.Small, 0, self.height),
        text.r, text.g, text.b, text.a, UIFont.Small)
end

function ReUIDropdown:render()
end
