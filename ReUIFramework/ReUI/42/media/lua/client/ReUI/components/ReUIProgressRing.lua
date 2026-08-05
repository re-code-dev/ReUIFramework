require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A circular progress indicator built from small segment blocks arranged
-- on a ring (same trigonometry approach as ReUILoadingSpinner - no
-- rotated-texture/arc-fill primitive available here). Segments up to
-- `progress` are drawn in `fillRole`, the rest in a muted track color.
-- Static (not animated) - pair with ReUIAnimation.to() on :setValue() for
-- an animated fill if needed.
ReUIProgressRing = ISPanel:derive("ReUIProgressRing")

local SEGMENT_COUNT = 32

function ReUIProgressRing:new(x, y, size, options)
    local o = ISPanel.new(self, x or 0, y or 0, size or 64, size or 64)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.minimum = tonumber(options.minimum) or 0
    o.maximum = tonumber(options.maximum) or 100
    o.value = tonumber(options.value) or o.minimum
    o.fillRole = options.fillRole or "primary"
    o.showLabel = options.showLabel ~= false
    o.thickness = options.thickness or 4

    ReUIComponent.apply(o, options)
    return o
end

function ReUIProgressRing:setValue(value)
    self.value = math.max(self.minimum, math.min(self.maximum, value))
    return self
end

function ReUIProgressRing:getProgress()
    local span = self.maximum - self.minimum
    if span <= 0 then return 0 end
    return (self.value - self.minimum) / span
end

function ReUIProgressRing:prerender()
    local fill = ReUITheme.color(self.fillRole)
    local track = ReUITheme.color("surfaceAlt")
    local text = ReUITheme.color("text")

    local radius = self.width / 2
    local segSize = math.max(2, self.thickness)
    local orbit = radius - segSize
    local cx, cy = radius, radius
    local progress = self:getProgress()
    local litSegments = math.floor(progress * SEGMENT_COUNT + 0.5)

    for i = 0, SEGMENT_COUNT - 1 do
        local angle = (i / SEGMENT_COUNT) * 2 * math.pi - (math.pi / 2)
        local dx = cx + math.cos(angle) * orbit - segSize / 2
        local dy = cy + math.sin(angle) * orbit - segSize / 2
        local color = i < litSegments and fill or track
        self:drawRect(dx, dy, segSize, segSize, color.a, color.r, color.g, color.b)
    end

    if self.showLabel then
        local label = tostring(math.floor(progress * 100 + 0.5)) .. "%"
        local labelWidth = getTextManager():MeasureStringX(UIFont.Small, label)
        self:drawText(label, cx - labelWidth / 2, ReUITheme.textY(UIFont.Small, 0, self.height),
            text.r, text.g, text.b, text.a, UIFont.Small)
    end
end
