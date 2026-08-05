require "ReUI/components/ReUIToggleBase"

ReUISwitch = ReUIToggleBase:derive("ReUISwitch")

function ReUISwitch:new(x, y, width, height, text, options)
    options = options or {}
    local o = ReUIToggleBase.new(self, x, y, width, height, text, options)
    setmetatable(o, self)
    self.__index = self

    o.trackWidth = options.trackWidth or 44
    o.trackHeight = options.trackHeight or 24
    o.knobSize = options.knobSize or 18
    o.gap = options.gap or ReUITheme.spacing.md
    o.labelPosition = options.labelPosition or "left"
    return o
end

function ReUISwitch:getTrackX()
    if self.labelPosition == "right" then
        return 0
    end
    return self.width - self.trackWidth
end

function ReUISwitch:prerender()
    local trackX = self:getTrackX()
    local trackY = math.floor((self.height - self.trackHeight) / 2)
    local trackRole = self.value and "primary" or "surfaceAlt"
    local borderRole = self.value and "primary" or "borderStrong"

    if self.mouseOver and self.enable and not self.value then
        trackRole = "surfaceRaised"
    end

    if not self.enable then
        trackRole = "surface"
        borderRole = "border"
    end

    local track = ReUITheme.color(trackRole)
    local border = ReUITheme.color(borderRole)
    local knob = ReUITheme.color(self.enable and "text" or "textDisabled")
    local text = ReUITheme.color(self.enable and self.textRole or self.disabledTextRole)

    self:drawRect(trackX, trackY, self.trackWidth, self.trackHeight,
        track.a, track.r, track.g, track.b)
    self:drawRectBorder(trackX, trackY, self.trackWidth, self.trackHeight,
        border.a, border.r, border.g, border.b)

    local knobY = trackY + math.floor((self.trackHeight - self.knobSize) / 2)
    local knobX = trackX + 3
    if self.value then
        knobX = trackX + self.trackWidth - self.knobSize - 3
    end

    self:drawRect(knobX, knobY, self.knobSize, self.knobSize,
        knob.a, knob.r, knob.g, knob.b)

    if self.focused and self.enable then
        local focus = ReUITheme.color("primary")
        self:drawRectBorder(trackX - 2, trackY - 2, self.trackWidth + 4, self.trackHeight + 4,
            focus.a, focus.r, focus.g, focus.b)
    end

    if self.labelPosition == "right" then
        ReUITheme.drawTextCenteredY(self, self.text,
            self.trackWidth + self.gap, 0, self.height, self.font, text)
    else
        ReUITheme.drawTextCenteredY(self, self.text,
            0, 0, self.height, self.font, text)
    end
end
