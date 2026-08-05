require "ReUI/components/ReUIPanel"
require "ReUI/core/ReUITheme"

-- A viewport that clips an arbitrarily tall content panel and lets the
-- player scroll it with the mouse wheel or a vertical scrollbar.
-- Children are added to :getContent() (typically a ReUIVBox), not to the
-- ReUIScrollContainer itself.
ReUIScrollContainer = ReUIPanel:derive("ReUIScrollContainer")

local SCROLLBAR_WIDTH = 10

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

function ReUIScrollContainer:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIPanel.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.scrollY = 0
    o.contentHeight = height
    o.scrollStep = tonumber(options.scrollStep) or 40
    o.showScrollbar = options.showScrollbar ~= false
    o.dragging = false
    o.dragStartY = 0
    o.dragStartScroll = 0

    return o
end

function ReUIScrollContainer:createChildren()
    ReUIPanel.createChildren(self)

    self.content = ReUIPanel:new(0, 0, self:getViewportWidth(), self.height, {
        drawBackground = false,
        drawBorder = false
    })
    self.content:initialise()
    self.content:instantiate()
    self:addChild(self.content)
end

function ReUIScrollContainer:getContent()
    return self.content
end

function ReUIScrollContainer:getViewportWidth()
    if self.showScrollbar then
        return math.max(0, self.width - SCROLLBAR_WIDTH - 2)
    end
    return self.width
end

-- Content height must be provided explicitly (e.g. after laying out a
-- ReUIVBox placed inside the content panel) since ReUIScrollContainer does
-- not run layout itself.
function ReUIScrollContainer:setContentHeight(height)
    self.contentHeight = math.max(0, tonumber(height) or 0)
    if self.content then
        self.content:setHeight(math.max(self.contentHeight, self.height))
        self.content:setWidth(self:getViewportWidth())
    end
    self:setScroll(self.scrollY)
    return self
end

function ReUIScrollContainer:getMaxScroll()
    return math.max(0, self.contentHeight - self.height)
end

function ReUIScrollContainer:setScroll(value)
    self.scrollY = clamp(value or 0, 0, self:getMaxScroll())
    if self.content then
        self.content:setY(-self.scrollY)
    end
    return self
end

function ReUIScrollContainer:scrollBy(delta)
    return self:setScroll(self.scrollY + delta)
end

function ReUIScrollContainer:getScrollbarBounds()
    local maxScroll = self:getMaxScroll()
    if maxScroll <= 0 then
        return nil
    end

    local trackX = self.width - SCROLLBAR_WIDTH
    local trackHeight = self.height
    local thumbHeight = math.max(24, trackHeight * (self.height / self.contentHeight))
    local thumbY = (trackHeight - thumbHeight) * (self.scrollY / maxScroll)

    return trackX, thumbY, SCROLLBAR_WIDTH, thumbHeight
end

function ReUIScrollContainer:onMouseWheel(delta)
    self:scrollBy(-delta * self.scrollStep)
    return true
end

function ReUIScrollContainer:onMouseDown(x, y)
    if self.showScrollbar then
        local trackX, thumbY, thumbWidth, thumbHeight = self:getScrollbarBounds()
        if trackX and x >= trackX and x <= trackX + thumbWidth
            and y >= thumbY and y <= thumbY + thumbHeight then
            self.dragging = true
            self.dragStartY = y
            self.dragStartScroll = self.scrollY
            return true
        end
    end
    return ReUIPanel.onMouseDown(self, x, y)
end

function ReUIScrollContainer:onMouseMove(dx, dy)
    if self.dragging then
        local maxScroll = self:getMaxScroll()
        local trackHeight = self.height
        local thumbHeight = math.max(24, trackHeight * (self.height / self.contentHeight))
        local travel = math.max(1, trackHeight - thumbHeight)
        local mouseDelta = self:getMouseY() - self.dragStartY
        self:setScroll(self.dragStartScroll + mouseDelta * (maxScroll / travel))
        return true
    end
    return ReUIPanel.onMouseMove(self, dx, dy)
end

function ReUIScrollContainer:onMouseUp(x, y)
    self.dragging = false
    return ReUIPanel.onMouseUp(self, x, y)
end

function ReUIScrollContainer:onMouseUpOutside(x, y)
    self.dragging = false
end

function ReUIScrollContainer:prerender()
    ReUIPanel.prerender(self)

    if self.showScrollbar then
        local trackColor = ReUITheme.color("surfaceAlt")
        self:drawRect(self.width - SCROLLBAR_WIDTH, 0, SCROLLBAR_WIDTH, self.height,
            trackColor.a, trackColor.r, trackColor.g, trackColor.b)

        local trackX, thumbY, thumbWidth, thumbHeight = self:getScrollbarBounds()
        if trackX then
            local thumbColor = ReUITheme.color("border")
            self:drawRect(trackX, thumbY, thumbWidth, thumbHeight,
                thumbColor.a, thumbColor.r, thumbColor.g, thumbColor.b)
        end
    end

    -- Clip everything rendered after this point (the content child renders
    -- next), mirroring the shipped ISScrollingListBox stencil pattern.
    self:setStencilRect(0, 0, self:getViewportWidth(), self.height)
end

function ReUIScrollContainer:render()
    -- Children have finished rendering by now; lift the clip before any
    -- further overlay drawing so it doesn't leak into the next frame.
    self:clearStencilRect()
    ReUIPanel.render(self)
end
