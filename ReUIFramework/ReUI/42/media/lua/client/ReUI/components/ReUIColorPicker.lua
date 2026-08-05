require "ISUI/ISPanel"
require "ReUI/components/ReUISlider"
require "ReUI/components/ReUITextBox"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- RGB sliders + hex entry + swatch preview. Values are 0..1 floats
-- (matching every other ReUI/ISUI color field), sliders just display 0..255.
ReUIColorPicker = ISPanel:derive("ReUIColorPicker")

local function toHex(r, g, b)
    return string.format("%02X%02X%02X",
        math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

local function fromHex(hex)
    hex = tostring(hex or ""):gsub("#", "")
    if string.len(hex) ~= 6 then return nil end
    local r = tonumber(string.sub(hex, 1, 2), 16)
    local g = tonumber(string.sub(hex, 3, 4), 16)
    local b = tonumber(string.sub(hex, 5, 6), 16)
    if not (r and g and b) then return nil end
    return r / 255, g / 255, b / 255
end

function ReUIColorPicker:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 240, height or 130)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.r = options.r or 1
    o.g = options.g or 1
    o.b = options.b or 1
    o.target = options.target
    o.onChange = options.onChange

    ReUIComponent.apply(o, options)
    return o
end

function ReUIColorPicker:createChildren()
    local ch = ReUITheme.metric("controlHeight", 32)
    local gap = 6
    local sliderX = 20
    local swatchSize = math.min(48, self.height)
    local sliderWidth = math.max(60, self.width - sliderX - swatchSize - 10)

    self.redSlider = ReUISlider:new(sliderX, 0, sliderWidth, ch, 0, 255,
        math.floor(self.r * 255), self, ReUIColorPicker.onRedChanged)
    self.redSlider:initialise()
    self:addChild(self.redSlider)

    self.greenSlider = ReUISlider:new(sliderX, ch + gap, sliderWidth, ch, 0, 255,
        math.floor(self.g * 255), self, ReUIColorPicker.onGreenChanged)
    self.greenSlider:initialise()
    self:addChild(self.greenSlider)

    self.blueSlider = ReUISlider:new(sliderX, (ch + gap) * 2, sliderWidth, ch, 0, 255,
        math.floor(self.b * 255), self, ReUIColorPicker.onBlueChanged)
    self.blueSlider:initialise()
    self:addChild(self.blueSlider)

    local hexY = (ch + gap) * 3 + 4
    self.hexBox = ReUITextBox:new(sliderX, hexY, 100, ch, {
        text = toHex(self.r, self.g, self.b),
        maxLength = 6,
        target = self,
        onEnter = ReUIColorPicker.onHexEntered
    })
    self.hexBox:initialise()
    self.hexBox:instantiate()
    self:addChild(self.hexBox)
end

function ReUIColorPicker:onRedChanged(slider, value)
    self.r = value / 255
    self:syncHex()
    self:notifyChanged()
end

function ReUIColorPicker:onGreenChanged(slider, value)
    self.g = value / 255
    self:syncHex()
    self:notifyChanged()
end

function ReUIColorPicker:onBlueChanged(slider, value)
    self.b = value / 255
    self:syncHex()
    self:notifyChanged()
end

function ReUIColorPicker:onHexEntered(control, text)
    local r, g, b = fromHex(text)
    if r then
        self:setColor(r, g, b)
    else
        self:syncHex()
    end
end

function ReUIColorPicker:syncHex()
    if self.hexBox then
        self.hexBox:setText(toHex(self.r, self.g, self.b))
    end
end

function ReUIColorPicker:setColor(r, g, b, notify)
    self.r, self.g, self.b = r, g, b
    if self.redSlider then self.redSlider:setValue(r * 255, false) end
    if self.greenSlider then self.greenSlider:setValue(g * 255, false) end
    if self.blueSlider then self.blueSlider:setValue(b * 255, false) end
    self:syncHex()
    if notify ~= false then self:notifyChanged() end
    return self
end

function ReUIColorPicker:getColor()
    return self.r, self.g, self.b
end

function ReUIColorPicker:notifyChanged()
    if self.emit then self:emit("change", self.r, self.g, self.b) end
    if self.onChange then
        if self.target then
            self.onChange(self.target, self, self.r, self.g, self.b)
        else
            self.onChange(self, self.r, self.g, self.b)
        end
    end
end

function ReUIColorPicker:prerender()
    local text = ReUITheme.color("text")
    local border = ReUITheme.color("border")
    local ch = ReUITheme.metric("controlHeight", 32)
    local gap = 6

    self:drawText("R", 0, ReUITheme.textY(UIFont.Small, 0, ch), text.r, text.g, text.b, text.a, UIFont.Small)
    self:drawText("G", 0, ReUITheme.textY(UIFont.Small, ch + gap, ch), text.r, text.g, text.b, text.a, UIFont.Small)
    self:drawText("B", 0, ReUITheme.textY(UIFont.Small, (ch + gap) * 2, ch), text.r, text.g, text.b, text.a, UIFont.Small)

    local swatchSize = math.min(48, self.height)
    local swatchX = self.width - swatchSize
    self:drawRect(swatchX, 0, swatchSize, swatchSize, 1, self.r, self.g, self.b)
    self:drawRectBorder(swatchX, 0, swatchSize, swatchSize, border.a, border.r, border.g, border.b)
end
