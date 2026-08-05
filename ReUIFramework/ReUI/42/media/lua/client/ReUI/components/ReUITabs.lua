require "ISUI/ISPanel"
require "ReUI/components/ReUIButton"
require "ReUI/components/ReUIPanel"
require "ReUI/core/ReUITheme"
require "ReUI/core/ReUIComponent"

-- A tab strip with one content page per tab. Pages are plain ReUIPanels
-- returned by :addTab(); callers populate them like any other container.
ReUITabs = ISPanel:derive("ReUITabs")

function ReUITabs:new(x, y, width, height, options)
    local o = ISPanel.new(self, x or 0, y or 0, width or 300, height or 200)
    setmetatable(o, self)
    self.__index = self

    options = options or {}
    o:noBackground()
    o.tabHeight = tonumber(options.tabHeight) or ReUITheme.metric("controlHeight", 32)
    o.tabs = {}
    o.activeIndex = nil
    o.target = options.target
    o.onChange = options.onChange

    ReUIComponent.apply(o, options)
    return o
end

function ReUITabs:addTab(label)
    local index = #self.tabs + 1

    local tabButton = ReUIButton:new(0, 0, 80, self.tabHeight, label, self, ReUITabs.onTabClicked)
    tabButton.tabIndex = index
    tabButton:setVariant("ghost")
    tabButton:initialise()
    tabButton:instantiate()
    self:addChild(tabButton)

    local page = ReUIPanel:new(0, self.tabHeight, self.width, math.max(0, self.height - self.tabHeight), {
        drawBackground = false, drawBorder = false
    })
    page:initialise()
    page:instantiate()
    page:setVisible(false)
    self:addChild(page)

    table.insert(self.tabs, { label = tostring(label), button = tabButton, page = page })
    self:layoutTabs()

    if #self.tabs == 1 then
        self:setActiveTab(1)
    end

    return page
end

function ReUITabs:layoutTabs()
    local x = 0
    for _, tab in ipairs(self.tabs) do
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, tab.label)
        local buttonWidth = math.max(60, textWidth + 24)
        tab.button:setX(x)
        tab.button:setY(0)
        tab.button:setWidth(buttonWidth)
        tab.button:setHeight(self.tabHeight)
        x = x + buttonWidth
    end
end

function ReUITabs:onTabClicked(button)
    self:setActiveTab(button.tabIndex)
end

function ReUITabs:setActiveTab(index)
    if index < 1 or index > #self.tabs then return self end

    self.activeIndex = index
    for i, tab in ipairs(self.tabs) do
        local active = i == index
        tab.button:setSelected(active)
        tab.page:setVisible(active)
        if active then
            tab.page:setWidth(self.width)
            tab.page:setHeight(math.max(0, self.height - self.tabHeight))
        end
    end

    local tab = self.tabs[index]
    if self.emit then self:emit("change", index, tab.label) end
    if self.onChange then
        if self.target then
            self.onChange(self.target, self, index, tab.label)
        else
            self.onChange(self, index, tab.label)
        end
    end

    return self
end

function ReUITabs:getActivePage()
    local tab = self.tabs[self.activeIndex]
    return tab and tab.page or nil
end

function ReUITabs:setSize(width, height)
    self:setWidth(width)
    self:setHeight(height)
    self:layoutTabs()
    local active = self.tabs[self.activeIndex]
    if active then
        active.page:setWidth(width)
        active.page:setHeight(math.max(0, height - self.tabHeight))
    end
    return self
end

function ReUITabs:prerender()
    local border = ReUITheme.color("border")
    self:drawRect(0, self.tabHeight - 1, self.width, 1, border.a, border.r, border.g, border.b)
end
