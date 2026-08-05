require "ReUI/components/ReUITextBox"
require "ReUI/core/ReUITheme"

-- A ReUITextBox with a clear ("x") button that appears once there's text.
-- Fires the same "change" event as ReUITextBox plus its own "clear" event
-- when the x is clicked. No icon glyph is drawn (avoids relying on a
-- non-ASCII character the game's bitmap fonts may not have a glyph for);
-- the "Search..." placeholder carries that signal instead.
ReUISearchBox = ReUITextBox:derive("ReUISearchBox")

local CLEAR_WIDTH = 22

function ReUISearchBox:new(x, y, width, height, options)
    options = options or {}
    options.placeholder = options.placeholder or "Search..."
    local o = ReUITextBox.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self
    return o
end

function ReUISearchBox:getClearRect()
    return { x = self.width - CLEAR_WIDTH, y = 0, width = CLEAR_WIDTH, height = self.height }
end

local function contains(rect, x, y)
    return x >= rect.x and y >= rect.y and x <= rect.x + rect.width and y <= rect.y + rect.height
end

function ReUISearchBox:onMouseDown(x, y)
    local text = self:getValue()
    if text and text ~= "" and contains(self:getClearRect(), x, y) then
        self:setValue("")
        if self.emit then self:emit("clear") end
        return true
    end
    return ReUITextBox.onMouseDown(self, x, y)
end

function ReUISearchBox:render()
    ReUITextBox.render(self)

    local muted = ReUITheme.color("textMuted")
    local text = self:getValue()
    if text and text ~= "" then
        local rect = self:getClearRect()
        self:drawText("x", rect.x + 6, ReUITheme.textY(UIFont.Small, 0, self.height),
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    end
end
