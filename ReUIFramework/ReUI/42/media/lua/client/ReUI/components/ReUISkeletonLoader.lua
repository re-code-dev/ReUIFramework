require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A placeholder block that pulses opacity while content is loading.
-- `variant`: "text" (thin, rounded-in-spirit bar) | "block" (any rect,
-- e.g. an avatar or image placeholder).
ReUISkeletonLoader = ISPanel:derive("ReUISkeletonLoader")

function ReUISkeletonLoader:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 160, height or 16)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.variant = options.variant or "text"
    o.pulseSpeed = options.pulseSpeed or 900
    o.startedAt = getTimestampMs and getTimestampMs() or 0

    ReUIComponent.apply(o, options)
    return o
end

local function now() return getTimestampMs and getTimestampMs() or 0 end

function ReUISkeletonLoader:prerender()
    local elapsed = now() - self.startedAt
    local phase = (elapsed % self.pulseSpeed) / self.pulseSpeed
    -- Triangle wave 0..1..0 for a smooth pulse instead of a hard reset.
    local pulse = phase < 0.5 and (phase * 2) or (2 - phase * 2)
    local alpha = 0.35 + pulse * 0.25

    local base = ReUITheme.color("surfaceAlt")
    self:drawRect(0, 0, self.width, self.height, alpha, base.r, base.g, base.b)
end
