require "ISUI/ISTextEntryBox"

local hasReUIComponent = pcall(require, "ReUI/core/ReUIComponent")
local hasReUITheme = pcall(require, "ReUI/core/ReUITheme")
require "ReUI/core/ReUICompatibility"
require "ReUI/core/ReUIFocusManager"

ReUITextBox = ISTextEntryBox:derive("ReUITextBox")

local fallback = {
    surface = { r = 0.075, g = 0.085, b = 0.11, a = 1.0 },
    surfaceAlt = { r = 0.11, g = 0.12, b = 0.15, a = 1.0 },
    border = { r = 0.22, g = 0.25, b = 0.31, a = 1.0 },
    primary = { r = 0.30, g = 0.76, b = 1.0, a = 1.0 },
    danger = { r = 0.91, g = 0.30, b = 0.24, a = 1.0 },
    text = { r = 0.96, g = 0.97, b = 0.98, a = 1.0 },
    textMuted = { r = 0.62, g = 0.66, b = 0.70, a = 1.0 },
    textDisabled = { r = 0.39, g = 0.42, b = 0.46, a = 1.0 }
}

local function color(role)
    if hasReUITheme and ReUITheme and ReUITheme.color then
        return ReUITheme.color(role)
    end
    return fallback[role] or fallback.text
end

local function clampText(text, maxLength)
    text = tostring(text or "")
    if maxLength and maxLength > 0 and string.len(text) > maxLength then
        return string.sub(text, 1, maxLength)
    end
    return text
end

function ReUITextBox:new(x, y, width, height, options)
    options = options or {}

    local initialText = tostring(options.text or "")
    local o = ISTextEntryBox.new(self, initialText, x, y, width, height)

    o.placeholder = tostring(options.placeholder or "")
    o.maxLength = tonumber(options.maxLength) or 0
    o.password = options.password == true
    o.readOnly = options.readOnly == true
    o.numbersOnly = options.numbersOnly == true
    o.allowFloat = options.allowFloat == true
    o.enabled = options.enabled ~= false
    o.valid = true
    o.errorText = nil
    o.validator = options.validator
    o.target = options.target
    o.onChangeCallback = options.onChange
    o.onEnterCallback = options.onEnter
    o.onFocusCallback = options.onFocus
    o.onBlurCallback = options.onBlur
    o.lastKnownText = initialText
    o.font = options.font or UIFont.Small
    o.paddingLeft = tonumber(options.paddingLeft) or 9
    o.paddingRight = tonumber(options.paddingRight) or 9
    o.showClearButton = options.showClearButton == true
    o.clearButtonWidth = 24
    o.reuiFocused = false
    o.reuiHovered = false
    o.tabOrder = tonumber(options.tabOrder)

    o.backgroundColor = color("surface")
    o.borderColor = color("border")
    o.textColor = color("text")

    if hasReUIComponent and ReUIComponent and ReUIComponent.apply then
        ReUIComponent.apply(o, options)
    end

    return o
end

function ReUITextBox:initialise()
    -- Build 42 creates the native text-entry object during instantiate(), not initialise().
    -- Calling native setters here causes javaObject == nil.
    ISTextEntryBox.initialise(self)
end

function ReUITextBox:instantiate()
    ISTextEntryBox.instantiate(self)
    ReUICompatibility.applyTextBoxOptions(self)
    ReUIFocusManager.register(self, self.tabOrder)
end

function ReUITextBox:setText(value)
    value = clampText(value, self.maxLength)
    ISTextEntryBox.setText(self, value)
    self.lastKnownText = value
    self:validate()
    return self
end

function ReUITextBox:getValue()
    return self:getText()
end

function ReUITextBox:setValue(value)
    return self:setText(value)
end

function ReUITextBox:clear()
    self:setText("")
    self:notifyChanged()
    return self
end

function ReUITextBox:setPlaceholder(value)
    self.placeholder = tostring(value or "")
    return self
end

function ReUITextBox:setPassword(value)
    self.password = value == true
    ReUICompatibility.setTextBoxMasked(self, self.password)
    return self
end

function ReUITextBox:setReadOnly(value)
    self.readOnly = value == true
    ReUICompatibility.setTextBoxEditable(self, not self.readOnly and self.enabled)
    return self
end

function ReUITextBox:setEnabled(value)
    self.enabled = value == true
    ReUICompatibility.setTextBoxEditable(self, self.enabled and not self.readOnly)
    return self
end

function ReUITextBox:isEnabled()
    return self.enabled
end

function ReUITextBox:setMaxLength(value)
    self.maxLength = math.max(0, tonumber(value) or 0)
    ReUICompatibility.setTextBoxMaxLength(self, self.maxLength)
    self:setText(self:getText())
    return self
end

