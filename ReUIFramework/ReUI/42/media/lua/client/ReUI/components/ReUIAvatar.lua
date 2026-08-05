require "ISUI/ISPanel"
require "ReUI/components/ReUIImage"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A square (rounded-corner-in-spirit, PZ draws sharp rects) avatar: either
-- an image (via ReUIImage) or initials on a themed color background when no
-- texture is given. Optional status dot (online/away/offline/busy).
ReUIAvatar = ISPanel:derive("ReUIAvatar")

local STATUS_ROLE = {
    online = "success", away = "warning", busy = "danger", offline = "textDisabled"
}

function ReUIAvatar:new(x, y, size, options)
    local o = ISPanel.new(self, x or 0, y or 0, size or 40, size or 40)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.initials = options.initials
    o.colorRole = options.colorRole or "primary"
    o.status = options.status
    o.texturePath = options.texturePath

    ReUIComponent.apply(o, options)
    return o
end

function ReUIAvatar:createChildren()
    ISPanel.createChildren(self)
    if self.texturePath then
        self.image = ReUIImage:new(0, 0, self.width, self.height, {
            texturePath = self.texturePath, scaleMode = "cover"
        })
        self.image:initialise()
        self.image:instantiate()
        self:addChild(self.image)
    end
end

function ReUIAvatar:setStatus(status)
    self.status = status
    return self
end

function ReUIAvatar:prerender()
    if not self.texturePath then
        local bg = ReUITheme.color(self.colorRole)
        self:drawRect(0, 0, self.width, self.height, bg.a * 0.28, bg.r, bg.g, bg.b)
        self:drawRectBorder(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)

        if self.initials then
            local text = ReUITheme.color("text")
            local font = self.width >= 48 and UIFont.Medium or UIFont.Small
            local textWidth = getTextManager():MeasureStringX(font, self.initials)
            self:drawText(self.initials, (self.width - textWidth) / 2,
                ReUITheme.textY(font, 0, self.height), text.r, text.g, text.b, text.a, font)
        end
    end

    if self.status then
        local role = STATUS_ROLE[self.status] or "textDisabled"
        local color = ReUITheme.color(role)
        local dotSize = math.max(8, math.floor(self.width * 0.28))
        local dx, dy = self.width - dotSize, self.height - dotSize
        local bg = ReUITheme.color("background")
        self:drawRect(dx - 1, dy - 1, dotSize + 2, dotSize + 2, bg.a, bg.r, bg.g, bg.b)
        self:drawRect(dx, dy, dotSize, dotSize, color.a, color.r, color.g, color.b)
    end
end
