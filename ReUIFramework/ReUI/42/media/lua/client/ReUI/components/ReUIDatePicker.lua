require "ISUI/ISPanel"
require "ReUI/components/ReUIButton"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A text field + calendar-icon button that opens a top-level month-grid
-- popup (same top-level-popup shape as ReUIDropdown). Date math is done by
-- hand (Zeller's congruence for weekday, a days-in-month table) rather than
-- relying on Lua's os.date, since availability of `os` in Build 42's
-- sandboxed Lua isn't guaranteed.
ReUIDatePicker = ISPanel:derive("ReUIDatePicker")

local DAYS_IN_MONTH = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
local WEEKDAY_LABELS = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }

local function isLeapYear(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

local function daysInMonth(year, month)
    if month == 2 and isLeapYear(year) then return 29 end
    return DAYS_IN_MONTH[month]
end

-- Zeller's congruence, Gregorian, returns 0=Saturday..6=Friday normalized
-- below to 0=Sunday for grid layout.
local function weekdayOf(year, month, day)
    local y, m = year, month
    if m < 3 then m = m + 12; y = y - 1 end
    local k, j = y % 100, math.floor(y / 100)
    local h = (day + math.floor(13 * (m + 1) / 5) + k + math.floor(k / 4) + math.floor(j / 4) + 5 * j) % 7
    return (h + 6) % 7 -- 0 = Sunday
end

local ReUIDatePickerPopup = ISPanel:derive("ReUIDatePickerPopup")

function ReUIDatePickerPopup:new(x, y, owner)
    local cellSize = 30
    local width = cellSize * 7
    local height = cellSize * 8
    local o = ISPanel.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.owner = owner
    o.cellSize = cellSize
    o.viewYear = owner.year
    o.viewMonth = owner.month
    return o
end

function ReUIDatePickerPopup:createChildren()
    ISPanel.createChildren(self)
    self.prevButton = ReUIButton:new(4, 2, 26, 24, "<", self, ReUIDatePickerPopup.onPrevMonth)
    self.prevButton:setVariant("ghost")
    self.prevButton:initialise(); self.prevButton:instantiate(); self:addChild(self.prevButton)

    self.nextButton = ReUIButton:new(self.width - 30, 2, 26, 24, ">", self, ReUIDatePickerPopup.onNextMonth)
    self.nextButton:setVariant("ghost")
    self.nextButton:initialise(); self.nextButton:instantiate(); self:addChild(self.nextButton)
end

function ReUIDatePickerPopup:onPrevMonth()
    self.viewMonth = self.viewMonth - 1
    if self.viewMonth < 1 then self.viewMonth = 12; self.viewYear = self.viewYear - 1 end
end

function ReUIDatePickerPopup:onNextMonth()
    self.viewMonth = self.viewMonth + 1
    if self.viewMonth > 12 then self.viewMonth = 1; self.viewYear = self.viewYear + 1 end
end

function ReUIDatePickerPopup:dayAt(x, y)
    if y < self.cellSize * 2 then return nil end
    local col = math.floor(x / self.cellSize)
    local row = math.floor(y / self.cellSize) - 2
    if col < 0 or col > 6 or row < 0 then return nil end
    local firstWeekday = weekdayOf(self.viewYear, self.viewMonth, 1)
    local day = row * 7 + col - firstWeekday + 1
    if day < 1 or day > daysInMonth(self.viewYear, self.viewMonth) then return nil end
    return day
end

function ReUIDatePickerPopup:onMouseDown(x, y)
    local day = self:dayAt(x, y)
    if day then
        self.owner:setDate(self.viewYear, self.viewMonth, day)
        self.owner:closePopup()
        return true
    end
    return ISPanel.onMouseDown(self, x, y)
end

function ReUIDatePickerPopup:onMouseUpOutside(x, y)
    self.owner:closePopup()
end

function ReUIDatePickerPopup:prerender()
    local bg = ReUITheme.color("surfaceAlt")
    local border = ReUITheme.color("border")
    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")
    local primary = ReUITheme.color("primary")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)

    local monthLabel = self.viewMonth .. "/" .. self.viewYear
    local labelWidth = getTextManager():MeasureStringX(UIFont.Small, monthLabel)
    self:drawText(monthLabel, (self.width - labelWidth) / 2, self.cellSize / 2 - 6,
        text.r, text.g, text.b, text.a, UIFont.Small)

    for i, label in ipairs(WEEKDAY_LABELS) do
        local x = (i - 1) * self.cellSize
        local w = getTextManager():MeasureStringX(UIFont.Small, label)
        self:drawText(label, x + (self.cellSize - w) / 2, self.cellSize + 8,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    end

    local firstWeekday = weekdayOf(self.viewYear, self.viewMonth, 1)
    local total = daysInMonth(self.viewYear, self.viewMonth)
    for day = 1, total do
        local index = firstWeekday + day - 1
        local col, row = index % 7, math.floor(index / 7)
        local x = col * self.cellSize
        local y = (row + 2) * self.cellSize

        local isSelected = self.viewYear == self.owner.year and self.viewMonth == self.owner.month and day == self.owner.day
        if isSelected then
            self:drawRect(x + 2, y + 2, self.cellSize - 4, self.cellSize - 4, primary.a, primary.r, primary.g, primary.b)
        end

        local label = tostring(day)
        local w = getTextManager():MeasureStringX(UIFont.Small, label)
        local color = isSelected and ReUITheme.color("text") or text
        self:drawText(label, x + (self.cellSize - w) / 2, y + 7, color.r, color.g, color.b, color.a, UIFont.Small)
    end
end

function ReUIDatePicker:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 160, height or 30)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.year = options.year or 1993
    o.month = options.month or 1
    o.day = options.day or 1
    o.target = options.target
    o.onChange = options.onChange
    o.popup = nil
    o.hovered = false

    ReUIComponent.apply(o, options)
    return o
