require "ReUI/components/ReUIPropertyGrid"
require "ReUI/core/ReUITheme"

-- A live, editable property sheet for any ReUIComponent/ISUIElement
-- instance: geometry, visibility and enabled state, read and written back
-- through whichever accessor (ReUIComponent's or the raw ISUIElement's) the
-- target actually exposes.
ReUIInspector = ReUIPropertyGrid:derive("ReUIInspector")

function ReUIInspector:new(x, y, width, height, options)
    local o = ReUIPropertyGrid.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.inspectedTarget = nil
    return o
end

function ReUIInspector:inspect(target)
    self.inspectedTarget = target
    self:clear()
    if not target then return self end

    self:addProperty("x", "X", "number", target.getX and target:getX() or (target.x or 0), { step = 1 })
    self:addProperty("y", "Y", "number", target.getY and target:getY() or (target.y or 0), { step = 1 })
    self:addProperty("width", "Width", "number", target.getWidth and target:getWidth() or (target.width or 0),
        { min = 0, step = 1 })
    self:addProperty("height", "Height", "number", target.getHeight and target:getHeight() or (target.height or 0),
        { min = 0, step = 1 })

    local visible = true
    if target.isReUIVisible then visible = target:isReUIVisible()
    elseif target.isVisible then visible = target:isVisible() end
    self:addProperty("visible", "Visible", "checkbox", visible ~= false)

    local enabled = true
    if target.isReUIEnabled then enabled = target:isReUIEnabled()
    elseif target.isEnabled then enabled = target:isEnabled() end
    self:addProperty("enabled", "Enabled", "checkbox", enabled ~= false)

    return self
end

function ReUIInspector:onPropertyChanged(key, value)
    ReUIPropertyGrid.onPropertyChanged(self, key, value)

    local target = self.inspectedTarget
    if not target then return end

    if key == "x" and target.setX then
        target:setX(value)
    elseif key == "y" and target.setY then
        target:setY(value)
    elseif key == "width" and target.setWidth then
        target:setWidth(value)
    elseif key == "height" and target.setHeight then
        target:setHeight(value)
    elseif key == "visible" then
        if target.setReUIVisible then target:setReUIVisible(value)
        elseif target.setVisible then target:setVisible(value) end
    elseif key == "enabled" then
        if target.setReUIEnabled then target:setReUIEnabled(value)
        elseif target.setEnabled then target:setEnabled(value) end
    end
end
