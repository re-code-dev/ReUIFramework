require "ISUI/ISPanel"
require "ReUI/components/ReUIButton"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- Prev / page numbers (with "..." collapsing) / Next. Purely a page-index
-- selector — callers own the actual data slicing.
ReUIPagination = ISPanel:derive("ReUIPagination")

local BUTTON_SIZE = 28
local GAP = 4

function ReUIPagination:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 300, height or BUTTON_SIZE)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.pageCount = math.max(1, tonumber(options.pageCount) or 1)
    o.currentPage = math.max(1, math.min(tonumber(options.currentPage) or 1, o.pageCount))
    o.target = options.target
    o.onChange = options.onChange
    o.buttons = {}

    ReUIComponent.apply(o, options)
    return o
end

function ReUIPagination:initialise()
    ISPanel.initialise(self)
end

function ReUIPagination:createChildren()
    ISPanel.createChildren(self)
    self:rebuild()
end

-- Which page numbers to render: first, last, current +-1, "..." elsewhere.
local function visiblePages(current, total)
    local pages = {}
    for i = 1, total do
        if i == 1 or i == total or math.abs(i - current) <= 1 then
            table.insert(pages, i)
        elseif pages[#pages] ~= "..." then
            table.insert(pages, "...")
        end
    end
    return pages
end

function ReUIPagination:rebuild()
    for _, button in ipairs(self.buttons) do
        self:removeChild(button)
    end
    self.buttons = {}

    local x = 0
    local prev = ReUIButton:new(x, 0, BUTTON_SIZE, BUTTON_SIZE, "<", self, ReUIPagination.onPrev)
    prev:setVariant("ghost")
    prev.enable = self.currentPage > 1
    prev:initialise(); prev:instantiate(); self:addChild(prev)
    table.insert(self.buttons, prev)
    x = x + BUTTON_SIZE + GAP

    for _, page in ipairs(visiblePages(self.currentPage, self.pageCount)) do
        if page == "..." then
            local label = ReUIButton:new(x, 0, BUTTON_SIZE, BUTTON_SIZE, "...", nil, nil)
            label:setVariant("ghost")
            label.enable = false
            label:initialise(); label:instantiate(); self:addChild(label)
            table.insert(self.buttons, label)
        else
            local button = ReUIButton:new(x, 0, BUTTON_SIZE, BUTTON_SIZE, tostring(page), self, ReUIPagination.onPageClicked)
            button.pageNumber = page
            button:setVariant(page == self.currentPage and "primary" or "ghost")
            button:initialise(); button:instantiate(); self:addChild(button)
            table.insert(self.buttons, button)
        end
        x = x + BUTTON_SIZE + GAP
    end

    local nextButton = ReUIButton:new(x, 0, BUTTON_SIZE, BUTTON_SIZE, ">", self, ReUIPagination.onNext)
    nextButton:setVariant("ghost")
    nextButton.enable = self.currentPage < self.pageCount
    nextButton:initialise(); nextButton:instantiate(); self:addChild(nextButton)
    table.insert(self.buttons, nextButton)
end

function ReUIPagination:setPage(page, notify)
    page = math.max(1, math.min(page, self.pageCount))
    if page == self.currentPage then return self end
    self.currentPage = page
    self:rebuild()
    if notify ~= false then
        if self.emit then self:emit("change", self.currentPage) end
        if self.onChange then
            if self.target then self.onChange(self.target, self, self.currentPage)
            else self.onChange(self, self.currentPage) end
        end
    end
    return self
end

function ReUIPagination:setPageCount(pageCount)
    self.pageCount = math.max(1, pageCount)
    self.currentPage = math.min(self.currentPage, self.pageCount)
    self:rebuild()
    return self
end

function ReUIPagination:onPrev() self:setPage(self.currentPage - 1) end
function ReUIPagination:onNext() self:setPage(self.currentPage + 1) end
function ReUIPagination:onPageClicked(button) self:setPage(button.pageNumber) end
