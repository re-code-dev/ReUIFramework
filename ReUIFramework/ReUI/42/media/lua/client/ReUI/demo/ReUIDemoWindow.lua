require "ReUI/core/ReUI"
require "ReUI/components/ReUIWindow"
require "ReUI/components/ReUIButton"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/components/ReUICard"
require "ReUI/components/ReUIDivider"
require "ReUI/components/ReUICheckbox"
require "ReUI/components/ReUISwitch"
require "ReUI/components/ReUIProgressBar"
require "ReUI/components/ReUIImage"
require "ReUI/components/ReUINumberBox"
require "ReUI/components/ReUIDropdown"
require "ReUI/components/ReUITabs"
require "ReUI/components/ReUIListView"
require "ReUI/components/ReUITreeView"
require "ReUI/components/ReUIColorPicker"
require "ReUI/components/ReUIPropertyGrid"
require "ReUI/components/ReUIInspector"
require "ReUI/components/ReUIFileBrowser"
require "ReUI/layout/ReUIVBox"
require "ReUI/layout/ReUIHBox"
require "ReUI/layout/ReUIScrollContainer"
require "ReUI/demo/ReUIWindowManagerDemo"
require "ReUI/managers/ReUIWindowManager"

ReUI.Demo = ReUI.Demo or {}
ReUI.Demo.instance = nil

local DemoWindow = ReUIWindow:derive("ReUIDemoWindow")

function DemoWindow:new()
    local o = ReUIWindow.new(self, 0, 0, 1040, 650, "Re:UI Showcase")
    o.subtitle = "Foundation v" .. ReUI.getVersion()
    o.activePage = "Buttons"
    o.navButtons = {}
    o.lastWidth = 0
    o.lastHeight = 0
    return o
end

function DemoWindow:initialise()
    ReUIWindow.initialise(self)
end

function DemoWindow:createChildren()
    ReUIWindow.createChildren(self)

    self.shell = ReUIHBox:new(0, 0, 100, 100, {
        spacing = "md", align = "stretch", drawBackground = false, drawBorder = false
    })
    self.shell:initialise()
    self.shell:instantiate()
    self:addChild(self.shell)

    self.sidebar = ReUIVBox:new(0, 0, ReUITheme.metrics.sidebarWidth, 100, {
        padding = "sm", spacing = ReUITheme.metrics.navItemGap, align = "stretch",
        backgroundRole = "surface", borderRole = "border"
    })
    self.main = ReUIPanel:new(0, 0, 560, 100, { backgroundRole = "surface", borderRole = "border" })
    self.inspector = ReUIPanel:new(0, 0, ReUITheme.metrics.inspectorWidth, 100, {
        backgroundRole = "surface", borderRole = "border"
    })

    self.shell:add(self.sidebar, { width = ReUITheme.metrics.sidebarWidth })
    self.shell:add(self.main, { grow = 1 })
    self.shell:add(self.inspector, { width = ReUITheme.metrics.inspectorWidth })

    self:createNavigation()
    self:createPreviewButtons()
    self:createTypographyPreview()
    self:createCardPreview()
    self:createFormsPreview()
    self:createControlsPreview()
    self:createStructuresPreview()
    self:createAdvancedPreview()
    self:createWindowActions()
    self:setPage("Buttons")
    self:updateResponsiveLayout(true)
    ReUIWindowManager:register(self)
end

function DemoWindow:createNavigation()
    self.sidebarHeaderSpacer = ReUIPanel:new(0, 0, 100, ReUITheme.metrics.sidebarHeaderHeight, {
        drawBackground = false, drawBorder = false
    })
    self.sidebar:add(self.sidebarHeaderSpacer, { height = ReUITheme.metrics.sidebarHeaderHeight })

    local pages = { "Buttons", "Typography", "Layouts", "Cards", "Forms", "Controls", "Structures", "Advanced", "Notifications", "Themes", "Animations", "Windows" }
    for _, page in ipairs(pages) do
        local button = ReUIButton:new(0, 0, 100, ReUITheme.metrics.navItemHeight, page, self, DemoWindow.onNavigate)
        button.pageName = page
        button:setVariant("ghost")
        button:setTextAlignment("left")
        button.textPadding = 12
        self.sidebar:add(button, { height = ReUITheme.metrics.navItemHeight })
        table.insert(self.navButtons, button)
    end
end

