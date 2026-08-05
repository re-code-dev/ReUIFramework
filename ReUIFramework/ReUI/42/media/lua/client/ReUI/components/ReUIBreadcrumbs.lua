require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A single-line path of clickable crumbs ("Home > Inventory > Weapons").
-- The last crumb is always non-interactive (current location).
ReUIBreadcrumbs = ISPanel:derive("ReUIBreadcrumbs")

local SEPARATOR = "  >  "

function ReUIBreadcrumbs:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 300, height or 24)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.crumbs = options.crumbs or {}
    o.target = options.target
    o.onSelect = options.onSelect
    o.hoverIndex = nil
    o.crumbRects = {}

    ReUIComponent.apply(o, options)
    return o
end

function ReUIBreadcrumbs:setCrumbs(crumbs)
    self.crumbs = crumbs or {}
    return self
end

function ReUIBreadcrumbs:computeRects()
    self.crumbRects = {}
    local x = 0
    for i, crumb in ipairs(self.crumbs) do
        local label = tostring(crumb)
        local width = getTextManager():MeasureStringX(UIFont.Small, label)
        table.insert(self.crumbRects, { x = x, width = width, index = i })
        x = x + width
        if i < #self.crumbs then
            x = x + getTextManager():MeasureStringX(UIFont.Small, SEPARATOR)
        end
    end
end

function ReUIBreadcrumbs:crumbAt(mouseX)
    for _, rect in ipairs(self.crumbRects) do
        if mouseX >= rect.x and mouseX <= rect.x + rect.width then
            return rect.index
        end
    end
    return nil
end

function ReUIBreadcrumbs:onMouseMove(dx, dy)
    self:computeRects()
    self.hoverIndex = self:crumbAt(self:getMouseX())
end

function ReUIBreadcrumbs:onMouseMoveOutside(dx, dy)
    self.hoverIndex = nil
end

function ReUIBreadcrumbs:onMouseDown(x, y)
    self:computeRects()
    local index = self:crumbAt(x)
    if index and index < #self.crumbs then
        if self.emit then self:emit("select", self.crumbs[index], index) end
        if self.onSelect then
            if self.target then self.onSelect(self.target, self.crumbs[index], index)
            else self.onSelect(self.crumbs[index], index) end
        end
        return true
    end
    return ISPanel.onMouseDown(self, x, y)
end

function ReUIBreadcrumbs:prerender()
    self:computeRects()
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")
    local primary = ReUITheme.color("primary")

    for _, rect in ipairs(self.crumbRects) do
        local isLast = rect.index == #self.crumbs
        local color = isLast and text or (rect.index == self.hoverIndex and primary or muted)
        self:drawText(tostring(self.crumbs[rect.index]), rect.x, ReUITheme.textY(UIFont.Small, 0, self.height),
            color.r, color.g, color.b, color.a, UIFont.Small)
        if not isLast then
            self:drawText(SEPARATOR, rect.x + rect.width, ReUITheme.textY(UIFont.Small, 0, self.height),
                muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        end
    end
end
