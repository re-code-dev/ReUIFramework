require "ReUI/core/ReUITheme"
require "ReUI/components/ReUIToast"

-- Screen-corner toast stack: top-level widgets (not children of any
-- window), auto-relayouts on add/remove. One global stack, like
-- ReUIFocusManager/ReUIDockManager.
ReUIToastManager = ReUIToastManager or {}
ReUIToastManager.stack = ReUIToastManager.stack or {}
ReUIToastManager.corner = ReUIToastManager.corner or "topRight"
ReUIToastManager.margin = ReUIToastManager.margin or 16
ReUIToastManager.gap = ReUIToastManager.gap or 10

function ReUIToastManager:show(message, options)
    options = options or {}
    options.message = message

    local toast = ReUIToast:new(options)
    toast:initialise()
    toast:createChildren()
    toast:addToUIManager()

    table.insert(self.stack, 1, toast)
    self:relayout()
    return toast
end

function ReUIToastManager:remove(toast)
    for i, t in ipairs(self.stack) do
        if t == toast then table.remove(self.stack, i); break end
    end
    if toast.removeFromUIManager then toast:removeFromUIManager() end
    self:relayout()
end

function ReUIToastManager:clear()
    for _, toast in ipairs(self.stack) do
        if toast.removeFromUIManager then toast:removeFromUIManager() end
    end
    self.stack = {}
end

function ReUIToastManager:relayout()
    local screenWidth = getCore():getScreenWidth()
    local y = self.margin
    for _, toast in ipairs(self.stack) do
        local x = screenWidth - toast.width - self.margin
        toast:setX(x)
        toast:setY(y)
        y = y + toast.height + self.gap
    end
end

function ReUIToastManager.success(message, duration) return ReUIToastManager:show(message, { role = "success", duration = duration or 4000 }) end
function ReUIToastManager.warning(message, duration) return ReUIToastManager:show(message, { role = "warning", duration = duration or 4000 }) end
function ReUIToastManager.danger(message, duration) return ReUIToastManager:show(message, { role = "danger", duration = duration or 4000 }) end
function ReUIToastManager.info(message, duration) return ReUIToastManager:show(message, { role = "info", duration = duration or 4000 }) end
function ReUIToastManager.loading(message) return ReUIToastManager:show(message, { role = "primary", showProgress = true, duration = nil }) end
