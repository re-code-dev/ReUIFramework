require "ReUI/core/ReUITheme"

-- Edge docking (v2): each screen edge (left/right/top/bottom) holds a
-- *stack* of windows, one active/visible at a time (see ReUIWindow's title-
-- bar stack indicator to cycle). Dragging a ReUIWindow's title bar near a
-- screen edge previews that zone; releasing there docks it, adding it to
-- the zone's stack and activating it. The active window's inner edge (the
-- one facing away from the screen border) is a drag-to-resize splitter —
-- see ReUIWindow:getSplitterRect/onMouseMove.
ReUIDockManager = ReUIDockManager or {
    docked = { left = {}, right = {}, top = {}, bottom = {} },
    activeInZone = { left = nil, right = nil, top = nil, bottom = nil },
    edgeThreshold = 28,
    splitterThickness = 6,
    zoneSize = { left = 320, right = 320, top = 220, bottom = 220 },
    previewZone = nil
}

function ReUIDockManager:getHostBounds()
    return 0, 0, getCore():getScreenWidth(), getCore():getScreenHeight()
end

function ReUIDockManager:getZoneRect(zone)
    local hx, hy, hw, hh = self:getHostBounds()
    local size = self.zoneSize[zone] or 300

    if zone == "left" then
        return hx, hy, size, hh
    elseif zone == "right" then
        return hx + hw - size, hy, size, hh
    elseif zone == "top" then
        return hx, hy, hw, size
    elseif zone == "bottom" then
        return hx, hy + hh - size, hw, size
    end

    return hx, hy, hw, hh
end

-- screenX/screenY: absolute screen-space coordinates (element-local
-- getMouseX/Y plus getAbsoluteX/Y), not element-relative ones.
function ReUIDockManager:detectZone(screenX, screenY)
    local hx, hy, hw, hh = self:getHostBounds()
    local t = self.edgeThreshold

    if screenX <= hx + t then return "left" end
    if screenX >= hx + hw - t then return "right" end
    if screenY <= hy + t then return "top" end
    if screenY >= hy + hh - t then return "bottom" end
    return nil
end

function ReUIDockManager:isDocked(window)
    return window ~= nil and window.reuiDockZone ~= nil
end

function ReUIDockManager:getZoneStack(zone)
    self.docked[zone] = self.docked[zone] or {}
    return self.docked[zone]
end

function ReUIDockManager:getZoneWindows(zone)
    return self:getZoneStack(zone)
end

function ReUIDockManager:getActiveInZone(zone)
    return self.activeInZone[zone]
end

function ReUIDockManager:applyGeometry(window, zone)
    local x, y, w, h = self:getZoneRect(zone)
    window:setX(x)
    window:setY(y)
    window:setWidth(w)
    window:setHeight(h)
end

-- Makes `window` the visible tab within its zone; hides the rest of the
-- stack (they keep their state, just stop rendering/receiving input).
function ReUIDockManager:setActive(window, zone)
    zone = zone or window.reuiDockZone
    if not zone then return end

    self.activeInZone[zone] = window
    for _, w in ipairs(self:getZoneStack(zone)) do
        w:setVisible(w == window)
    end
    self:applyGeometry(window, zone)

    if window.bringToTop then window:bringToTop() end
end

function ReUIDockManager:removeFromZone(window, zone)
    local stack = self:getZoneStack(zone)
    for i = #stack, 1, -1 do
        if stack[i] == window then
            table.remove(stack, i)
        end
    end

    if self.activeInZone[zone] == window then
        local nextWindow = stack[#stack]
        self.activeInZone[zone] = nextWindow
        if nextWindow then
            self:setActive(nextWindow, zone)
        end
    end
end

function ReUIDockManager:dock(window, zone)
    if not window or not zone then return end

    if not self:isDocked(window) then
        window.reuiFloatingRect = {
            x = window:getX(), y = window:getY(),
            width = window:getWidth(), height = window:getHeight()
        }
    elseif window.reuiDockZone == zone then
        self:setActive(window, zone)
        return
    else
        self:removeFromZone(window, window.reuiDockZone)
    end

    window.reuiDockZone = zone
    table.insert(self:getZoneStack(zone), window)
    self:setActive(window, zone)

    if window.onReUIDock then window:onReUIDock(zone) end
end

function ReUIDockManager:undock(window)
    if not self:isDocked(window) then return end

    local zone = window.reuiDockZone
    self:removeFromZone(window, zone)
    window.reuiDockZone = nil
    window:setVisible(true)

    local rect = window.reuiFloatingRect
    if rect then
        window:setX(rect.x)
        window:setY(rect.y)
        window:setWidth(rect.width)
        window:setHeight(rect.height)
    end

    if window.onReUIUndock then window:onReUIUndock() end
end

-- Call after a screen resolution change to re-fit every zone's active window.
function ReUIDockManager:relayout()
    for zone, window in pairs(self.activeInZone) do
        if window then
            self:applyGeometry(window, zone)
        end
    end
end

function ReUIDockManager:setZoneSize(zone, size)
    self.zoneSize[zone] = math.max(80, math.floor(size))
    local window = self.activeInZone[zone]
    if window then
        self:applyGeometry(window, zone)
    end
end

function ReUIDockManager:setPreviewZone(zone)
    self.previewZone = zone
end

function ReUIDockManager:clearPreview()
    self.previewZone = nil
end
