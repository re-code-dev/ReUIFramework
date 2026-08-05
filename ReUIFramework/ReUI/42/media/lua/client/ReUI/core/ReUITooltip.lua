require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"

-- Delayed hover tooltip, shared across the whole framework (like
-- ReUIFocusManager). Deliberately NOT wired into ReUIComponent.apply: many
-- controls (Button, Slider, TextBox, Window, ScrollContainer, ...) already
-- override :onMouseMove/:onMouseMoveOutside on their class, and an
-- instance-level closure added by ReUIComponent.apply would shadow those
-- (Lua instance fields win over metatable/class lookups) and silently break
-- hover/drag behavior everywhere. Instead, opt in per control: call
-- ReUITooltip.update(text, screenX, screenY) from :onMouseMove and
-- ReUITooltip.cancel() from :onMouseMoveOutside — see ReUIButton for the
-- two-line pattern.
ReUITooltip = ReUITooltip or {
    panel = nil,
    delayMs = 400,
    hoverStart = nil,
    pendingText = nil
}

local TooltipPanel = ISPanel:derive("ReUITooltipPanel")

function TooltipPanel:new(text)
    local o = ISPanel.new(self, 0, 0, 10, 10)
    setmetatable(o, self)
    self.__index = self
    o:noBackground()
    o.text = text
    o.padding = 8
    return o
end

function TooltipPanel:setText(text)
    self.text = text
end

function TooltipPanel:prerender()
    local bg = ReUITheme.color("surfaceRaised")
    local border = ReUITheme.color("border")
    local text = ReUITheme.color("text")

    local textWidth = getTextManager():MeasureStringX(UIFont.Small, self.text)
    local textHeight = getTextManager():getFontHeight(UIFont.Small)
    self:setWidth(textWidth + self.padding * 2)
    self:setHeight(textHeight + self.padding * 2)

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)
    self:drawText(self.text, self.padding, self.padding, text.r, text.g, text.b, text.a, UIFont.Small)
end

local function now()
    return getTimestampMs and getTimestampMs() or 0
end

function ReUITooltip.show(text, x, y)
    if not ReUITooltip.panel then
        ReUITooltip.panel = TooltipPanel:new(text)
        ReUITooltip.panel:initialise()
        ReUITooltip.panel:instantiate()
    else
        ReUITooltip.panel:setText(text)
    end

    ReUITooltip.panel:setX(x)
    ReUITooltip.panel:setY(y)

    if not ReUITooltip.panel:isReallyVisible() then
        ReUITooltip.panel:addToUIManager()
        ReUITooltip.panel:bringToTop()
    end
end

-- Hides immediately and forgets the pending hover — call when the mouse
-- leaves the hovering control.
function ReUITooltip.cancel()
    if ReUITooltip.panel and ReUITooltip.panel:isReallyVisible() then
        ReUITooltip.panel:removeFromUIManager()
    end
    ReUITooltip.pendingText = nil
    ReUITooltip.hoverStart = nil
end

-- Call every frame from a hovered control's :onMouseMove with the tooltip
-- text and the current absolute screen mouse position
-- (self:getAbsoluteX() + self:getMouseX(), likewise for Y). Shows after
-- ReUITooltip.delayMs of continuous hover over the same text.
function ReUITooltip.update(text, screenX, screenY)
    if not text or text == "" then
        ReUITooltip.cancel()
        return
    end

    if ReUITooltip.pendingText ~= text then
        ReUITooltip.pendingText = text
        ReUITooltip.hoverStart = now()
        if ReUITooltip.panel and ReUITooltip.panel:isReallyVisible() then
            ReUITooltip.panel:removeFromUIManager()
        end
    end

    if now() - ReUITooltip.hoverStart >= ReUITooltip.delayMs then
        ReUITooltip.show(text, screenX + 14, screenY + 18)
    end
end
