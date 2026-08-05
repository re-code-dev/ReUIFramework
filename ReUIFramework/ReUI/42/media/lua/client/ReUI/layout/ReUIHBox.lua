require "ReUI/layout/ReUIContainer"

ReUIHBox = ReUIContainer:derive("ReUIHBox")

function ReUIHBox:new(x, y, width, height, options)
    local o = ReUIContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self
    return o
end

function ReUIHBox:layoutNow()
    local visible = {}
    local fixedWidth = 0
    local totalGrow = 0

    for _, child in ipairs(self.layoutChildren) do
        if self:isChildInLayout(child) then
            table.insert(visible, child)
            local layout = child.layout or {}
            local grow = layout.grow or 0
            if grow > 0 then
                totalGrow = totalGrow + grow
            else
                fixedWidth = fixedWidth + (layout.width or child:getWidth())
            end
        end
    end

    local count = #visible
    local innerWidth = math.max(0, self.width - self.padding.left - self.padding.right)
    local innerHeight = math.max(0, self.height - self.padding.top - self.padding.bottom)
    local spacingTotal = math.max(0, count - 1) * self.spacing
    local remaining = math.max(0, innerWidth - fixedWidth - spacingTotal)
    local x = self.padding.left

    for _, child in ipairs(visible) do
        local layout = child.layout or {}
        local margin = ReUITheme.normalizeBox(layout.margin or 0)
        local grow = layout.grow or 0
        local width = layout.width or child:getWidth()

        if grow > 0 and totalGrow > 0 then
            width = remaining * (grow / totalGrow)
        end

        local height = layout.height or child:getHeight()
        local align = layout.alignSelf or self.align

        if align == "stretch" then
            height = math.max(0, innerHeight - margin.top - margin.bottom)
            child:setY(self.padding.top + margin.top)
        elseif align == "center" then
            child:setY(self.padding.top + (innerHeight - height) / 2)
        elseif align == "end" then
            child:setY(self.height - self.padding.bottom - height - margin.bottom)
        else
            child:setY(self.padding.top + margin.top)
        end

        child:setX(x + margin.left)
        child:setWidth(math.max(0, width - margin.left - margin.right))
        child:setHeight(height)
        x = x + width + self.spacing
    end

    self.layoutDirty = false
end