function ReUITextBox:setNumbersOnly(value, allowFloat)
    self.numbersOnly = value == true
    self.allowFloat = allowFloat == true

    ReUICompatibility.setTextBoxOnlyNumbers(self, self.numbersOnly and not self.allowFloat)
    return self
end

function ReUITextBox:setValidator(callback)
    self.validator = callback
    self:validate()
    return self
end

function ReUITextBox:setError(message)
    self.valid = false
    self.errorText = tostring(message or "Invalid value")
    return self
end

function ReUITextBox:clearError()
    self.valid = true
    self.errorText = nil
    return self
end

function ReUITextBox:validate()
    local text = self:getText() or ""

    if self.numbersOnly and self.allowFloat and text ~= "" then
        local normalized = string.gsub(text, ",", ".")
        if tonumber(normalized) == nil then
            return self:setError("Only numeric values are allowed")
        end
    end

    if self.validator then
        local ok, result, message = pcall(self.validator, self, text)
        if not ok then
            return self:setError("Validator error")
        end
        if result == false then
            return self:setError(message or "Invalid value")
        end
    end

    return self:clearError()
end

function ReUITextBox:notifyChanged()
    local text = self:getText() or ""

    if self.maxLength > 0 and string.len(text) > self.maxLength then
        text = string.sub(text, 1, self.maxLength)
        ISTextEntryBox.setText(self, text)
    end

    if self.numbersOnly and self.allowFloat then
        local filtered = string.gsub(text, "[^0-9%.,%-]", "")
        if filtered ~= text then
            text = filtered
            ISTextEntryBox.setText(self, text)
        end
    end

    self.lastKnownText = text
    self:validate()

    if self.emit then self:emit("change", text, self.valid) end
    if self.onChangeCallback then
        if self.target then
            self.onChangeCallback(self.target, self, text, self.valid)
        else
            self.onChangeCallback(self, text, self.valid)
        end
    end
end

-- Build 42 calls this while text is edited.
function ReUITextBox:onTextChange()
    self:notifyChanged()
end

-- Build 42 calls this when Enter is accepted.
function ReUITextBox:onCommandEntered()
    local text = self:getText() or ""
    self:validate()

    if self.emit then self:emit("enter", text, self.valid) end
    if self.onEnterCallback then
        if self.target then
            self.onEnterCallback(self.target, self, text, self.valid)
        else
            self.onEnterCallback(self, text, self.valid)
        end
    end
end

function ReUITextBox:onGainFocus()
    self.reuiFocused = true
    if ISTextEntryBox.onGainFocus then
        ISTextEntryBox.onGainFocus(self)
    end
    if self.emit then self:emit("focus") end
    if self.onFocusCallback then
        if self.target then self.onFocusCallback(self.target, self)
        else self.onFocusCallback(self) end
    end
end

function ReUITextBox:onLoseFocus()
    self.reuiFocused = false
    if ISTextEntryBox.onLoseFocus then
        ISTextEntryBox.onLoseFocus(self)
    end
    self:validate()
    if self.emit then self:emit("blur", self.valid) end
    if self.onBlurCallback then
        if self.target then self.onBlurCallback(self.target, self, self.valid)
        else self.onBlurCallback(self, self.valid) end
    end
end

function ReUITextBox:onMouseMove(dx, dy)
    self.reuiHovered = true
    if ISTextEntryBox.onMouseMove then
        return ISTextEntryBox.onMouseMove(self, dx, dy)
    end
end

function ReUITextBox:onMouseMoveOutside(dx, dy)
    self.reuiHovered = false
    if ISTextEntryBox.onMouseMoveOutside then
        return ISTextEntryBox.onMouseMoveOutside(self, dx, dy)
    end
end

function ReUITextBox:prerender()
    local bg = self.enabled and color("surface") or color("surfaceAlt")
    local border = color("border")

    if not self.valid then
        border = color("danger")
    elseif self.reuiFocused then
        border = color("primary")
    end

    self.backgroundColor = { r = bg.r, g = bg.g, b = bg.b, a = bg.a }
    self.borderColor = { r = border.r, g = border.g, b = border.b, a = border.a }
    self.textColor = self.enabled and color("text") or color("textDisabled")

    ISTextEntryBox.prerender(self)
end

function ReUITextBox:render()
    ISTextEntryBox.render(self)

    local text = self:getText() or ""
    if text == "" and self.placeholder ~= "" and not self.reuiFocused then
        local c = color("textMuted")
        local fontHeight = getTextManager():getFontHeight(self.font)
        local y = math.floor((self.height - fontHeight) / 2)
        self:drawText(self.placeholder, self.paddingLeft, y, c.r, c.g, c.b, 0.78, self.font)
    end

    if self.errorText and self.errorText ~= "" then
        local c = color("danger")
        self:drawText(self.errorText, 2, self.height + 3, c.r, c.g, c.b, c.a, UIFont.Small)
    end
end
