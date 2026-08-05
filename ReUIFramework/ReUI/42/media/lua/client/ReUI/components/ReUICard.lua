require "ReUI/components/ReUIPanel"
require "ReUI/core/ReUITheme"

ReUICard = ReUIPanel:derive("ReUICard")

function ReUICard:new(x, y, width, height, options)
    options = options or {}
    options.backgroundRole = options.backgroundRole or "surfaceAlt"
    options.borderRole = options.borderRole or "border"

    local o = ReUIPanel.new(self, x or 0, y or 0, width or 260, height or 180, options)
    setmetatable(o, self)
    self.__index = self

    o.title = options.title
    o.subtitle = options.subtitle
    o.footerText = options.footerText
    o.titleFont = options.titleFont or UIFont.Medium
    o.bodyFont = options.bodyFont or UIFont.Small
    o.headerHeight = options.headerHeight or 58
    o.footerHeight = options.footerText and (options.footerHeight or 40) or 0
    o.contentPadding = ReUITheme.normalizeBox(options.contentPadding or "lg")
    o.accentRole = options.accentRole
    o.accentWidth = options.accentWidth or 3
    o.showHeaderDivider = options.showHeaderDivider ~= false
    o.showFooterDivider = options.showFooterDivider ~= false

    return o
end

function ReUICard:setTitle(title)
    self.title = title
    return self
end

function ReUICard:setSubtitle(subtitle)
    self.subtitle = subtitle
    return self
end

function ReUICard:setFooterText(text)
    self.footerText = text
    self.footerHeight = text and math.max(self.footerHeight, 40) or 0
    return self
end

function ReUICard:getContentBounds()
    local top = self.headerHeight + self.contentPadding.top
    local bottom = self.height - self.footerHeight - self.contentPadding.bottom
    return {
        x = self.contentPadding.left,
        y = top,
        width = math.max(0, self.width - self.contentPadding.left - self.contentPadding.right),
        height = math.max(0, bottom - top)
    }
end

function ReUICard:prerender()
    ReUIPanel.prerender(self)

    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")
    local border = ReUITheme.color(self.borderRole)

    if self.accentRole then
        local accent = ReUITheme.color(self.accentRole)
        self:drawRect(0, 0, self.accentWidth, self.height,
            accent.a, accent.r, accent.g, accent.b)
    end

    if self.title then
        self:drawText(self.title, self.contentPadding.left, 14,
            text.r, text.g, text.b, text.a, self.titleFont)
    end

    if self.subtitle then
        self:drawText(self.subtitle, self.contentPadding.left, 36,
            muted.r, muted.g, muted.b, muted.a, self.bodyFont)
    end

    if self.showHeaderDivider and self.headerHeight > 0 then
        self:drawRect(self.contentPadding.left, self.headerHeight,
            self.width - self.contentPadding.left - self.contentPadding.right, 1,
            border.a, border.r, border.g, border.b)
    end

    if self.footerHeight > 0 then
        local footerY = self.height - self.footerHeight
        if self.showFooterDivider then
            self:drawRect(self.contentPadding.left, footerY,
                self.width - self.contentPadding.left - self.contentPadding.right, 1,
                border.a, border.r, border.g, border.b)
        end
        if self.footerText then
            ReUITheme.drawTextCenteredY(self, self.footerText,
                self.contentPadding.left, footerY, self.footerHeight,
                self.bodyFont, muted)
        end
    end
end
