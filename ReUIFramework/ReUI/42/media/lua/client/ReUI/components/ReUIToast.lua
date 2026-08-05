require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"
require "ReUI/components/ReUIProgressBar"

-- A single stacked notification. Variants: "success"/"warning"/"danger"/
-- "info"/"primary". `duration` (ms) auto-closes; nil/false makes it
-- manual-close only (loading/progress toasts typically pass nil and call
-- :close() themselves, or :setProgress() to drive a ReUIProgressBar).
ReUIToast = ISPanel:derive("ReUIToast")

local ICONS = {
    success = "✓", warning = "!", danger = "×", info = "i", primary = "•"
}

function ReUIToast:new(options)
    options = options or {}
    local width = options.width or 320
    local height = options.height or (options.showProgress and 72 or 56)
    local o = ISPanel.new(self, 0, 0, width, height)
    setmetatable(o, self)
    self.__index = self

    o.message = options.message or ""
    o.role = options.role or "primary"
    o.duration = options.duration
    o.showProgress = options.showProgress == true
    o.createdAt = getTimestampMs and getTimestampMs() or 0
    o.closed = false
    o.onClose = options.onClose

    ReUIComponent.apply(o, options)
    return o
end

function ReUIToast:initialise()
    ISPanel.initialise(self)
end

function ReUIToast:createChildren()
    ISPanel.createChildren(self)
    if self.showProgress then
        self.progressBar = ReUIProgressBar:new(14, self.height - 24, self.width - 28, 10, {
            value = 0, fillRole = self.role
        })
        self.progressBar:initialise()
        self.progressBar:instantiate()
        self:addChild(self.progressBar)
    end
end

function ReUIToast:setProgress(value)
    if self.progressBar then self.progressBar:setValue(value) end
end

function ReUIToast:close()
    if self.closed then return end
    self.closed = true
    if self.onClose then self.onClose(self) end
    if ReUIToastManager then ReUIToastManager:remove(self) end
end

local function contains(rect, x, y)
    return x >= rect.x and y >= rect.y and x <= rect.x + rect.width and y <= rect.y + rect.height
end

function ReUIToast:getCloseRect()
    return { x = self.width - 26, y = 8, width = 18, height = 18 }
end

function ReUIToast:onMouseDown(x, y)
    if contains(self:getCloseRect(), x, y) then
        self:close()
        return true
    end
    return ISPanel.onMouseDown(self, x, y)
end

function ReUIToast:prerender()
    local surface = ReUITheme.color("surfaceRaised")
    local border = ReUITheme.color("border")
    local accent = ReUITheme.color(self.role)
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")

    self:drawRect(0, 0, self.width, self.height, surface.a, surface.r, surface.g, surface.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)
    self:drawRect(0, 0, 4, self.height, accent.a, accent.r, accent.g, accent.b)

    self:drawText(ICONS[self.role] or "•", 16, 14, accent.r, accent.g, accent.b, accent.a, UIFont.Medium)
    self:drawText(self.message, 40, 16, text.r, text.g, text.b, text.a, UIFont.Small)

    local closeRect = self:getCloseRect()
    self:drawText("×", closeRect.x + 4, closeRect.y - 2, muted.r, muted.g, muted.b, muted.a, UIFont.Medium)

    if self.duration and not self.closed then
        local now = getTimestampMs and getTimestampMs() or 0
        if now - self.createdAt >= self.duration then
            self:close()
        end
    end
end
