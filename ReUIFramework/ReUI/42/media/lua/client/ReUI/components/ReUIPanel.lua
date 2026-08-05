require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

ReUIPanel = ISPanel:derive("ReUIPanel")

function ReUIPanel:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 100, height or 100)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.backgroundRole = options.backgroundRole or "surface"
    o.borderRole = options.borderRole or "border"
    o.drawBackground = options.drawBackground ~= false
    o.drawBorder = options.drawBorder ~= false
    ReUIComponent.apply(o, options)
    return o
end

function ReUIPanel:prerender()
    if self.drawBackground then
        local bg = ReUITheme.color(self.backgroundRole)
        self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    end

    if self.drawBorder then
        local border = ReUITheme.color(self.borderRole)
        self:drawRectBorder(0, 0, self.width, self.height,
            border.a, border.r, border.g, border.b)
    end
end
