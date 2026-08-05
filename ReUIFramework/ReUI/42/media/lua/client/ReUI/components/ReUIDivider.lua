require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

ReUIDivider = ISPanel:derive("ReUIDivider")

function ReUIDivider:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 120, height or 1)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.orientation = options.orientation or "horizontal"
    o.colorRole = options.colorRole or "border"
    o.thickness = options.thickness or 1
    o.label = options.label
    o.labelFont = options.labelFont or UIFont.Small
    o.labelColorRole = options.labelColorRole or "textMuted"
    o.labelGap = options.labelGap or ReUITheme.spacing.sm

    ReUIComponent.apply(o, options)
    return o
end

function ReUIDivider:setOrientation(orientation)
    self.orientation = orientation or "horizontal"
    return self
end

function ReUIDivider:setLabel(label)
    self.label = label
    return self
end

function ReUIDivider:setColorRole(role)
    self.colorRole = role or "border"
    return self
end

function ReUIDivider:prerender()
    local color = ReUITheme.color(self.colorRole)

    if self.orientation == "vertical" then
        local x = math.floor((self.width - self.thickness) / 2)
        self:drawRect(x, 0, self.thickness, self.height,
            color.a, color.r, color.g, color.b)
        return
    end

    local y = math.floor((self.height - self.thickness) / 2)

    if self.label and self.label ~= "" then
        local manager = getTextManager()
        local labelWidth = manager:MeasureStringX(self.labelFont, self.label)
        local labelColor = ReUITheme.color(self.labelColorRole)
        local labelX = math.floor((self.width - labelWidth) / 2)
        local leftWidth = math.max(0, labelX - self.labelGap)
        local rightX = labelX + labelWidth + self.labelGap

        self:drawRect(0, y, leftWidth, self.thickness,
            color.a, color.r, color.g, color.b)
        self:drawRect(rightX, y, math.max(0, self.width - rightX), self.thickness,
            color.a, color.r, color.g, color.b)
        self:drawText(self.label, labelX,
            math.floor((self.height - manager:getFontHeight(self.labelFont)) / 2),
            labelColor.r, labelColor.g, labelColor.b, labelColor.a, self.labelFont)
    else
        self:drawRect(0, y, self.width, self.thickness,
            color.a, color.r, color.g, color.b)
    end
end

function ReUIDivider:render()
end