end

function ReUIDatePicker:setDate(year, month, day, notify)
    self.year, self.month, self.day = year, month, day
    if notify ~= false then
        if self.emit then self:emit("change", year, month, day) end
        if self.onChange then
            if self.target then self.onChange(self.target, self, year, month, day)
            else self.onChange(self, year, month, day) end
        end
    end
    return self
end

function ReUIDatePicker:getDateString()
    return string.format("%04d-%02d-%02d", self.year, self.month, self.day)
end

function ReUIDatePicker:openPopup()
    if self.popup then return end
    self.popup = ReUIDatePickerPopup:new(self:getAbsoluteX(), self:getAbsoluteY() + self.height, self)
    self.popup:initialise()
    self.popup:instantiate()
    self.popup:createChildren()
    self.popup:addToUIManager()
    self.popup:bringToTop()
end

function ReUIDatePicker:closePopup()
    if not self.popup then return end
    self.popup:removeFromUIManager()
    self.popup = nil
end

function ReUIDatePicker:togglePopup()
    if self.popup then self:closePopup() else self:openPopup() end
end

function ReUIDatePicker:onMouseDown(x, y)
    self:togglePopup()
    return true
end

function ReUIDatePicker:onMouseMove(dx, dy)
    self.hovered = true
    return ISPanel.onMouseMove(self, dx, dy)
end

function ReUIDatePicker:onMouseMoveOutside(dx, dy)
    self.hovered = false
end

function ReUIDatePicker:prerender()
    local bg = ReUITheme.color(self.hovered and "surfaceRaised" or "surfaceAlt")
    local border = ReUITheme.color(self.popup and "primary" or "border")
    local text = ReUITheme.color("text")

    self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, border.a, border.r, border.g, border.b)
    self:drawText(self:getDateString(), 8, ReUITheme.textY(UIFont.Small, 0, self.height),
        text.r, text.g, text.b, text.a, UIFont.Small)
    local arrow = self.popup and "^" or "v"
    self:drawText(arrow, self.width - 18, ReUITheme.textY(UIFont.Small, 0, self.height),
        text.r, text.g, text.b, text.a, UIFont.Small)
end

function ReUIDatePicker:render()
end
