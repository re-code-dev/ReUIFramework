require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

ReUIProgressBar = ISPanel:derive("ReUIProgressBar")

function ReUIProgressBar:new(x, y, width, height, options)
    options = options or {}
    local o = ISPanel.new(self, x or 0, y or 0, width or 240, height or 22)
    setmetatable(o, self)
    self.__index = self

    o.minimum = options.minimum or 0
    o.maximum = options.maximum or 100
    o.value = options.value or o.minimum
    o.fillRole = options.fillRole or "primary"
    o.backgroundRole = options.backgroundRole or "surfaceAlt"
    o.borderRole = options.borderRole or "borderStrong"
    o.textRole = options.textRole or "text"
    o.showText = options.showText ~= false
    o.formatter = options.formatter
    o.font = options.font or UIFont.Small
    o.padding = options.padding or 2
    o.drawBackground = false
    o.drawBorder = false

    ReUIComponent.apply(o, options)
    o:setValue(o.value, true)
    return o
end

function ReUIProgressBar:setRange(minimum, maximum)
    self.minimum = tonumber(minimum) or 0
    self.maximum = tonumber(maximum) or 100
    if self.maximum <= self.minimum then
        self.maximum = self.minimum + 1
    end
    return self:setValue(self.value)
end

function ReUIProgressBar:setValue(value, silent)
    local numeric = tonumber(value) or self.minimum
    local clamped = math.max(self.minimum, math.min(self.maximum, numeric))
    if self.value == clamped then
        return self
    end

    self.value = clamped
    if not silent then
        self:emit("change", clamped, self:getProgress())
    end
    return self
end

function ReUIProgressBar:getValue()
    return self.value
end

function ReUIProgressBar:getProgress()
    local range = self.maximum - self.minimum
    if range <= 0 then
        return 0
    end
    return (self.value - self.minimum) / range
end

function ReUIProgressBar:setFillRole(role)
    self.fillRole = role or "primary"
    return self
end

function ReUIProgressBar:setFormatter(formatter)
    self.formatter = formatter
    return self
end

function ReUIProgressBar:getDisplayText()
    if self.formatter then
        return tostring(self.formatter(self, self.value, self:getProgress()))
    end
    return tostring(math.floor(self:getProgress() * 100 + 0.5)) .. "%"
end

function ReUIProgressBar:prerender()
    local background = ReUITheme.color(self.backgroundRole)
    local border = ReUITheme.color(self.borderRole)
    local fill = ReUITheme.color(self.fillRole)
    local text = ReUITheme.color(self.textRole)

    self:drawRect(0, 0, self.width, self.height,
        background.a, background.r, background.g, background.b)
    self:drawRectBorder(0, 0, self.width, self.height,
        border.a, border.r, border.g, border.b)

    local innerWidth = math.max(0, self.width - self.padding * 2)
    local innerHeight = math.max(0, self.height - self.padding * 2)
    local fillWidth = math.floor(innerWidth * self:getProgress())

    if fillWidth > 0 then
        self:drawRect(self.padding, self.padding, fillWidth, innerHeight,
            fill.a, fill.r, fill.g, fill.b)
    end

    if self.showText then
        local displayText = self:getDisplayText()
        local textWidth = getTextManager():MeasureStringX(self.font, displayText)
        self:drawText(displayText,
            math.floor((self.width - textWidth) / 2),
            ReUITheme.textY(self.font, 0, self.height),
            text.r, text.g, text.b, text.a, self.font)
    end
end

function ReUIProgressBar:render()
end
