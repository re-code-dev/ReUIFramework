require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"

ReUISlider = ISPanel:derive("ReUISlider")

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

local function roundToStep(value, minimum, step)
    if not step or step <= 0 then
        return value
    end

    local steps = math.floor(((value - minimum) / step) + 0.5)

    return minimum + steps * step
end

function ReUISlider:new(
    x,
    y,
    width,
    height,
    minimum,
    maximum,
    value,
    target,
    onValueChanged
)
    local instance = ISPanel.new(self, x, y, width, height)

    instance:noBackground()
    instance:setWantMouseEvents(true)

    instance.minimum = minimum or 0
    instance.maximum = maximum or 100
    instance.value = value or instance.minimum
    instance.step = 1

    instance.target = target
    instance.onValueChanged = onValueChanged

    instance.trackHeight = 6
    instance.thumbWidth = 16
    instance.thumbHeight = 22

    instance.dragging = false
    instance.hovered = false
    instance.enabled = true

    instance.showValue = false
    instance.valueSuffix = ""
    instance.valuePrefix = ""

    -- Theme-driven defaults; :setTrackColor/:setFillColor/:setThumbColor
    -- still let a caller override any of these explicitly.
    local track = ReUITheme.color("surfaceAlt")
    local fill = ReUITheme.color("primary")
    local thumb = ReUITheme.color("text")
    local disabled = ReUITheme.color("textDisabled")
    local text = ReUITheme.color("text")

    instance.trackColor = { r = track.r, g = track.g, b = track.b, a = track.a }
    instance.fillColor = { r = fill.r, g = fill.g, b = fill.b, a = fill.a }
    instance.thumbColor = { r = thumb.r, g = thumb.g, b = thumb.b, a = thumb.a }
    instance.thumbHoverColor = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 }
    instance.disabledColor = { r = disabled.r, g = disabled.g, b = disabled.b, a = 0.70 }
    instance.textColor = { r = text.r, g = text.g, b = text.b, a = text.a }

    instance.value = clamp(
        instance.value,
        instance.minimum,
        instance.maximum
    )

    return instance
end

function ReUISlider:initialise()
    ISPanel.initialise(self)
end

function ReUISlider:createChildren()
    ISPanel.createChildren(self)
end

function ReUISlider:setRange(minimum, maximum)
    minimum = minimum or 0
    maximum = maximum or 100

    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end

    self.minimum = minimum
    self.maximum = maximum

    self:setValue(self.value, false)

    return self
end

function ReUISlider:setMinimum(value)
    return self:setRange(value, self.maximum)
end

function ReUISlider:setMaximum(value)
    return self:setRange(self.minimum, value)
end

function ReUISlider:setStep(step)
    self.step = math.max(0, step or 0)

    self:setValue(self.value, false)

    return self
end

function ReUISlider:setEnabled(enabled)
    self.enabled = enabled == true

    if not self.enabled then
        self.dragging = false
    end

    return self
end

function ReUISlider:isEnabled()
    return self.enabled
end

function ReUISlider:setShowValue(show)
    self.showValue = show == true

    return self
end

function ReUISlider:setValuePrefix(prefix)
    self.valuePrefix = prefix or ""

    return self
end

function ReUISlider:setValueSuffix(suffix)
    self.valueSuffix = suffix or ""

    return self
end

function ReUISlider:getValue()
    return self.value
end

function ReUISlider:getNormalizedValue()
    local range = self.maximum - self.minimum

    if range <= 0 then
        return 0
    end

    return clamp(
        (self.value - self.minimum) / range,
        0,
        1
    )
end

function ReUISlider:setValue(value, notify)
    local oldValue = self.value

    value = tonumber(value) or self.minimum
    value = clamp(value, self.minimum, self.maximum)
    value = roundToStep(value, self.minimum, self.step)
    value = clamp(value, self.minimum, self.maximum)

    self.value = value

    if notify ~= false and oldValue ~= self.value then
        self:notifyValueChanged()
    end

    return self
end

function ReUISlider:notifyValueChanged()
    if not self.onValueChanged then
        return
    end

    if self.target then
        self.onValueChanged(
            self.target,
            self,
            self.value
        )
    else
        self.onValueChanged(
            self,
            self.value
        )
    end
end

function ReUISlider:getTrackBounds()
    local reservedTextWidth = 0

    if self.showValue then
        reservedTextWidth = 70
    end

    local trackX = self.thumbWidth / 2
    local trackWidth =
        self.width
        - self.thumbWidth
        - reservedTextWidth

    trackWidth = math.max(1, trackWidth)

    local trackY =
        math.floor((self.height - self.trackHeight) / 2)

    return trackX, trackY, trackWidth, self.trackHeight
end

function ReUISlider:getThumbBounds()
    local trackX, _, trackWidth =
        self:getTrackBounds()

    local normalized = self:getNormalizedValue()

    local centerX =
        trackX + trackWidth * normalized

    local thumbX =
        centerX - self.thumbWidth / 2

    local thumbY =
        math.floor((self.height - self.thumbHeight) / 2)

    return thumbX, thumbY, self.thumbWidth, self.thumbHeight
