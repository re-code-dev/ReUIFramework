require "ISUI/ISButton"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"
require "ReUI/core/ReUITooltip"

ReUIButton = ISButton:derive("ReUIButton")

function ReUIButton:new(x, y, width, height, title, target, onclick)
    local o = ISButton.new(self, x, y, width, height, title, target, onclick)
    setmetatable(o, self)
    self.__index = self

    o.enable = true
    o.tooltip = nil
    o.font = UIFont.Small
    o.variant = "secondary"
    o.selected = false
    o.alignText = "center"
    o.textPadding = 12
    ReUIComponent.apply(o)
    return o
end

function ReUIButton:setTooltip(text)
    self.tooltip = text
    return self
end

function ReUIButton:onMouseMove(dx, dy)
    if self.tooltip then
        ReUITooltip.update(self.tooltip, self:getAbsoluteX() + self:getMouseX(), self:getAbsoluteY() + self:getMouseY())
    end
    if ISButton.onMouseMove then
        return ISButton.onMouseMove(self, dx, dy)
    end
end

function ReUIButton:onMouseMoveOutside(dx, dy)
    if self.tooltip then
        ReUITooltip.cancel()
    end
    if ISButton.onMouseMoveOutside then
        return ISButton.onMouseMoveOutside(self, dx, dy)
    end
end

function ReUIButton:setVariant(variant)
    self.variant = variant or "secondary"
    return self
end

function ReUIButton:setSelected(selected)
    self.selected = selected == true
    return self
end

function ReUIButton:setTextAlignment(alignment)
    self.alignText = alignment or "center"
    return self
end

function ReUIButton:getRoles()
    local bgRole = "surfaceAlt"
    local hoverRole = "surfaceRaised"
    local borderRole = "border"
    local textRole = "text"

    if self.variant == "primary" then
        bgRole = "primaryMuted"
        hoverRole = "primary"
        borderRole = "primary"
    elseif self.variant == "success" then
        bgRole = "success"
        hoverRole = "success"
        borderRole = "success"
    elseif self.variant == "warning" then
        bgRole = "warning"
        hoverRole = "warning"
        borderRole = "warning"
        textRole = "background"
    elseif self.variant == "danger" then
        bgRole = "danger"
        hoverRole = "danger"
        borderRole = "danger"
    elseif self.variant == "ghost" then
        bgRole = "surface"
        hoverRole = "surfaceAlt"
        borderRole = "surface"
    end

    if self.selected then
        bgRole = "primaryMuted"
        hoverRole = "primaryMuted"
        borderRole = "primary"
    end

    return bgRole, hoverRole, borderRole, textRole
end

function ReUIButton:prerender()
    local bgRole, hoverRole, borderRole, textRole = self:getRoles()
    local bg = ReUITheme.color(self.mouseOver and hoverRole or bgRole)
    local border = ReUITheme.color(borderRole)
    local text = ReUITheme.color(textRole)

    if not self.enable then
        bg = ReUITheme.color("surface")
        border = ReUITheme.color("border")
        text = ReUITheme.color("textDisabled")
    end

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height,
        border.a, border.r, border.g, border.b)

    if self.selected then
        local accent = ReUITheme.color("primary")
        self:drawRect(0, 0, 3, self.height, accent.a, accent.r, accent.g, accent.b)
    end

    local textWidth = getTextManager():MeasureStringX(self.font, self.title)
    local textX = (self.width - textWidth) / 2

    if self.alignText == "left" then
        textX = self.textPadding
    elseif self.alignText == "right" then
        textX = self.width - textWidth - self.textPadding
    end

    self:drawText(self.title, textX, ReUITheme.textY(self.font, 0, self.height),
        text.r, text.g, text.b, text.a, self.font)
end
-- ISButton also draws its title in render(). Re:UI owns the complete visual pass
-- in prerender(), so render intentionally remains empty.
function ReUIButton:render()
end
function ReUIButton:onMouseUp(x, y)
    if self.enable and self:isMouseOver() then
        self:emit("click", x, y)
    end
    return ISButton.onMouseUp(self, x, y)
end