function DemoWindow:createPreviewButtons()
    self.previewButtons = {}
    local definitions = {
        { title = "Primary", variant = "primary" }, { title = "Secondary", variant = "secondary" },
        { title = "Success", variant = "success" }, { title = "Warning", variant = "warning" },
        { title = "Danger", variant = "danger" }, { title = "Disabled", variant = "secondary", disabled = true }
    }
    for _, definition in ipairs(definitions) do
        local button = ReUIButton:new(0, 0, 150, 36, definition.title, self, DemoWindow.onPreviewClick)
        button:setVariant(definition.variant)
        button.enable = definition.disabled ~= true
        button:setTooltip("Variant: " .. definition.variant .. " — hover to see ReUITooltip")
        button:setVisible(false)
        button:initialise(); button:instantiate(); self.main:addChild(button)
        table.insert(self.previewButtons, button)
    end
end


function DemoWindow:createTypographyPreview()
    self.typographyControls = {}

    local labels = {
        ReUILabel:new(0, 0, 260, 34, "Large heading", {
            font = UIFont.Large, colorRole = "text"
        }),
        ReUILabel:new(0, 0, 260, 28, "Medium section title", {
            font = UIFont.Medium, colorRole = "text"
        }),
        ReUILabel:new(0, 0, 260, 24, "Muted supporting text", {
            font = UIFont.Small, colorRole = "textMuted"
        }),
        ReUILabel:new(0, 0, 260, 24,
            "This deliberately long label demonstrates automatic ellipsis inside constrained layouts.", {
            font = UIFont.Small, colorRole = "primary", ellipsis = true
        })
    }

    for _, label in ipairs(labels) do
        label:setVisible(false)
        label:initialise()
        label:instantiate()
        self.main:addChild(label)
        table.insert(self.typographyControls, label)
    end

    self.typographyDivider = ReUIDivider:new(0, 0, 300, 24, {
        label = "SECTION DIVIDER"
    })
    self.typographyDivider:setVisible(false)
    self.typographyDivider:initialise()
    self.typographyDivider:instantiate()
    self.main:addChild(self.typographyDivider)
end

function DemoWindow:createCardPreview()
    self.cardPreview = ReUICard:new(0, 0, 320, 220, {
        title = "Survivor Profile",
        subtitle = "Reusable structured container",
        footerText = "Last updated moments ago",
        accentRole = "primary"
    })
    self.cardPreview:setVisible(false)
    self.cardPreview:initialise()
    self.cardPreview:instantiate()
    self.main:addChild(self.cardPreview)

    self.cardName = ReUILabel:new(0, 0, 200, 26, "Alex Mercer", {
        font = UIFont.Medium
    })
    self.cardStatus = ReUILabel:new(0, 0, 200, 24, "Status: Healthy", {
        colorRole = "success"
    })
    self.cardLocation = ReUILabel:new(0, 0, 250, 24, "Location: Muldraugh Safehouse", {
        colorRole = "textMuted"
    })

    for _, label in ipairs({ self.cardName, self.cardStatus, self.cardLocation }) do
        label:setVisible(false)
        label:initialise()
        label:instantiate()
        self.cardPreview:addChild(label)
    end
end


function DemoWindow:createFormsPreview()
    self.formControls = {}

    self.formCheckbox = ReUICheckbox:new(0, 0, 320, 36, "Enable survival notifications", {
        value = true
    })
    self.formCheckbox:on("change", function(control, value)
        self.lastAction = "Notifications " .. (value and "enabled" or "disabled")
        self.formProgress:setValue(value and 72 or 32)
    end)

    self.formSwitch = ReUISwitch:new(0, 0, 320, 36, "Compact interface", {
        value = false
    })
    self.formSwitch:on("change", function(control, value)
        self.lastAction = "Compact interface " .. (value and "enabled" or "disabled")
    end)

    self.formDisabledCheckbox = ReUICheckbox:new(0, 0, 320, 36, "Server-enforced option", {
        value = true,
        enabled = false
    })

    self.formProgress = ReUIProgressBar:new(0, 0, 360, 26, {
        value = 72,
        fillRole = "success"
    })

    self.formDangerProgress = ReUIProgressBar:new(0, 0, 360, 26, {
        value = 24,
        fillRole = "danger",
        formatter = function(control, value, progress)
            return "Condition " .. tostring(math.floor(value)) .. " / 100"
        end
    })

    for _, control in ipairs({
        self.formCheckbox,
        self.formSwitch,
        self.formDisabledCheckbox,
        self.formProgress,
        self.formDangerProgress
    }) do
        control:setVisible(false)
        control:initialise()
        control:instantiate()
        self.main:addChild(control)
        table.insert(self.formControls, control)
    end
