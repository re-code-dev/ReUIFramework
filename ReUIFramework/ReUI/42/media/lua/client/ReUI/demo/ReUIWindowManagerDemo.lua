require "ReUI/core/ReUI"
require "ReUI/components/ReUIWindow"
require "ReUI/components/ReUIButton"
require "ReUI/managers/ReUIWindowManager"

ReUI.WindowDemo = ReUI.WindowDemo or {}

local ToolWindow = ReUIWindow:derive("ReUIToolWindow")

function ToolWindow:new()
    local o = ReUIWindow.new(self, 0, 0, 420, 250, "Re:UI Tool Window")
    o.subtitle = "Managed"
    return o
end

function ToolWindow:createChildren()
    ReUIWindow.createChildren(self)

    local actions = {
        { "Dock L", ToolWindow.dockLeft }, { "Dock R", ToolWindow.dockRight },
        { "Dock T", ToolWindow.dockTop }, { "Dock B", ToolWindow.dockBottom },
        { "Float", ToolWindow.undock }
    }

    self.dockButtons = {}
    local buttonWidth = 68
    for i, action in ipairs(actions) do
        local button = ReUIButton:new(24 + (i - 1) * (buttonWidth + 6), 194, buttonWidth, 32, action[1], self, action[2])
        button:setVariant("ghost")
        button:initialise()
        button:instantiate()
        self:addChild(button)
        table.insert(self.dockButtons, button)
    end
end

function ToolWindow:render()
    ReUIWindow.render(self)

    if self.reuiMinimized then return end

    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")
    local primary = ReUITheme.color("primary")

    self:drawText("Window Manager is active", 24, 72,
        text.r, text.g, text.b, text.a, UIFont.Large)
    self:drawText("Drag near a screen edge to dock, or use the buttons below.", 24, 116,
        muted.r, muted.g, muted.b, muted.a, UIFont.Small)
    self:drawText("Active ID: " .. tostring(self.reuiWindowId or "pending")
        .. "   Docked: " .. tostring(self.reuiDockZone or "no"), 24, 158,
        primary.r, primary.g, primary.b, primary.a, UIFont.Small)
end

local ModalWindow = ReUIWindow:derive("ReUIModalWindow")

function ModalWindow:new()
    local o = ReUIWindow.new(self, 0, 0, 460, 250, "Modal Dialog", {
        showMinimizeButton = false
    })
    o.subtitle = "Input locked"
    return o
end

function ModalWindow:createChildren()
    ReUIWindow.createChildren(self)

    self.confirmButton = ReUIButton:new(24, 174, 196, 38, "Confirm", self, ModalWindow.onConfirm)
    self.confirmButton:setVariant("primary")
    self.confirmButton:initialise()
    self.confirmButton:instantiate()
    self:addChild(self.confirmButton)

    self.cancelButton = ReUIButton:new(240, 174, 196, 38, "Cancel", self, ModalWindow.onCancel)
    self.cancelButton:setVariant("secondary")
    self.cancelButton:initialise()
    self.cancelButton:instantiate()
    self:addChild(self.cancelButton)
end

function ModalWindow:render()
    ReUIWindow.render(self)

    local text = ReUITheme.color("text")
    local muted = ReUITheme.color("textMuted")

    self:drawText("Modal window test", 24, 72,
        text.r, text.g, text.b, text.a, UIFont.Large)
    self:drawText("Other managed windows cannot be activated until this dialog closes.", 24, 116,
        muted.r, muted.g, muted.b, muted.a, UIFont.Small)
end

function ModalWindow:onConfirm()
    ReUIWindowManager:closeModal()
end

function ModalWindow:onCancel()
    ReUIWindowManager:closeModal()
end

function ReUI.WindowDemo.openTool()
    if ReUI.WindowDemo.toolInstance then
        return ReUIWindowManager:open(ReUI.WindowDemo.toolInstance, { center = false })
    end

    local window = ToolWindow:new()
    window:initialise()
    window:addToUIManager()
    window:centerOnScreen()
    window:setX(window:getX() + 120)
    window:setY(window:getY() + 70)
    ReUIWindowManager:register(window)
    ReUI.WindowDemo.toolInstance = window
    return window
end

function ReUI.WindowDemo.openModal()
    local window = ModalWindow:new()
    window:initialise()
    window:createChildren()
    window:addToUIManager()
    window:centerOnScreen()
    ReUIWindowManager:register(window)
    ReUIWindowManager.modalWindow = window
    return window
end
