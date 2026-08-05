require "ISUI/ISPanel"
require "ReUI/components/ReUINumberBox"
require "ReUI/components/ReUIButton"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- Inline hour/minute steppers (no popup - a NumberBox pair reads more
-- clearly for time than a picker wheel would in this engine's UI toolkit)
-- plus an AM/PM toggle when `use24Hour` is false.
ReUITimePicker = ISPanel:derive("ReUITimePicker")

function ReUITimePicker:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 180, height or 32)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.use24Hour = options.use24Hour == true
    o.hour = options.hour or 9
    o.minute = options.minute or 0
    o.isPM = options.isPM == true
    o.target = options.target
    o.onChange = options.onChange

    ReUIComponent.apply(o, options)
    return o
end

function ReUITimePicker:createChildren()
    ISPanel.createChildren(self)

    local maxHour = self.use24Hour and 23 or 12
    local minHour = self.use24Hour and 0 or 1

    self.hourBox = ReUINumberBox:new(0, 0, 64, self.height, {
        value = self.hour, min = minHour, max = maxHour, step = 1
    })
    self.hourBox:on("change", function(control) self:commit(control:getNumber(), self.minute, self.isPM) end)
    self.hourBox:initialise(); self.hourBox:instantiate(); self:addChild(self.hourBox)

    self.minuteBox = ReUINumberBox:new(72, 0, 64, self.height, {
        value = self.minute, min = 0, max = 59, step = 5
    })
    self.minuteBox:on("change", function(control) self:commit(self.hour, control:getNumber(), self.isPM) end)
    self.minuteBox:initialise(); self.minuteBox:instantiate(); self:addChild(self.minuteBox)

    if not self.use24Hour then
        self.meridiemButton = ReUIButton:new(144, 0, 36, self.height, self.isPM and "PM" or "AM", self, ReUITimePicker.onToggleMeridiem)
        self.meridiemButton:setVariant("ghost")
        self.meridiemButton:initialise(); self.meridiemButton:instantiate(); self:addChild(self.meridiemButton)
    end
end

function ReUITimePicker:onToggleMeridiem()
    self:commit(self.hour, self.minute, not self.isPM)
end

function ReUITimePicker:commit(hour, minute, isPM, notify)
    self.hour, self.minute, self.isPM = hour, minute, isPM
    if self.meridiemButton then self.meridiemButton.title = isPM and "PM" or "AM" end

    if notify ~= false then
        if self.emit then self:emit("change", self:getTimeString()) end
        if self.onChange then
            if self.target then self.onChange(self.target, self, self:getTimeString())
            else self.onChange(self, self:getTimeString()) end
        end
    end
    return self
end

function ReUITimePicker:getTimeString()
    if self.use24Hour then
        return string.format("%02d:%02d", self.hour, self.minute)
    end
    return string.format("%02d:%02d %s", self.hour, self.minute, self.isPM and "PM" or "AM")
end
