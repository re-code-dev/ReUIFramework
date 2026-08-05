require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"

-- Right-click/popup menu: a top-level panel (added directly to the
-- UIManager, not a child) listing clickable items, closed on selection or
-- an outside click. Same top-level-popup shape as ReUIDropdown's popup,
-- generalized for arbitrary screen coordinates and item callbacks.
ReUIContextMenu = ISPanel:derive("ReUIContextMenu")

local ROW_HEIGHT = 28
local DIVIDER_HEIGHT = 9

function ReUIContextMenu:new(items)
    local width = 0
    local height = 0
    for _, item in ipairs(items or {}) do
        if item.divider then
            height = height + DIVIDER_HEIGHT
        else
            height = height + ROW_HEIGHT
            local textWidth = getTextManager():MeasureStringX(UIFont.Small, item.label or "")
            width = math.max(width, textWidth + 32)
        end
    end
    width = math.max(width, 140)

    local o = ISPanel.new(self, 0, 0, width, height)
    setmetatable(o, self)
    self.__index = self

    o.items = items or {}
    o.hoverIndex = nil
    return o
end

function ReUIContextMenu:rowAt(y)
    local rowY = 0
    for i, item in ipairs(self.items) do
        local h = item.divider and DIVIDER_HEIGHT or ROW_HEIGHT
        if y >= rowY and y < rowY + h then
            return (not item.divider) and i or nil
        end
        rowY = rowY + h
    end
    return nil
end

function ReUIContextMenu:onMouseMove(dx, dy)
    self.hoverIndex = self:rowAt(self:getMouseY())
end

function ReUIContextMenu:onMouseDown(x, y)
    local index = self:rowAt(y)
    if index then
        local item = self.items[index]
        if item.enabled ~= false and item.onSelect then
            item.onSelect(item)
        end
    end
    ReUIContextMenu.close()
    return true
end

function ReUIContextMenu:onMouseUpOutside(x, y)
    ReUIContextMenu.close()
end

function ReUIContextMenu:prerender()
    local bg = ReUITheme.color("surfaceAlt")
    local border = ReUITheme.color("border")
    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    local rowY = 0
    for i, item in ipairs(self.items) do
        if item.divider then
            local dividerColor = ReUITheme.color("border")
            self:drawRect(8, rowY + math.floor(DIVIDER_HEIGHT / 2), self.width - 16, 1,
                dividerColor.a, dividerColor.r, dividerColor.g, dividerColor.b)
            rowY = rowY + DIVIDER_HEIGHT
        else
            if i == self.hoverIndex and item.enabled ~= false then
                local hover = ReUITheme.color("surfaceRaised")
                self:drawRect(0, rowY, self.width, ROW_HEIGHT, hover.a, hover.r, hover.g, hover.b)
            end
            local color = item.enabled == false and ReUITheme.color("textDisabled") or ReUITheme.color("text")
            self:drawText(item.label, 12, ReUITheme.textY(UIFont.Small, rowY, ROW_HEIGHT),
                color.r, color.g, color.b, color.a, UIFont.Small)
            rowY = rowY + ROW_HEIGHT
        end
    end
end

-- One global menu instance at a time, like ReUIDropdown's popup.
function ReUIContextMenu.open(screenX, screenY, items)
    ReUIContextMenu.close()

    local menu = ReUIContextMenu:new(items)
    local maxX = getCore():getScreenWidth() - menu.width
    local maxY = getCore():getScreenHeight() - menu.height
    menu:setX(math.max(0, math.min(screenX, maxX)))
    menu:setY(math.max(0, math.min(screenY, maxY)))
    menu:initialise()
    menu:instantiate()
    menu:addToUIManager()
    menu:bringToTop()
    ReUIContextMenu.instance = menu
    return menu
end

function ReUIContextMenu.close()
    if ReUIContextMenu.instance then
        ReUIContextMenu.instance:removeFromUIManager()
        ReUIContextMenu.instance = nil
    end
end
