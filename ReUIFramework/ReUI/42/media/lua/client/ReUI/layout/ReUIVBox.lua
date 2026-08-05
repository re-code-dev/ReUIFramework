require "ReUI/layout/ReUIContainer"

ReUIVBox = ReUIContainer:derive("ReUIVBox")

function ReUIVBox:new(x, y, width, height, options)
    local o = ReUIContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self
    return o
end

function ReUIVBox:layoutNow()
    local visible = {}
    local fixedHeight = 0
    local totalGrow = 0

    for _, child in ipairs(self.layoutChildren) do
        if self:isChildInLayout(child) then
            table.insert(visible, child)
            local layout = child.layout or {}
            local grow = layout.grow or 0
            if grow > 0 then
                totalGrow = totalGrow + grow
            else
                fixedHeight = fixedHeight + (layout.height or child:getHeight())
            end
        end
    end

    local count = #visible
    local innerWidth = math.max(0, self.width - self.padding.left - self.padding.right)
    local innerHeight = math.max(0, self.height - self.padding.top - self.padding.bottom)
    local spacingTotal = math.max(0, count - 1) * self.spacing
    local remaining = math.max(0, innerHeight - fixedHeight - spacingTotal)
    local y = self.padding.top

    for _, child in ipairs(visible) do
        local layout = child.layout or {}
        local margin = ReUITheme.normalizeBox(layout.margin or 0)
        local grow = layout.grow or 0
        local height = layout.height or child:getHeight()

        if grow > 0 and totalGrow > 0 then
            height = remaining * (grow / totalGrow)
        end

        local width = layout.width or child:getWidth()
        local align = layout.alignSelf or self.align

        if align == "stretch" then
            width = math.max(0, innerWidth - margin.left - margin.right)
            child:setX(self.padding.left + margin.left)
        elseif align == "center" then
            child:setX(self.padding.left + (innerWidth - width) / 2)
        elseif align == "end" then
            child:setX(self.width - self.padding.right - width - margin.right)
        else
            child:setX(self.padding.left + margin.left)
        end

        child:setY(y + margin.top)
        child:setWidth(width)
        child:setHeight(math.max(0, height - margin.top - margin.bottom))
        y = y + height + self.spacing
    end

    self.layoutDirty = false
end
