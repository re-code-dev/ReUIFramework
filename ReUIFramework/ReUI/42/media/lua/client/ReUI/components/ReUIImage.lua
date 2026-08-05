require "ISUI/ISPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- Draws a game texture (by path, via getTexture()) or an already-resolved
-- Texture object. Supports "fill" (stretch), "contain" (aspect-fit) and
-- "cover" (aspect-fill, cropped) scale modes.
ReUIImage = ISPanel:derive("ReUIImage")

function ReUIImage:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 64, height or 64)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o.scaleMode = options.scaleMode or "contain"
    o.tintR = options.tintR or 1
    o.tintG = options.tintG or 1
    o.tintB = options.tintB or 1
    o.alpha = options.alpha or 1
    o.drawBackground = options.drawBackground == true
    o.drawBorder = options.drawBorder == true
    o.backgroundRole = options.backgroundRole or "surface"
    o.borderRole = options.borderRole or "border"

    ReUIComponent.apply(o, options)

    if options.texturePath then
        o:setTexturePath(options.texturePath)
    elseif options.texture then
        o:setTexture(options.texture)
    end

    return o
end

function ReUIImage:setTexture(texture)
    self.texture = texture
    return self
end

function ReUIImage:setTexturePath(path)
    self.texture = path and getTexture(path) or nil
    return self
end

function ReUIImage:setScaleMode(mode)
    self.scaleMode = mode or "contain"
    return self
end

function ReUIImage:setTint(r, g, b, a)
    self.tintR = r or 1
    self.tintG = g or 1
    self.tintB = b or 1
    self.alpha = a or self.alpha
    return self
end

function ReUIImage:prerender()
    if self.drawBackground then
        local bg = ReUITheme.color(self.backgroundRole)
        self:drawRect(0, 0, self.width, self.height, bg.a, bg.r, bg.g, bg.b)
    end

    if self.texture then
        if self.scaleMode == "fill" then
            self:drawTextureScaled(self.texture, 0, 0, self.width, self.height,
                self.alpha, self.tintR, self.tintG, self.tintB)
        elseif self.scaleMode == "cover" then
            self:drawTextureScaledAspect2(self.texture, 0, 0, self.width, self.height,
                self.alpha, self.tintR, self.tintG, self.tintB)
        else
            self:drawTextureScaledAspect(self.texture, 0, 0, self.width, self.height,
                self.alpha, self.tintR, self.tintG, self.tintB)
        end
    end

    if self.drawBorder then
        local border = ReUITheme.color(self.borderRole)
        self:drawRectBorder(0, 0, self.width, self.height,
            border.a, border.r, border.g, border.b)
    end
end

function ReUIImage:render()
end