end

function DemoWindow:createControlsPreview()
    self.controlsImage = ReUIImage:new(0, 0, 64, 64, {
        texturePath = "media/ui/Search_Icon_On.png",
        scaleMode = "contain",
        drawBackground = true,
        drawBorder = true,
        backgroundRole = "surfaceAlt"
    })

    self.controlsNumberBox = ReUINumberBox:new(0, 0, 150, ReUITheme.metrics.controlHeight, {
        value = 10, min = 0, max = 99, step = 1
    })
    self.controlsNumberBox:on("change", function(control, value)
        self.lastAction = "Quantity set to " .. tostring(value)
    end)

    self.controlsDropdown = ReUIDropdown:new(0, 0, 200, ReUITheme.metrics.controlHeight, {
        options = { "Small", "Medium", "Large", "Extra Large" },
        placeholder = "Choose a size"
    })
    self.controlsDropdown:on("change", function(control, value)
        self.lastAction = "Size set to " .. tostring(value)
    end)

    self.controlsScroll = ReUIScrollContainer:new(0, 0, 300, 180, {
        backgroundRole = "surface", borderRole = "border"
    })

    self.controlsInteractive = {
        self.controlsImage,
        self.controlsNumberBox,
        self.controlsDropdown,
        self.controlsScroll
    }

    for _, control in ipairs(self.controlsInteractive) do
        control:setVisible(false)
        control:initialise()
        control:instantiate()
        self.main:addChild(control)
    end

    local scrollContent = self.controlsScroll:getContent()
    local rowHeight = 28
    local rowCount = 14
    for i = 1, rowCount do
        local row = ReUILabel:new(8, (i - 1) * rowHeight, 260, rowHeight,
            "Scrollable row #" .. i, {
                colorRole = (i % 2 == 0) and "textMuted" or "text"
            })
        row:initialise()
        row:instantiate()
        scrollContent:addChild(row)
    end
    self.controlsScroll:setContentHeight(rowCount * rowHeight)
end

function DemoWindow:createStructuresPreview()
    self.structuresTabs = ReUITabs:new(0, 0, 340, 300, {})
    self.structuresTabs:setVisible(false)
    self.structuresTabs:initialise()
    self.structuresTabs:instantiate()
    self.main:addChild(self.structuresTabs)
    self.structuresInteractive = { self.structuresTabs }

    local listPage = self.structuresTabs:addTab("List")
    self.structuresList = ReUIListView:new(8, 8, 300, 250, {})
    self.structuresList:initialise()
    self.structuresList:instantiate()
    listPage:addChild(self.structuresList)
    for i = 1, 10 do
        self.structuresList:addItem("Survivor #" .. i, i)
    end
    self.structuresList:on("select", function(control, data, label)
        self.lastAction = "Selected " .. label
    end)

    local treePage = self.structuresTabs:addTab("Tree")
    self.structuresTree = ReUITreeView:new(8, 8, 300, 250, {})
    self.structuresTree:initialise()
    self.structuresTree:instantiate()
    treePage:addChild(self.structuresTree)

    local inventory = self.structuresTree:addNode(nil, "Inventory")
    local weapons = self.structuresTree:addNode(inventory, "Weapons")
    self.structuresTree:addNode(weapons, "Axe")
    self.structuresTree:addNode(weapons, "Crowbar")
    local food = self.structuresTree:addNode(inventory, "Food")
    self.structuresTree:addNode(food, "Canned Beans")
    self.structuresTree:addNode(food, "Water Bottle")
    self.structuresTree:on("select", function(control, data, label)
        self.lastAction = "Selected " .. label
    end)
end

