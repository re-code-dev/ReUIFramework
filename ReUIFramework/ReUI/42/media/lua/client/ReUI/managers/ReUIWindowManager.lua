ReUIWindowManager = ReUIWindowManager or {
    windows = {},
    activeWindow = nil,
    modalWindow = nil,
    nextId = 1
}

local function removeValue(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
            return
        end
    end
end

function ReUIWindowManager:register(window)
    if not window then return nil end

    if not window.reuiWindowId then
        window.reuiWindowId = "reui-window-" .. tostring(self.nextId)
        self.nextId = self.nextId + 1
    end

    for _, registered in ipairs(self.windows) do
        if registered == window then
            return window
        end
    end

    table.insert(self.windows, window)
    self:setActive(window)
    return window
end

function ReUIWindowManager:unregister(window)
    if not window then return end

    removeValue(self.windows, window)

    if self.activeWindow == window then
        self.activeWindow = self.windows[#self.windows]
    end

    if self.modalWindow == window then
        self.modalWindow = nil
    end
end

function ReUIWindowManager:setActive(window)
    if not window then return end

    self.activeWindow = window
    removeValue(self.windows, window)
    table.insert(self.windows, window)

    if window.bringToTop then
        window:bringToTop()
    end
end

function ReUIWindowManager:open(window, options)
    if not window then return nil end
    options = options or {}

    self:register(window)
    window:setVisible(true)

    if options.center ~= false and window.centerOnScreen then
        window:centerOnScreen()
    end

    if not window:isReallyVisible() then
        window:addToUIManager()
    end

    self:setActive(window)
    return window
end

function ReUIWindowManager:close(window)
    if not window then return end

    window:setVisible(false)
    if window.removeFromUIManager then
        window:removeFromUIManager()
    end

    self:unregister(window)

    if window.onReUIClose then
        window:onReUIClose()
    end
end

function ReUIWindowManager:minimize(window)
    if not window or window.reuiMinimized then return end

    window.reuiRestoreHeight = window:getHeight()
    window.reuiRestoreWidth = window:getWidth()
    window.reuiMinimized = true
    window:setHeight(window:getTitleBarHeight())

    if window.onReUIMinimize then
        window:onReUIMinimize()
    end
end

function ReUIWindowManager:restore(window)
    if not window or not window.reuiMinimized then return end

    window.reuiMinimized = false
    window:setWidth(window.reuiRestoreWidth or window:getWidth())
    window:setHeight(window.reuiRestoreHeight or 300)

    if window.onReUIRestore then
        window:onReUIRestore()
    end

    self:setActive(window)
end

function ReUIWindowManager:toggleMinimize(window)
    if not window then return end

    if window.reuiMinimized then
        self:restore(window)
    else
        self:minimize(window)
    end
end

function ReUIWindowManager:openModal(window)
    if not window then return nil end

    if self.modalWindow and self.modalWindow ~= window then
        self:close(self.modalWindow)
    end

    window.reuiIsModal = true
    self.modalWindow = window
    return self:open(window, { center = true })
end

function ReUIWindowManager:closeModal()
    if self.modalWindow then
        self:close(self.modalWindow)
    end
end

function ReUIWindowManager:canInteract(window)
    return self.modalWindow == nil or self.modalWindow == window
end

function ReUIWindowManager:getWindowCount()
    return #self.windows
end

function ReUIWindowManager:getActiveWindow()
    return self.activeWindow
end

function ReUIWindowManager:getModalWindow()
    return self.modalWindow
end
