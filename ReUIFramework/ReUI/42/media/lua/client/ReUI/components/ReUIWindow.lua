require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/managers/ReUIWindowManager"
require "ReUI/managers/ReUIDockManager"

ReUIWindow = ISPanel:derive("ReUIWindow")

function ReUIWindow:initialise()
    ISPanel.initialise(self)
end

function ReUIWindow:createChildren()
    ISPanel.createChildren(self)
end

function ReUIWindow:new(x, y, width, height, title, options)
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.title = title or "Re:UI Window"
    o.subtitle = nil
    o.moveWithMouse = options.moveWithMouse ~= false
    o.showCloseButton = options.showCloseButton ~= false
    o.showMinimizeButton = options.showMinimizeButton ~= false
    o.isDragging = false
    o.dragOffsetX = 0
    o.dragOffsetY = 0
    o.resizingSplitter = false
    o.reuiMinimized = false
    o.reuiIsModal = false
    return o
end

function ReUIWindow:getTitleBarHeight()
    return ReUITheme.metrics.titleBarHeight
end

function ReUIWindow:getControlRects()
    local size = 28
    local gap = 4
    local right = self.width - 8

    local closeRect = {
        x = right - size,
        y = 7,
        width = size,
        height = size
    }

    local minimizeRect = {
        x = closeRect.x - gap - size,
        y = 7,
        width = size,
        height = size
    }

    local stackRect = nil
    if ReUIDockManager:isDocked(self) then
        local stack = ReUIDockManager:getZoneWindows(self.reuiDockZone)
        if #stack > 1 then
            stackRect = {
                x = minimizeRect.x - gap - 40,
                y = 7,
                width = 40,
                height = size
            }
        end
    end

    return minimizeRect, closeRect, stackRect
end

-- Only valid while docked: the inner edge (facing away from the screen
-- border) that, when dragged, resizes the whole zone via ReUIDockManager.
function ReUIWindow:getSplitterRect()
    local zone = self.reuiDockZone
    if not zone then return nil end

    local t = ReUIDockManager.splitterThickness or 6
    if zone == "left" then return { x = self.width - t, y = 0, width = t, height = self.height } end
    if zone == "right" then return { x = 0, y = 0, width = t, height = self.height } end
    if zone == "top" then return { x = 0, y = self.height - t, width = self.width, height = t } end
    if zone == "bottom" then return { x = 0, y = 0, width = self.width, height = t } end
    return nil
end