function DemoWindow:createAdvancedPreview()
    self.advancedColorPicker = ReUIColorPicker:new(0, 0, 220, 120, { r = 0.28, g = 0.70, b = 1.00 })
    self.advancedColorPicker:on("change", function(control, r, g, b)
        self.lastAction = string.format("Accent set to #%02X%02X%02X",
            math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
    end)

    self.advancedGrid = ReUIPropertyGrid:new(0, 0, 260, 140, { labelWidth = 100 })
    self.advancedTarget = ReUIPanel:new(0, 0, 90, 60, { backgroundRole = "primaryMuted", borderRole = "primary" })
    self.advancedInspector = ReUIInspector:new(0, 0, 220, 140, { labelWidth = 90 })

    self.advancedBrowser = ReUIFileBrowser:new(0, 0, 200, 140, {
        target = self, onSelectFile = DemoWindow.onAdvancedFileSelected
    })

    self.advancedInteractive = {
        self.advancedColorPicker,
        self.advancedGrid,
        self.advancedTarget,
        self.advancedInspector,
        self.advancedBrowser
    }

    -- Every control must be instantiate()d (so ReUIScrollContainer-based
    -- ones have their internal content panel) before addProperty/addItem/
    -- inspect/setRoot are called below.
    for _, control in ipairs(self.advancedInteractive) do
        control:setVisible(false)
        control:initialise()
        control:instantiate()
        self.main:addChild(control)
    end

    self.advancedGrid:addProperty("difficulty", "Difficulty", "dropdown", "Normal",
        { options = { "Easy", "Normal", "Hard" } })
    self.advancedGrid:addProperty("volume", "Volume", "number", 80, { min = 0, max = 100, step = 5 })
    self.advancedGrid:addProperty("debug", "Debug mode", "checkbox", false)
    self.advancedGrid:on("change", function(control, key, value)
        self.lastAction = "Property " .. key .. " = " .. tostring(value)
    end)

    self.advancedInspector:inspect(self.advancedTarget)

    self.advancedBrowser:setRoot({
        { name = "42", isDirectory = true, children = {
            { name = "media", isDirectory = true, children = {
                { name = "lua", isDirectory = true, children = {
                    { name = "client", isDirectory = true, children = {
                        { name = "ReUI", isDirectory = true, children = {
                            { name = "ReUIButton.lua", isDirectory = false },
                            { name = "ReUISlider.lua", isDirectory = false },
                            { name = "ReUITheme.lua", isDirectory = false }
                        } }
                    } }
                } }
            } }
        } },
        { name = "mod.info", isDirectory = false }
    })
end

function DemoWindow:onAdvancedFileSelected(control, entry)
    self.lastAction = "Selected file: " .. entry.name
end

function DemoWindow:createWindowActions()
    self.windowActions = {}
    local actions = {
        { "Open managed window", "primary", DemoWindow.onOpenToolWindow },
        { "Open modal dialog", "secondary", DemoWindow.onOpenModal }
    }
    for _, action in ipairs(actions) do
        local button = ReUIButton:new(0, 0, 220, 38, action[1], self, action[3])
        button:setVariant(action[2]); button:setVisible(false)
        button:initialise(); button:instantiate(); self.main:addChild(button)
        table.insert(self.windowActions, button)
    end
end

function DemoWindow:onOpenToolWindow() ReUI.WindowDemo.openTool(); self.lastAction = "Managed tool window opened" end
function DemoWindow:onOpenModal() ReUI.WindowDemo.openModal(); self.lastAction = "Modal dialog opened" end
function DemoWindow:onNavigate(button) self:setPage(button.pageName) end
function DemoWindow:onPreviewClick(button) self.lastAction = button.title .. " clicked" end

function DemoWindow:setPage(page)
    self.activePage = page; self.lastAction = nil
    for _, button in ipairs(self.navButtons) do button:setSelected(button.pageName == page) end
    for _, button in ipairs(self.previewButtons) do button:setVisible(page == "Buttons") end
    for _, label in ipairs(self.typographyControls) do label:setVisible(page == "Typography") end
    self.typographyDivider:setVisible(page == "Typography")
    self.cardPreview:setVisible(page == "Cards")
    self.cardName:setVisible(page == "Cards")
    self.cardStatus:setVisible(page == "Cards")
    self.cardLocation:setVisible(page == "Cards")
    for _, control in ipairs(self.formControls) do control:setVisible(page == "Forms") end
    for _, control in ipairs(self.controlsInteractive) do control:setVisible(page == "Controls") end
    for _, control in ipairs(self.structuresInteractive) do control:setVisible(page == "Structures") end
    for _, control in ipairs(self.advancedInteractive) do control:setVisible(page == "Advanced") end
    for _, button in ipairs(self.windowActions) do button:setVisible(page == "Windows") end
end

function DemoWindow:updateResponsiveLayout(force)
    if not force and self.lastWidth == self.width and self.lastHeight == self.height then return end
    self.lastWidth, self.lastHeight = self.width, self.height

    local inset = ReUITheme.metrics.contentInset
    local top = ReUITheme.metrics.titleBarHeight + inset
    local height = math.max(300, self.height - top - inset)
    self.shell:setX(inset); self.shell:setY(top)
    self.shell:setWidth(math.max(600, self.width - inset * 2)); self.shell:setHeight(height)

    local available = self.shell.width
    local inspectorWidth = ReUITheme.metrics.inspectorWidth
    local sidebarWidth = ReUITheme.metrics.sidebarWidth
    if available < 860 then inspectorWidth = 200 end
    if available < 760 then sidebarWidth = 170 end

    self.sidebar.layout.width = sidebarWidth
    self.inspector.layout.width = inspectorWidth
    self.shell:invalidateLayout(); self.shell:layoutNow()
end

function DemoWindow:layoutInteractiveControls()
    local inset, gap = 26, 14
    if self.activePage == "Buttons" then
        local width = math.max(120, (self.main.width - inset * 2 - gap) / 2)
        for i, button in ipairs(self.previewButtons) do
            local column, row = (i - 1) % 2, math.floor((i - 1) / 2)
            button:setX(inset + column * (width + gap)); button:setY(150 + row * 50)
            button:setWidth(width); button:setHeight(36)
        end
    elseif self.activePage == "Typography" then
        local y = 132
        for i, label in ipairs(self.typographyControls) do
            label:setX(inset)
            label:setY(y)
            label:setWidth(math.max(180, self.main.width - inset * 2))
            if i == 4 then
                label:setWidth(math.min(330, self.main.width - inset * 2))
            end
            y = y + label:getHeight() + 12
        end
        self.typographyDivider:setX(inset)
        self.typographyDivider:setY(y + 12)
        self.typographyDivider:setWidth(math.max(180, self.main.width - inset * 2))
        self.typographyDivider:setHeight(26)
    elseif self.activePage == "Cards" then
        local cardWidth = math.min(420, self.main.width - inset * 2)
        self.cardPreview:setX(inset)
        self.cardPreview:setY(132)
        self.cardPreview:setWidth(cardWidth)
        self.cardPreview:setHeight(250)

        local bounds = self.cardPreview:getContentBounds()
        self.cardName:setX(bounds.x)
        self.cardName:setY(bounds.y)
        self.cardName:setWidth(bounds.width)
        self.cardStatus:setX(bounds.x)
        self.cardStatus:setY(bounds.y + 38)
        self.cardStatus:setWidth(bounds.width)
        self.cardLocation:setX(bounds.x)
        self.cardLocation:setY(bounds.y + 70)
        self.cardLocation:setWidth(bounds.width)
    elseif self.activePage == "Forms" then
        local controlWidth = math.max(240, math.min(420, self.main.width - inset * 2))
        local y = 142
        for _, control in ipairs({
            self.formCheckbox,
            self.formSwitch,
            self.formDisabledCheckbox
        }) do
            control:setX(inset)
            control:setY(y)
            control:setWidth(controlWidth)
            control:setHeight(36)
            y = y + 50
        end

        self.formProgress:setX(inset)
        self.formProgress:setY(y + 14)
        self.formProgress:setWidth(controlWidth)
        self.formProgress:setHeight(26)

        self.formDangerProgress:setX(inset)
        self.formDangerProgress:setY(y + 62)
        self.formDangerProgress:setWidth(controlWidth)
        self.formDangerProgress:setHeight(26)
    elseif self.activePage == "Controls" then
        self.controlsImage:setX(inset); self.controlsImage:setY(140)
        self.controlsImage:setWidth(64); self.controlsImage:setHeight(64)

        self.controlsNumberBox:setX(inset + 64 + gap); self.controlsNumberBox:setY(140)
        self.controlsNumberBox:setWidth(150); self.controlsNumberBox:setHeight(ReUITheme.metrics.controlHeight)

        self.controlsDropdown:setX(inset + 64 + gap); self.controlsDropdown:setY(140 + ReUITheme.metrics.controlHeight + 10)
        self.controlsDropdown:setWidth(200); self.controlsDropdown:setHeight(ReUITheme.metrics.controlHeight)

        local scrollWidth = math.min(320, self.main.width - inset * 2)
        self.controlsScroll:setX(inset); self.controlsScroll:setY(232)
        self.controlsScroll:setWidth(scrollWidth); self.controlsScroll:setHeight(180)
    elseif self.activePage == "Structures" then
        local tabsWidth = math.min(340, self.main.width - inset * 2)
        self.structuresTabs:setX(inset); self.structuresTabs:setY(140)
        self.structuresTabs:setSize(tabsWidth, 300)
    elseif self.activePage == "Advanced" then
        self.advancedColorPicker:setX(inset); self.advancedColorPicker:setY(140)
        self.advancedColorPicker:setWidth(220); self.advancedColorPicker:setHeight(120)

        self.advancedGrid:setX(inset + 220 + gap); self.advancedGrid:setY(140)
        self.advancedGrid:setWidth(260); self.advancedGrid:setHeight(140)

        self.advancedTarget:setX(inset); self.advancedTarget:setY(280)
        self.advancedTarget:setWidth(90); self.advancedTarget:setHeight(60)

        self.advancedInspector:setX(inset + 110); self.advancedInspector:setY(280)
        self.advancedInspector:setWidth(220); self.advancedInspector:setHeight(140)

        self.advancedBrowser:setX(inset + 110 + 220 + gap); self.advancedBrowser:setY(280)
        self.advancedBrowser:setWidth(200); self.advancedBrowser:setHeight(140)
    elseif self.activePage == "Windows" then
        for i, button in ipairs(self.windowActions) do
            button:setX(inset); button:setY(150 + ((i - 1) * 54))
            button:setWidth(math.min(280, self.main.width - inset * 2)); button:setHeight(38)
        end
    end
end

function DemoWindow:prerender()
    ReUIWindow.prerender(self)
    self:updateResponsiveLayout(false)
    self:layoutInteractiveControls()
end

function DemoWindow:renderSidebar()
    local muted = ReUITheme.color("textMuted")
    ReUITheme.drawTextCenteredY(self.sidebar, "COMPONENTS", 12, 8,
        ReUITheme.metrics.sidebarHeaderHeight, UIFont.Small, muted)
end

function DemoWindow:renderMain()
    local text, muted = ReUITheme.color("text"), ReUITheme.color("textMuted")
    local primary, border = ReUITheme.color("primary"), ReUITheme.color("border")
    local raised = ReUITheme.color("surfaceAlt")

    self.main:drawText(self.activePage, 26, 25, text.r, text.g, text.b, text.a, UIFont.Large)
    self.main:drawText("Interactive component preview", 26, 59, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    self.main:drawRect(26, 92, self.main.width - 52, 1, border.a, border.r, border.g, border.b)

    if self.activePage == "Buttons" then
        self.main:drawText("Variants", 26, 116, text.r, text.g, text.b, text.a, UIFont.Medium)
        local infoY = 322
        self.main:drawRect(26, infoY, self.main.width - 52, 116, raised.a, raised.r, raised.g, raised.b)
        self.main:drawRectBorder(26, infoY, self.main.width - 52, 116, border.a, border.r, border.g, border.b)
        self.main:drawText("Usage", 42, infoY + 17, text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText('button:setVariant("primary")', 42, infoY + 49, primary.r, primary.g, primary.b, primary.a, UIFont.Small)
        self.main:drawText("All reusable colors are resolved through semantic theme roles.", 42, infoY + 77, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Typography" then
        self.main:drawText("Labels & Dividers", 26, 108, text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("Font roles, alignment, semantic colors and constrained text.", 26, 366,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Cards" then
        self.main:drawText("Structured containers", 26, 108, text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("Cards provide header, content and footer regions with optional accents.", 26, 408,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Forms" then
        self.main:drawText("Interactive form controls", 26, 108,
            text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("Checkboxes and switches emit change events; progress bars use normalized ranges.", 26, 398,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        self.main:drawText('control:on("change", function(control, value) ... end)', 26, 426,
            primary.r, primary.g, primary.b, primary.a, UIFont.Small)
    elseif self.activePage == "Controls" then
        self.main:drawText("Image, NumberBox, Dropdown & ScrollContainer", 26, 116,
            text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("Scroll containers clip their content with setStencilRect.", 26, 420,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Structures" then
        self.main:drawText("Tabs, ListView & TreeView", 26, 116, text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("ListView and TreeView are both built on ReUIScrollContainer.", 26, 460,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Advanced" then
        self.main:drawText("ColorPicker, PropertyGrid, Inspector & FileBrowser", 26, 116,
            text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("The Inspector edits the small swatch panel live. FileBrowser walks a", 26, 430,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        self.main:drawText("caller-supplied virtual tree, not the real disk.", 26, 448,
            muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    elseif self.activePage == "Windows" then
        self.main:drawText("Window Manager", 26, 116, text.r, text.g, text.b, text.a, UIFont.Medium)
        self.main:drawText("Open independent managed windows or test modal focus locking.", 26, 246, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        self.main:drawText("Registration, focus, Z-order, minimize, restore and modal state.", 26, 274, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    else
        self.main:drawText("This module is reserved for the next Re:UI milestone.", 26, 126, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        self.main:drawText("The navigation and inspector are already prepared for it.", 26, 154, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    end

    if self.lastAction then
        local success = ReUITheme.color("success")
        self.main:drawText(self.lastAction, 26, self.main.height - 34, success.r, success.g, success.b, success.a, UIFont.Small)
    end
end

function DemoWindow:renderInspector()
    local text, muted = ReUITheme.color("text"), ReUITheme.color("textMuted")
    local border, primary = ReUITheme.color("border"), ReUITheme.color("primary")
    local x, innerWidth = 16, self.inspector.width - 32

    self.inspector:drawText("INSPECTOR", x, 16, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    self.inspector:drawText(self.activePage, x, 50, text.r, text.g, text.b, text.a, UIFont.Medium)
    self.inspector:drawRect(x, 82, innerWidth, 1, border.a, border.r, border.g, border.b)

    local rows = {
        { "Type",
            self.activePage == "Buttons" and "ReUIButton"
            or self.activePage == "Typography" and "ReUILabel"
            or self.activePage == "Cards" and "ReUICard"
            or self.activePage == "Forms" and "ReUICheckbox"
            or self.activePage == "Controls" and "ReUIDropdown"
            or self.activePage == "Structures" and "ReUITabs"
            or self.activePage == "Advanced" and "ReUIInspector"
            or "ShowcasePage" },
        { "Theme", "ReCodeDark" }, { "Spacing", "md / 12px" }, { "State", "Ready" },
        { "Windows", tostring(ReUIWindowManager:getWindowCount()) }, { "Version", ReUI.getVersion() }
    }

    local y, rowHeight = 102, 48
    for _, row in ipairs(rows) do
        self.inspector:drawText(row[1], x, y, muted.r, muted.g, muted.b, muted.a, UIFont.Small)
        self.inspector:drawText(row[2], x, y + 18, text.r, text.g, text.b, text.a, UIFont.Small)
        y = y + rowHeight
    end

    self.inspector:drawRect(x, y + 2, innerWidth, 1, border.a, border.r, border.g, border.b)
    self.inspector:drawText("Layout tree", x, y + 22, text.r, text.g, text.b, text.a, UIFont.Medium)

    local tree = {
        { "Window", primary, 0 }, { "HBox shell", muted, 1 }, { "Sidebar", muted, 2 },
        { "Preview", muted, 2 }, { "Inspector", muted, 2 }
    }
    local treeY = y + 54
    for _, item in ipairs(tree) do
        self.inspector:drawText(string.rep("  ", item[3]) .. item[1], x, treeY,
            item[2].r, item[2].g, item[2].b, item[2].a, UIFont.Small)
        treeY = treeY + 21
    end
end

function DemoWindow:render()
    ReUIWindow.render(self)
    self:renderSidebar(); self:renderMain(); self:renderInspector()
end

function ReUI.Demo.show()
    if ReUI.Demo.instance then
        ReUI.Demo.instance:setVisible(true); ReUI.Demo.instance:bringToTop(); return
    end
    local window = DemoWindow:new(); window:initialise(); window:addToUIManager(); window:centerOnScreen()
    ReUIWindowManager:register(window); ReUI.Demo.instance = window
end
function ReUI.Demo.hide() if ReUI.Demo.instance then ReUI.Demo.instance:setVisible(false) end end
function ReUI.Demo.toggle()
    if ReUI.Demo.instance and ReUI.Demo.instance:getIsVisible() then ReUI.Demo.hide() else ReUI.Demo.show() end
end
