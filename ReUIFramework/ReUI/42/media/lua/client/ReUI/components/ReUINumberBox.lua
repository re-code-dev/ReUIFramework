require "ReUI/components/ReUITextBox"
require "ReUI/components/ReUIButton"
require "ReUI/core/ReUITheme"

-- A ReUITextBox restricted to numeric input, with optional min/max clamping
-- and +/- stepper buttons.
ReUINumberBox = ReUITextBox:derive("ReUINumberBox")

local STEPPER_WIDTH = 20

local function clamp(value, minimum, maximum)
    if minimum and value < minimum then value = minimum end
    if maximum and value > maximum then value = maximum end
    return value
end

local function formatNumber(value, decimals)
    if decimals and decimals > 0 then
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(math.floor(value + 0.5))
end

function ReUINumberBox:new(x, y, width, height, options)
    options = options or {}

    local decimals = tonumber(options.decimals) or 0
    local minimum = tonumber(options.min)
    local maximum = tonumber(options.max)
    local step = tonumber(options.step) or 1
    local initialValue = clamp(tonumber(options.value) or minimum or 0, minimum, maximum)

    local textOptions = {}
    for k, v in pairs(options) do textOptions[k] = v end
    textOptions.numbersOnly = true
    textOptions.allowFloat = decimals > 0
    textOptions.text = formatNumber(initialValue, decimals)
    textOptions.showStepper = nil

    local o = ReUITextBox.new(self, x, y, width, height, textOptions)
    setmetatable(o, self)
    self.__index = self

    o.minimum = minimum
    o.maximum = maximum
    o.step = step
    o.decimals = decimals
    o.showStepper = options.showStepper ~= false
    o.paddingRight = o.showStepper and (STEPPER_WIDTH + 4) or o.paddingRight

    return o
end

-- ISTextEntryBox:instantiate() does not call createChildren(), so the
-- stepper buttons are built here instead, right after the native text-entry
-- javaObject exists.
function ReUINumberBox:instantiate()
    ReUITextBox.instantiate(self)

    if not self.showStepper then return end

    self.incrementButton = ReUIButton:new(self.width - STEPPER_WIDTH, 0, STEPPER_WIDTH,
        math.floor(self.height / 2), "+", self, ReUINumberBox.onIncrement)
    self.incrementButton:initialise()
    self.incrementButton:instantiate()
    self.incrementButton.anchorLeft = false
    self.incrementButton.anchorRight = true
    self:addChild(self.incrementButton)

    self.decrementButton = ReUIButton:new(self.width - STEPPER_WIDTH, math.floor(self.height / 2),
        STEPPER_WIDTH, self.height - math.floor(self.height / 2), "-", self, ReUINumberBox.onDecrement)
    self.decrementButton:initialise()
    self.decrementButton:instantiate()
    self.decrementButton.anchorLeft = false
    self.decrementButton.anchorRight = true
    self:addChild(self.decrementButton)
end

function ReUINumberBox:getNumber()
    return tonumber(self:getText()) or 0
end

function ReUINumberBox:setNumber(value, notify)
    value = clamp(tonumber(value) or 0, self.minimum, self.maximum)
    self:setText(formatNumber(value, self.decimals))
    if notify ~= false then
        self:notifyChanged()
    end
    return self
end

function ReUINumberBox:setRange(minimum, maximum)
    self.minimum = minimum
    self.maximum = maximum
    self:setNumber(self:getNumber(), false)
    return self
end

function ReUINumberBox:setStep(step)
    self.step = tonumber(step) or 1
    return self
end

function ReUINumberBox:onIncrement()
    self:setNumber(self:getNumber() + self.step)
end

function ReUINumberBox:onDecrement()
    self:setNumber(self:getNumber() - self.step)
end

-- Reject non-numeric edits and clamp on commit rather than on every
-- keystroke, so the player can still type "-" or an empty field mid-edit.
function ReUINumberBox:onCommandEntered()
    self:setNumber(self:getNumber())
    ReUITextBox.onCommandEntered(self)
end

function ReUINumberBox:onLoseFocus()
    self:setNumber(self:getNumber())
    ReUITextBox.onLoseFocus(self)
end
