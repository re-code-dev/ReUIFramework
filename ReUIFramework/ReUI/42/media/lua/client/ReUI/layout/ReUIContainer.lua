require "ReUI/components/ReUIPanel"
require "ReUI/core/ReUITheme"

ReUIContainer = ReUIPanel:derive("ReUIContainer")

function ReUIContainer:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIPanel.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.padding = ReUITheme.normalizeBox(options.padding or 0)
    o.spacing = ReUITheme.getSpacing(options.spacing or 0)
    o.align = options.align or "start"
    o.layoutChildren = {}
    o.layoutDirty = true
    return o
end

function ReUIContainer:add(component, layout)
    if not component then return nil end

    component.layout = layout or component.layout or {}
    component:initialise()
    component:instantiate()
    self:addChild(component)
    table.insert(self.layoutChildren, component)
    self:invalidateLayout()
    return component
end

function ReUIContainer:remove(component)
    if not component then return end

    self:removeChild(component)
    for i = #self.layoutChildren, 1, -1 do
        if self.layoutChildren[i] == component then
            table.remove(self.layoutChildren, i)
            break
        end
    end
    self:invalidateLayout()
end

function ReUIContainer:clear()
    for i = #self.layoutChildren, 1, -1 do
        local child = self.layoutChildren[i]
        self:removeChild(child)
        table.remove(self.layoutChildren, i)
    end
    self:invalidateLayout()
end

function ReUIContainer:getLayoutChildren()
    return self.layoutChildren
end

function ReUIContainer:setPadding(value)
    self.padding = ReUITheme.normalizeBox(value)
    self:invalidateLayout()
end

function ReUIContainer:setSpacing(value)
    self.spacing = ReUITheme.getSpacing(value)
    self:invalidateLayout()
end

function ReUIContainer:invalidateLayout()
    self.layoutDirty = true
end

function ReUIContainer:layoutNow()
    self.layoutDirty = false
end

function ReUIContainer:prerender()
    if self.layoutDirty then
        self:layoutNow()
    end
    ReUIPanel.prerender(self)
end

function ReUIContainer:isChildInLayout(child)
    return child and child:getIsVisible()
end