function ReUIWindow:cycleZoneStack()
    if not ReUIDockManager:isDocked(self) then return end

    local stack = ReUIDockManager:getZoneWindows(self.reuiDockZone)
    if #stack <= 1 then return end

    local index = 1
    for i, w in ipairs(stack) do
        if w == self then index = i end
    end

    ReUIDockManager:setActive(stack[(index % #stack) + 1], self.reuiDockZone)
end

local function contains(rect, x, y)
    return x >= rect.x and y >= rect.y
        and x <= rect.x + rect.width and y <= rect.y + rect.height
end

function ReUIWindow:drawWindowControls()
    local minimizeRect, closeRect, stackRect = self:getControlRects()
    local text = ReUITheme.color("textMuted")
    local hover = ReUITheme.color("surfaceRaised")
    local danger = ReUITheme.color("danger")

    if stackRect then
        local stack = ReUIDockManager:getZoneWindows(self.reuiDockZone)
        local index = 1
        for i, w in ipairs(stack) do
            if w == self then index = i end
        end

        local isHover = contains(stackRect, self:getMouseX(), self:getMouseY())
        if isHover then
            self:drawRect(stackRect.x, stackRect.y, stackRect.width, stackRect.height,
                hover.a, hover.r, hover.g, hover.b)
        end
        self:drawText(index .. "/" .. #stack, stackRect.x + 6, stackRect.y + 5,
            text.r, text.g, text.b, text.a, UIFont.Small)
    end

    if self.showMinimizeButton then
        local isHover = contains(minimizeRect, self:getMouseX(), self:getMouseY())
        if isHover then
            self:drawRect(minimizeRect.x, minimizeRect.y, minimizeRect.width, minimizeRect.height,
                hover.a, hover.r, hover.g, hover.b)
        end
        self:drawText(self.reuiMinimized and "+" or "–",
            minimizeRect.x + 9, minimizeRect.y + 3,
            text.r, text.g, text.b, text.a, UIFont.Medium)
    end

    if self.showCloseButton then
        local isHover = contains(closeRect, self:getMouseX(), self:getMouseY())
        if isHover then
            self:drawRect(closeRect.x, closeRect.y, closeRect.width, closeRect.height,
                danger.a, danger.r, danger.g, danger.b)
        end
        self:drawText("×", closeRect.x + 8, closeRect.y + 3,
            text.r, text.g, text.b, text.a, UIFont.Medium)
    end
end

function ReUIWindow:prerender()
    local bg = ReUITheme.color("background")
    local surface = ReUITheme.color("surface")
    local border = ReUITheme.color("border")
    local primary = ReUITheme.color("primary")
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRect(0, 0, self.width, self:getTitleBarHeight(),
        surface.a, surface.r, surface.g, surface.b)
    self:drawRect(0, self:getTitleBarHeight() - 2, self.width, 2,
        primary.a, primary.r, primary.g, primary.b)
    self:drawRectBorder(0, 0, self.width, self.height,
        border.a, border.r, border.g, border.b)

    self:drawText(self.title, 16, 11, text.r, text.g, text.b, text.a, UIFont.Medium)

    if self.subtitle and not self.reuiMinimized then
        local reserve = 84
        local subtitleWidth = getTextManager():MeasureStringX(UIFont.Small, self.subtitle)
        self:drawText(self.subtitle, self.width - subtitleWidth - reserve, 13,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    end

    self:drawWindowControls()
end

function ReUIWindow:onMouseDown(x, y)
    if not ReUIWindowManager:canInteract(self) then
        return true
    end

    local minimizeRect, closeRect, stackRect = self:getControlRects()

    if stackRect and contains(stackRect, x, y) then
        self:cycleZoneStack()
        return true
    end

    if self.showCloseButton and contains(closeRect, x, y) then
        ReUIWindowManager:close(self)
        return true
    end

    if self.showMinimizeButton and contains(minimizeRect, x, y) then
        ReUIWindowManager:toggleMinimize(self)
        return true
    end

    ReUIWindowManager:setActive(self)

    local splitterRect = self:getSplitterRect()
    if splitterRect and contains(splitterRect, x, y) then
        self.resizingSplitter = true
        return true
    end

    if self.moveWithMouse and y <= self:getTitleBarHeight() then
        if ReUIDockManager:isDocked(self) then
            ReUIDockManager:undock(self)
        end
        self.isDragging = true
        self.dragOffsetX = x
        self.dragOffsetY = y
        return true
    end

    return ISPanel.onMouseDown(self, x, y)
end

function ReUIWindow:onMouseMove(dx, dy)
    if self.resizingSplitter then
        local hostX, hostY, hostWidth, hostHeight = ReUIDockManager:getHostBounds()
        local screenX = self:getAbsoluteX() + self:getMouseX()
        local screenY = self:getAbsoluteY() + self:getMouseY()
        local zone = self.reuiDockZone

        if zone == "left" then
            ReUIDockManager:setZoneSize(zone, screenX - hostX)
        elseif zone == "right" then
            ReUIDockManager:setZoneSize(zone, hostX + hostWidth - screenX)
        elseif zone == "top" then
            ReUIDockManager:setZoneSize(zone, screenY - hostY)
        elseif zone == "bottom" then
            ReUIDockManager:setZoneSize(zone, hostY + hostHeight - screenY)
        end

        return true
    end

    if self.isDragging then
        self:setX(self:getMouseX() + self:getX() - self.dragOffsetX)
        self:setY(self:getMouseY() + self:getY() - self.dragOffsetY)

        local screenX = self:getAbsoluteX() + self:getMouseX()
        local screenY = self:getAbsoluteY() + self:getMouseY()
        ReUIDockManager:setPreviewZone(ReUIDockManager:detectZone(screenX, screenY))

        return true
    end
    return ISPanel.onMouseMove(self, dx, dy)
end

function ReUIWindow:onMouseUp(x, y)
    if self.isDragging and ReUIDockManager.previewZone then
        ReUIDockManager:dock(self, ReUIDockManager.previewZone)
    end
    ReUIDockManager:clearPreview()
    self.isDragging = false
    self.resizingSplitter = false
    return ISPanel.onMouseUp(self, x, y)
end

function ReUIWindow:onMouseUpOutside(x, y)
    ReUIDockManager:clearPreview()
    self.isDragging = false
    self.resizingSplitter = false
end

function ReUIWindow:centerOnScreen()
    self:setX((getCore():getScreenWidth() - self.width) / 2)
    self:setY((getCore():getScreenHeight() - self.height) / 2)
end

function ReUIWindow:open()
    return ReUIWindowManager:open(self)
end

function ReUIWindow:close()
    ReUIWindowManager:close(self)
end

function ReUIWindow:minimize()
    ReUIWindowManager:minimize(self)
end

function ReUIWindow:restore()
    ReUIWindowManager:restore(self)
end

function ReUIWindow:dockLeft() ReUIDockManager:dock(self, "left") end
function ReUIWindow:dockRight() ReUIDockManager:dock(self, "right") end
function ReUIWindow:dockTop() ReUIDockManager:dock(self, "top") end
function ReUIWindow:dockBottom() ReUIDockManager:dock(self, "bottom") end
function ReUIWindow:undock() ReUIDockManager:undock(self) end
function ReUIWindow:isDocked() return ReUIDockManager:isDocked(self) end

function ReUIWindow:render()
    ISPanel.render(self)

    if self.isDragging and ReUIDockManager.previewZone then
        local zoneX, zoneY, zoneWidth, zoneHeight = ReUIDockManager:getZoneRect(ReUIDockManager.previewZone)
        local localX = zoneX - self:getAbsoluteX()
        local localY = zoneY - self:getAbsoluteY()
        local accent = ReUITheme.color("primary")

        self:drawRect(localX, localY, zoneWidth, zoneHeight, 0.22, accent.r, accent.g, accent.b)
        self:drawRectBorder(localX, localY, zoneWidth, zoneHeight, 0.9, accent.r, accent.g, accent.b)
    end
end
