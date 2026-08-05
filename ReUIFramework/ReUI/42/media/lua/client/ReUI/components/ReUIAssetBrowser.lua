require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUIImage"
require "ReUI/components/ReUILabel"
require "ReUI/core/ReUITheme"

-- A thumbnail grid picker (icons + labels), distinct from ReUIFileBrowser's
-- name-only tree: for picking a texture/icon rather than a virtual file
-- path. Same "caller-supplied data, not the real disk" constraint as
-- ReUIFileBrowser applies to the texture paths too - only textures already
-- shipped with the game/mod can be shown.
ReUIAssetBrowser = ReUIScrollContainer:derive("ReUIAssetBrowser")

function ReUIAssetBrowser:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIScrollContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.tileSize = tonumber(options.tileSize) or 72
    o.tileGap = tonumber(options.tileGap) or 8
    o.assets = {}
    o.tiles = {}
    o.selectedIndex = nil
    o.target = options.target
    o.onSelect = options.onSelect

    return o
end

-- assets: {name, texturePath}[]
function ReUIAssetBrowser:setAssets(assets)
    local content = self:getContent()
    for _, tile in ipairs(self.tiles) do content:removeChild(tile.panel) end
    self.tiles = {}
    self.assets = assets or {}
    self.selectedIndex = nil

    local viewportWidth = self:getViewportWidth()
    local columns = math.max(1, math.floor((viewportWidth + self.tileGap) / (self.tileSize + self.tileGap)))
    local cellSize = self.tileSize + self.tileGap

    for i, asset in ipairs(self.assets) do
        local col, row = (i - 1) % columns, math.floor((i - 1) / columns)
        local panel = ReUIPanel:new(col * cellSize, row * cellSize, self.tileSize, self.tileSize, {
            backgroundRole = "surfaceAlt", borderRole = "border"
        })
        panel:initialise(); panel:instantiate(); content:addChild(panel)

        local image = ReUIImage:new(4, 4, self.tileSize - 8, self.tileSize - 24, {
            texturePath = asset.texturePath, scaleMode = "contain"
        })
        image:initialise(); image:instantiate(); panel:addChild(image)

        local label = ReUILabel:new(2, self.tileSize - 18, self.tileSize - 4, 16, asset.name or "", {
            colorRole = "textMuted", font = UIFont.Small, horizontalAlign = "center"
        })
        label:initialise(); label:instantiate(); panel:addChild(label)

        panel.onMouseDown = function()
            self:selectIndex(i)
            return true
        end

        table.insert(self.tiles, { panel = panel, image = image, label = label })
    end

    local rows = math.ceil(#self.assets / columns)
    self:setContentHeight(rows * cellSize)
    return self
end

function ReUIAssetBrowser:selectIndex(index, notify)
    self.selectedIndex = index
    for i, tile in ipairs(self.tiles) do
        tile.panel.borderRole = (i == index) and "primary" or "border"
    end
    if notify ~= false then
        local asset = self.assets[index]
        if self.emit then self:emit("select", asset, index) end
        if self.onSelect then
            if self.target then self.onSelect(self.target, self, asset, index)
            else self.onSelect(self, asset, index) end
        end
    end
    return self
end

function ReUIAssetBrowser:getSelected()
    return self.selectedIndex and self.assets[self.selectedIndex] or nil
end
