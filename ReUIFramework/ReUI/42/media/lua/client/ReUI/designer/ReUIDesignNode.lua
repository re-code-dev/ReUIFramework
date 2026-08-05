require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"

-- A non-interactive, draggable/resizable design-time stand-in for a real
-- ReUI control. The Designer moves/resizes/selects these directly; the
-- actual live widget is only ever instantiated by the generated code
-- (see ReUIDesignerWindow:generateCode), never by the node itself.
ReUIDesignNode = ISPanel:derive("ReUIDesignNode")

local RESIZE_GRIP = 14

function ReUIDesignNode:new(x, y, width, height, nodeType, options)
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.nodeType = nodeType
    o.label = options.label or nodeType
    o.selected = false
    o.dragging = false
    o.resizing = false
    o.dragOffsetX = 0
    o.dragOffsetY = 0
    o.resizeStartX = 0
    o.resizeStartY = 0
    o.resizeStartWidth = width
    o.resizeStartHeight = height
    o.onSelected = options.onSelected
    o.designerTarget = options.target

    return o
end

function ReUIDesignNode:setSelected(selected)
    self.selected = selected == true
end

function ReUIDesignNode:onMouseDown(x, y)
    if self.onSelected then
        if self.designerTarget then
            self.onSelected(self.designerTarget, self)
        else
            self.onSelected(self)
        end
    end

    if x >= self.width - RESIZE_GRIP and y >= self.height - RESIZE_GRIP then
        self.resizing = true
        self.resizeStartX = x
        self.resizeStartY = y
        self.resizeStartWidth = self.width
        self.resizeStartHeight = self.height
        return true
    end

    self.dragging = true
    self.dragOffsetX = x
    self.dragOffsetY = y
    return true
end

function ReUIDesignNode:onMouseMove(dx, dy)
    if self.resizing then
        local mouseX = self:getMouseX()
        local mouseY = self:getMouseY()
        self:setWidth(math.max(24, self.resizeStartWidth + mouseX - self.resizeStartX))
        self:setHeight(math.max(24, self.resizeStartHeight + mouseY - self.resizeStartY))
        return true
    end

    if self.dragging then
        self:setX(self:getMouseX() + self:getX() - self.dragOffsetX)
        self:setY(self:getMouseY() + self:getY() - self.dragOffsetY)
        return true
    end

    return false
end

function ReUIDesignNode:onMouseUp(x, y)
    self.dragging = false
    self.resizing = false
    return true
end

function ReUIDesignNode:onMouseUpOutside(x, y)
    self.dragging = false
    self.resizing = false
end

function ReUIDesignNode:prerender()
    local bg = ReUITheme.color("surfaceAlt")
    local border = self.selected and ReUITheme.color("primary") or ReUITheme.color("border")
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)
    self:drawText("[" .. self.nodeType .. "] " .. self.label, 6, 4, text.r, text.g, text.b, text.a, UIFont.Small)

    self:drawRect(self.width - RESIZE_GRIP, self.height - 2, RESIZE_GRIP, 2, 0.6, muted.r, muted.g, muted.b)
    self:drawRect(self.width - 2, self.height - RESIZE_GRIP, 2, RESIZE_GRIP, 0.6, muted.r, muted.g, muted.b)
end
