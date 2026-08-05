require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/core/ReUITheme"

-- A vertical timeline: a connecting line with a dot per entry, each entry
-- showing a title, optional timestamp and optional description. Built on
-- ReUIScrollContainer for the entry list, same shape as ReUIListView.
ReUITimeline = ReUIScrollContainer:derive("ReUITimeline")

local DOT_SIZE = 10
local RAIL_X = 6
local ENTRY_PADDING = 14

function ReUITimeline:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIScrollContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self
    o.entries = {}
    return o
end

-- entry: {title, timestamp, description, colorRole}
function ReUITimeline:addEntry(entry)
    local content = self:getContent()
    local viewportWidth = self:getViewportWidth()
    local textX = RAIL_X * 2 + DOT_SIZE

    local titleHeight = 20
    local timeHeight = entry.timestamp and 16 or 0
    local descHeight = entry.description and 32 or 0
    local entryHeight = titleHeight + timeHeight + descHeight + ENTRY_PADDING

    local yOffset = 0
    for _, existing in ipairs(self.entries) do yOffset = yOffset + existing.height end

    local row = ReUIPanel:new(0, yOffset, viewportWidth, entryHeight, { drawBackground = false, drawBorder = false })
    row:initialise(); row:instantiate(); content:addChild(row)

    row.colorRole = entry.colorRole or "primary"

    local title = ReUILabel:new(textX, 0, viewportWidth - textX - 8, titleHeight, entry.title or "",
        { colorRole = "text", font = UIFont.Small })
    title:initialise(); title:instantiate(); row:addChild(title)

    local timeLabel
    if entry.timestamp then
        timeLabel = ReUILabel:new(textX, titleHeight, viewportWidth - textX - 8, timeHeight, entry.timestamp,
            { colorRole = "textMuted", font = UIFont.Small })
        timeLabel:initialise(); timeLabel:instantiate(); row:addChild(timeLabel)
    end

    local descLabel
    if entry.description then
        descLabel = ReUILabel:new(textX, titleHeight + timeHeight, viewportWidth - textX - 8, descHeight,
            entry.description, { colorRole = "textMuted", font = UIFont.Small })
        descLabel:initialise(); descLabel:instantiate(); row:addChild(descLabel)
    end

    table.insert(self.entries, { row = row, height = entryHeight, colorRole = row.colorRole })
    self:setContentHeight(yOffset + entryHeight)
    return row
end

function ReUITimeline:clear()
    local content = self:getContent()
    for _, entry in ipairs(self.entries) do
        content:removeChild(entry.row)
    end
    self.entries = {}
    self:setContentHeight(0)
    return self
end

-- The rail line + dots are drawn on the timeline itself (not per-row) so
-- they stay correctly positioned under ReUIScrollContainer's stencil clip.
function ReUITimeline:render()
    ReUIScrollContainer.render(self)

    local content = self:getContent()
    local border = ReUITheme.color("border")
    local scrollOffset = -content:getY()

    if #self.entries > 0 then
        local totalHeight = 0
        for _, entry in ipairs(self.entries) do totalHeight = totalHeight + entry.height end
        self:drawRect(RAIL_X, 0 - scrollOffset, 1, totalHeight, border.a, border.r, border.g, border.b)
    end

    local y = 0
    for _, entry in ipairs(self.entries) do
        local color = ReUITheme.color(entry.colorRole)
        local dotY = y + 4 - scrollOffset
        if dotY > -DOT_SIZE and dotY < self.height then
            self:drawRect(RAIL_X - DOT_SIZE / 2 + 1, dotY, DOT_SIZE, DOT_SIZE, color.a, color.r, color.g, color.b)
        end
        y = y + entry.height
    end
end
