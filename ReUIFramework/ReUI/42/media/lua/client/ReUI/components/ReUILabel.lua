require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

ReUILabel = ISPanel:derive("ReUILabel")

function ReUILabel:new(x, y, width, height, text, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 120, height or 24)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.text = tostring(text or "")
    o.font = options.font or UIFont.Small
    o.colorRole = options.colorRole or "text"
    o.horizontalAlign = options.horizontalAlign or options.align or "left"
    o.verticalAlign = options.verticalAlign or "center"
    o.padding = ReUITheme.normalizeBox(options.padding or 0)
    o.ellipsis = options.ellipsis ~= false
    o.drawBackground = false
    o.drawBorder = false

    ReUIComponent.apply(o, options)
    return o
end

function ReUILabel:setText(text)
    self.text = tostring(text or "")
    self:emit("textChanged", self.text)
    return self
end

function ReUILabel:getText()
    return self.text
end

function ReUILabel:setFont(font)
    self.font = font or UIFont.Small
    return self
end

function ReUILabel:setColorRole(role)
    self.colorRole = role or "text"
    return self
end

function ReUILabel:setHorizontalAlignment(alignment)
    self.horizontalAlign = alignment or "left"
    return self
end

function ReUILabel:setVerticalAlignment(alignment)
    self.verticalAlign = alignment or "center"
    return self
end

function ReUILabel:getAvailableWidth()
    return math.max(0, self.width - self.padding.left - self.padding.right)
end

function ReUILabel:getDisplayText()
    local value = self.text or ""
    if not self.ellipsis then
        return value
    end

    local available = self:getAvailableWidth()
    if available <= 0 then
        return ""
    end

    local manager = getTextManager()
    if manager:MeasureStringX(self.font, value) <= available then
        return value
    end

    local suffix = "..."
    local suffixWidth = manager:MeasureStringX(self.font, suffix)
    if suffixWidth >= available then
        return suffix
    end

    local low, high, best = 0, string.len(value), ""
    while low <= high do
        local middle = math.floor((low + high) / 2)
        local candidate = string.sub(value, 1, middle)
        if manager:MeasureStringX(self.font, candidate) + suffixWidth <= available then
            best = candidate
            low = middle + 1
        else
            high = middle - 1
        end
    end

    return best .. suffix
end

function ReUILabel:prerender()
    local color = ReUITheme.color(self.colorRole)
    local displayText = self:getDisplayText()
    local manager = getTextManager()
    local textWidth = manager:MeasureStringX(self.font, displayText)
    local textHeight = manager:getFontHeight(self.font)

    local x = self.padding.left
    if self.horizontalAlign == "center" then
        x = math.floor((self.width - textWidth) / 2)
    elseif self.horizontalAlign == "right" then
        x = self.width - self.padding.right - textWidth
    end

    local y = self.padding.top
    if self.verticalAlign == "center" then
        y = math.floor((self.height - textHeight) / 2)
    elseif self.verticalAlign == "bottom" then
        y = self.height - self.padding.bottom - textHeight
    end

    self:drawText(displayText, x, y,
        color.r, color.g, color.b, color.a, self.font)
end

function ReUILabel:render()
end
