require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- An 8-dot ring spinner (PZ's 2D draw API has no rotated-texture primitive
-- readily available here, so the "spin" is simulated by cycling each dot's
-- brightness around the ring rather than rotating a single graphic).
ReUILoadingSpinner = ISPanel:derive("ReUILoadingSpinner")

local DOT_COUNT = 8

function ReUILoadingSpinner:new(x, y, size, options)
    local o = ISPanel.new(self, x or 0, y or 0, size or 32, size or 32)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.colorRole = options.colorRole or "primary"
    o.cycleMs = options.cycleMs or 900
    o.startedAt = getTimestampMs and getTimestampMs() or 0

    ReUIComponent.apply(o, options)
    return o
end

local function now() return getTimestampMs and getTimestampMs() or 0 end

function ReUILoadingSpinner:prerender()
    local color = ReUITheme.color(self.colorRole)
    local radius = self.width / 2
    local dotRadius = math.max(2, radius * 0.16)
    local cx, cy = radius, radius
    local orbit = radius - dotRadius - 1

    local elapsed = now() - self.startedAt
    local headIndex = math.floor((elapsed / self.cycleMs) * DOT_COUNT) % DOT_COUNT

    for i = 0, DOT_COUNT - 1 do
        local angle = (i / DOT_COUNT) * 2 * math.pi - (math.pi / 2)
        local dx = cx + math.cos(angle) * orbit - dotRadius
        local dy = cy + math.sin(angle) * orbit - dotRadius

        -- Fade trailing the "head" dot around the ring.
        local distanceBack = (headIndex - i) % DOT_COUNT
        local alpha = 1 - (distanceBack / DOT_COUNT)
        alpha = math.max(0.15, alpha)

        self:drawRect(dx, dy, dotRadius * 2, dotRadius * 2, color.a * alpha, color.r, color.g, color.b)
    end
end
