require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A simple vertical bar chart: one bar per data point, auto-scaled to the
-- tallest value, optional value/label text. This is the "Charts" checklist
-- item scoped down to what's actually renderable with this engine's 2D
-- draw primitives (rects + text) - no line/area/pie charts yet.
ReUIBarChart = ISPanel:derive("ReUIBarChart")

function ReUIBarChart:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 300, height or 180)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.data = options.data or {}         -- {label, value, colorRole}[]
    o.showValues = options.showValues ~= false
    o.barGap = options.barGap or 10
    o.maxValue = options.maxValue

    ReUIComponent.apply(o, options)
    return o
end

function ReUIBarChart:setData(data)
    self.data = data or {}
    return self
end

function ReUIBarChart:prerender()
    if #self.data == 0 then return end

    local maxValue = self.maxValue
    if not maxValue then
        maxValue = 0
        for _, point in ipairs(self.data) do maxValue = math.max(maxValue, point.value or 0) end
        maxValue = maxValue > 0 and maxValue or 1
    end

    local labelHeight = 18
    local valueHeight = self.showValues and 16 or 0
    local chartHeight = self.height - labelHeight - valueHeight
    local barWidth = (self.width - self.barGap * (#self.data - 1)) / #self.data
    local text, muted, border = ReUITheme.color("text"), ReUITheme.color("textMuted"), ReUITheme.color("border")

    self:drawRect(0, chartHeight, self.width, 1, border.a, border.r, border.g, border.b)

    local x = 0
    for _, point in ipairs(self.data) do
        local value = point.value or 0
        local barHeight = math.max(1, (value / maxValue) * (chartHeight - valueHeight - 4))
        local color = ReUITheme.color(point.colorRole or "primary")
        local barY = chartHeight - barHeight

        self:drawRect(x, barY, barWidth, barHeight, color.a, color.r, color.g, color.b)

        if self.showValues then
            local valueLabel = tostring(value)
            local vw = getTextManager():MeasureStringX(UIFont.Small, valueLabel)
            self:drawText(valueLabel, x + (barWidth - vw) / 2, barY - valueHeight,
                text.r, text.g, text.b, text.a, UIFont.Small)
        end

        local labelWidth = getTextManager():MeasureStringX(UIFont.Small, point.label or "")
        self:drawText(point.label or "", x + (barWidth - labelWidth) / 2, chartHeight + 4,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)

        x = x + barWidth + self.barGap
    end
end
