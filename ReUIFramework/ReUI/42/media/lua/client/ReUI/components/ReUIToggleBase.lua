require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

ReUIToggleBase = ISPanel:derive("ReUIToggleBase")

function ReUIToggleBase:new(x, y, width, height, text, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 180, height or ReUITheme.metrics.controlHeight)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.text = tostring(text or "")
    o.value = options.value == true
    o.enable = options.enabled ~= false
    o.font = options.font or UIFont.Small
    o.textRole = options.textRole or "text"
    o.disabledTextRole = options.disabledTextRole or "textDisabled"
    o.focused = false
    o.mouseDown = false
    o.drawBackground = false
    o.drawBorder = false

    ReUIComponent.apply(o, options)
    return o
end

function ReUIToggleBase:setValue(value, silent)
    local nextValue = value == true
    if self.value == nextValue then
        return self
    end

    self.value = nextValue
    self:setState("selected", nextValue)

    if not silent then
        self:emit("change", nextValue)
    end
    return self
end

function ReUIToggleBase:getValue()
    return self.value == true
end

function ReUIToggleBase:toggle()
    if not self.enable then
        return self
    end
    return self:setValue(not self.value)
end

function ReUIToggleBase:setText(text)
    self.text = tostring(text or "")
    return self
end

function ReUIToggleBase:setEnabled(enabled)
    self.enable = enabled == true
    self:setReUIEnabled(self.enable)
    return self
end

function ReUIToggleBase:isEnabled()
    return self.enable == true
end

function ReUIToggleBase:onMouseDown(x, y)
    if not self.enable then
        return false
    end
    self.mouseDown = true
    self:setState("pressed", true)
    return true
end

function ReUIToggleBase:onMouseUp(x, y)
    local wasPressed = self.mouseDown
    self.mouseDown = false
    self:setState("pressed", false)

    if wasPressed and self.enable and self:isMouseOver() then
        self:toggle()
        self.focused = true
        self:setState("focused", true)
        return true
    end
    return false
end

function ReUIToggleBase:onMouseMove(dx, dy)
    self:setState("hovered", true)
end

function ReUIToggleBase:onMouseMoveOutside(dx, dy)
    self:setState("hovered", false)
end

function ReUIToggleBase:onKeyPress(key)
    if not self.enable or not self.focused then
        return
    end

    if key == Keyboard.KEY_SPACE or key == Keyboard.KEY_RETURN then
        self:toggle()
    end
end

function ReUIToggleBase:onGainJoypadFocus(joypadData)
    self.focused = true
    self:setState("focused", true)
end

function ReUIToggleBase:onLoseJoypadFocus(joypadData)
    self.focused = false
    self:setState("focused", false)
end

function ReUIToggleBase:onJoypadDown(button, joypadData)
    if self.enable and button == Joypad.AButton then
        self:toggle()
    end
end

function ReUIToggleBase:render()
end