end

function ReUISlider:isPointInside(
    x,
    y,
    boundsX,
    boundsY,
    boundsWidth,
    boundsHeight
)
    return x >= boundsX
        and x <= boundsX + boundsWidth
        and y >= boundsY
        and y <= boundsY + boundsHeight
end

function ReUISlider:setValueFromMouseX(mouseX)
    local trackX, _, trackWidth =
        self:getTrackBounds()

    local ratio = clamp(
        (mouseX - trackX) / trackWidth,
        0,
        1
    )

    local value =
        self.minimum
        + (self.maximum - self.minimum) * ratio

    self:setValue(value, true)
end

function ReUISlider:onMouseDown(x, y)
    if not self.enabled then
        return false
    end

    local trackX, trackY, trackWidth, trackHeight =
        self:getTrackBounds()

    local thumbX, thumbY, thumbWidth, thumbHeight =
        self:getThumbBounds()

    local insideTrack = self:isPointInside(
        x,
        y,
        trackX - self.thumbWidth / 2,
        trackY - 8,
        trackWidth + self.thumbWidth,
        trackHeight + 16
    )

    local insideThumb = self:isPointInside(
        x,
        y,
        thumbX,
        thumbY,
        thumbWidth,
        thumbHeight
    )

    if not insideTrack and not insideThumb then
        return false
    end

    self.dragging = true
    self:setCapture(true)
    self:setValueFromMouseX(x)

    return true
end

function ReUISlider:onMouseMove(dx, dy)
    local mouseX = self:getMouseX()
    local mouseY = self:getMouseY()

    local thumbX, thumbY, thumbWidth, thumbHeight =
        self:getThumbBounds()

    self.hovered = self:isPointInside(
        mouseX,
        mouseY,
        thumbX - 4,
        thumbY - 4,
        thumbWidth + 8,
        thumbHeight + 8
    )

    if self.dragging and self.enabled then
        self:setValueFromMouseX(mouseX)
    end
end

function ReUISlider:onMouseMoveOutside(dx, dy)
    self.hovered = false

    if self.dragging and self.enabled then
        self:setValueFromMouseX(self:getMouseX())
    end
end

function ReUISlider:onMouseUp(x, y)
    if not self.dragging then
        return false
    end

    self.dragging = false
    self:setCapture(false)

    return true
end

function ReUISlider:onMouseUpOutside(x, y)
    if not self.dragging then
        return false
    end

    self.dragging = false
    self:setCapture(false)

    return true
end

function ReUISlider:setTrackColor(r, g, b, a)
    self.trackColor = {
        r = r or 0,
        g = g or 0,
        b = b or 0,
        a = a or 1
    }

    return self
end

function ReUISlider:setFillColor(r, g, b, a)
    self.fillColor = {
        r = r or 0,
        g = g or 0,
        b = b or 0,
        a = a or 1
    }

    return self
end

function ReUISlider:setThumbColor(r, g, b, a)
    self.thumbColor = {
        r = r or 0,
        g = g or 0,
        b = b or 0,
        a = a or 1
    }

    return self
end

function ReUISlider:render()
    ISPanel.render(self)

    local trackX, trackY, trackWidth, trackHeight =
        self:getTrackBounds()

    local normalized = self:getNormalizedValue()
    local fillWidth = trackWidth * normalized

    local trackColor = self.trackColor
    local fillColor = self.fillColor
    local thumbColor = self.thumbColor

    if not self.enabled then
        trackColor = self.disabledColor
        fillColor = self.disabledColor
        thumbColor = self.disabledColor
    elseif self.hovered or self.dragging then
        thumbColor = self.thumbHoverColor
    end

    self:drawRect(
        trackX,
        trackY,
        trackWidth,
        trackHeight,
        trackColor.a,
        trackColor.r,
        trackColor.g,
        trackColor.b
    )

    if fillWidth > 0 then
        self:drawRect(
            trackX,
            trackY,
            fillWidth,
            trackHeight,
            fillColor.a,
            fillColor.r,
            fillColor.g,
            fillColor.b
        )
    end

    local thumbX, thumbY, thumbWidth, thumbHeight =
        self:getThumbBounds()

    self:drawRect(
        thumbX,
        thumbY,
        thumbWidth,
        thumbHeight,
        thumbColor.a,
        thumbColor.r,
        thumbColor.g,
        thumbColor.b
    )

    if self.showValue then
        local valueText =
            self.valuePrefix
            .. tostring(self.value)
            .. self.valueSuffix

        self:drawText(
            valueText,
            self.width - 60,
            math.floor((self.height - 14) / 2),
            self.textColor.r,
            self.textColor.g,
            self.textColor.b,
            self.textColor.a,
            UIFont.Small
        )
    end
end