require "ISUI/ISPanel"
require "ReUI/components/ReUITextBox"
require "ReUI/core/ReUITheme"

-- A top-level (not window-scoped) fuzzy-filter command list, spotlight/
-- command-palette style. Single global instance, opened/closed via
-- ReUICommandPalette.open(commands)/.close()/.toggle(commands).
-- `commands`: {label, hint, onRun}[].
ReUICommandPalette = ISPanel:derive("ReUICommandPalette")

local ROW_HEIGHT = 30
local MAX_VISIBLE_ROWS = 8

-- Subsequence match (every query char must appear in order in the label,
-- case-insensitive) - simple, no scoring, good enough for a mod-sized
-- command list.
local function matches(query, label)
    if query == "" then return true end
    local q, l = query:lower(), label:lower()
    local qi = 1
    for li = 1, #l do
        if qi > #q then return true end
        if l:sub(li, li) == q:sub(qi, qi) then qi = qi + 1 end
    end
    return qi > #q
end

function ReUICommandPalette:new(commands)
    local width = 460
    local o = ISPanel.new(self, 0, 0, width, 44)
    setmetatable(o, self)
    self.__index = self

    o.commands = commands or {}
    o.filtered = {}
    o.hoverIndex = nil
    o.query = ""

    return o
end

function ReUICommandPalette:createChildren()
    ISPanel.createChildren(self)

    self.input = ReUITextBox:new(0, 0, self.width, 40, {
        placeholder = "Type a command...",
        onChange = function(control, text) self:setQuery(text) end
    })
    self.input:initialise()
    self.input:instantiate()
    self:addChild(self.input)

    self:setQuery("")
end

function ReUICommandPalette:setQuery(query)
    self.query = query or ""
    self.filtered = {}
    for _, command in ipairs(self.commands) do
        if matches(self.query, command.label) then
            table.insert(self.filtered, command)
        end
    end
    self.hoverIndex = #self.filtered > 0 and 1 or nil

    local visibleRows = math.min(#self.filtered, MAX_VISIBLE_ROWS)
    self:setHeight(44 + visibleRows * ROW_HEIGHT + (visibleRows > 0 and 6 or 0))
end

function ReUICommandPalette:rowAt(y)
    if y < 44 then return nil end
    local index = math.floor((y - 44) / ROW_HEIGHT) + 1
    if index < 1 or index > #self.filtered then return nil end
    return index
end

function ReUICommandPalette:runIndex(index)
    local command = self.filtered[index]
    if command and command.onRun then command.onRun(command) end
    ReUICommandPalette.close()
end

function ReUICommandPalette:onMouseMove(dx, dy)
    local index = self:rowAt(self:getMouseY())
    if index then self.hoverIndex = index end
end

function ReUICommandPalette:onMouseDown(x, y)
    local index = self:rowAt(y)
    if index then self:runIndex(index); return true end
    return ISPanel.onMouseDown(self, x, y)
end

function ReUICommandPalette:prerender()
    local bg = ReUITheme.color("surfaceRaised")
    local border = ReUITheme.color("primary")
    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    local text, muted = ReUITheme.color("text"), ReUITheme.color("textMuted")
    local rowY = 44
    for i, command in ipairs(self.filtered) do
        if i > MAX_VISIBLE_ROWS then break end
        if i == self.hoverIndex then
            local sel = ReUITheme.color("primaryMuted")
            self:drawRect(4, rowY, self.width - 8, ROW_HEIGHT, sel.a, sel.r, sel.g, sel.b)
        end
        self:drawText(command.label, 14, ReUITheme.textY(UIFont.Small, rowY, ROW_HEIGHT),
            text.r, text.g, text.b, text.a, UIFont.Small)
        if command.hint then
            local hintWidth = getTextManager():MeasureStringX(UIFont.Small, command.hint)
            self:drawText(command.hint, self.width - hintWidth - 14, ReUITheme.textY(UIFont.Small, rowY, ROW_HEIGHT),
                muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        end
        rowY = rowY + ROW_HEIGHT
    end

    if #self.filtered == 0 and self.query ~= "" then
        self:drawText("No matching commands", 14, ReUITheme.textY(UIFont.Small, 44, ROW_HEIGHT),
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    end
end

function ReUICommandPalette.open(commands)
    ReUICommandPalette.close()
    local palette = ReUICommandPalette:new(commands)
    palette:setX((getCore():getScreenWidth() - palette.width) / 2)
    palette:setY(getCore():getScreenHeight() * 0.22)
    palette:initialise()
    palette:createChildren()
    palette:addToUIManager()
    palette:bringToTop()
    palette.input:focus()
    ReUICommandPalette.instance = palette
    return palette
end

function ReUICommandPalette.close()
    if ReUICommandPalette.instance then
        ReUICommandPalette.instance:removeFromUIManager()
        ReUICommandPalette.instance = nil
    end
end

function ReUICommandPalette.toggle(commands)
    if ReUICommandPalette.instance then
        ReUICommandPalette.close()
    else
        ReUICommandPalette.open(commands)
    end
end

-- Global key handling instead of per-instance onKeyPress: keyboard focus in
-- this engine's UI toolkit generally only reaches text-entry widgets, not a
-- plain ISPanel, so Escape/Enter/Up/Down are wired through the same
-- always-firing Events.OnKeyPressed channel Bootstrap files use for
-- keybinds - reliable regardless of which child currently holds focus.
if not ReUICommandPalette.keysRegistered and Events and Events.OnKeyPressed then
    ReUICommandPalette.keysRegistered = true
    Events.OnKeyPressed.Add(function(key)
        local palette = ReUICommandPalette.instance
        if not palette then return end

        if key == Keyboard.KEY_ESCAPE then
            ReUICommandPalette.close()
        elseif key == Keyboard.KEY_RETURN and palette.hoverIndex then
            palette:runIndex(palette.hoverIndex)
        elseif key == Keyboard.KEY_DOWN and #palette.filtered > 0 then
            palette.hoverIndex = math.min(#palette.filtered, (palette.hoverIndex or 0) + 1)
        elseif key == Keyboard.KEY_UP and #palette.filtered > 0 then
            palette.hoverIndex = math.max(1, (palette.hoverIndex or 1) - 1)
        end
    end)
end
