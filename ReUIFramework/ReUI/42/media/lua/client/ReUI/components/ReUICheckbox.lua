require "ReUI/components/ReUIToggleBase"

ReUICheckbox = ReUIToggleBase:derive("ReUICheckbox")

function ReUICheckbox:new(x, y, width, height, text, options)
    options = options or {}
    local o = ReUIToggleBase.new(self, x, y, width, height, text, options)
    setmetatable(o, self)
    self.__index = self

    o.boxSize = options.boxSize or 20
    o.gap = options.gap or ReUITheme.spacing.md
    o.checkThickness = options.checkThickness or 2
    return o
end

function ReUICheckbox:prerender()
    local boxY = math.floor((self.height - self.boxSize) / 2)
    local backgroundRole = self.value and "primaryMuted" or "surfaceAlt"
    local borderRole = self.value and "primary" or "borderStrong"

    if self.mouseOver and self.enable then
        backgroundRole = self.value and "primaryMuted" or "surfaceRaised"
    end

    if not self.enable then
        backgroundRole = "surface"
        borderRole = "border"
    end

    local background = ReUITheme.color(backgroundRole)
    local border = ReUITheme.color(borderRole)
    local text = ReUITheme.color(self.enable and self.textRole or self.disabledTextRole)

    self:drawRect(0, boxY, self.boxSize, self.boxSize,
        background.a, background.r, background.g, background.b)
    self:drawRectBorder(0, boxY, self.boxSize, self.boxSize,
        border.a, border.r, border.g, border.b)

    if self.value then
        local accent = ReUITheme.color(self.enable and "primary" or "textDisabled")
        local left = 5
        local middleX = 9
        local middleY = boxY + 14
        local topY = boxY + 6

        self:drawLine2(left, boxY + 10, middleX, middleY,
            accent.a, accent.r, accent.g, accent.b, self.checkThickness)
        self:drawLine2(middleX, middleY, self.boxSize - 4, topY,
            accent.a, accent.r, accent.g, accent.b, self.checkThickness)
    end

    if self.focused and self.enable then
        local focus = ReUITheme.color("primary")
        self:drawRectBorder(-2, boxY - 2, self.boxSize + 4, self.boxSize + 4,
            focus.a, focus.r, focus.g, focus.b)
    end

    local textX = self.boxSize + self.gap
    ReUITheme.drawTextCenteredY(self, self.text, textX, 0, self.height, self.font, text)
end
