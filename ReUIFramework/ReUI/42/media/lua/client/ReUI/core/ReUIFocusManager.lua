ReUIFocusManager = ReUIFocusManager or {
    controls = {},
    active = nil
}

local function usable(control)
    if not control then return false end
    if control.isVisible and not control:isVisible() then return false end
    if control.isEnabled and not control:isEnabled() then return false end
    return true
end

function ReUIFocusManager.register(control, order)
    if not control then return end
    ReUIFocusManager.unregister(control)
    table.insert(ReUIFocusManager.controls, {
        control = control,
        order = tonumber(order) or (#ReUIFocusManager.controls + 1)
    })
    table.sort(ReUIFocusManager.controls, function(a, b) return a.order < b.order end)
end

function ReUIFocusManager.unregister(control)
    for i = #ReUIFocusManager.controls, 1, -1 do
        if ReUIFocusManager.controls[i].control == control then
            table.remove(ReUIFocusManager.controls, i)
        end
    end
    if ReUIFocusManager.active == control then
        ReUIFocusManager.active = nil
    end
end

function ReUIFocusManager.setFocus(control)
    if not usable(control) then return false end
    ReUIFocusManager.active = control
    if control.focus then
        pcall(control.focus, control)
        return true
    end
    if control.onGainFocus then
        pcall(control.onGainFocus, control)
        return true
    end
    return false
end

function ReUIFocusManager.move(direction)
    local list = ReUIFocusManager.controls
    if #list == 0 then return false end

    local currentIndex = 0
    for i, item in ipairs(list) do
        if item.control == ReUIFocusManager.active then
            currentIndex = i
            break
        end
    end

    direction = direction and direction < 0 and -1 or 1
    for step = 1, #list do
        local index = ((currentIndex - 1 + direction * step) % #list) + 1
        if usable(list[index].control) then
            return ReUIFocusManager.setFocus(list[index].control)
        end
    end
    return false
end

function ReUIFocusManager.next()
    return ReUIFocusManager.move(1)
end

function ReUIFocusManager.previous()
    return ReUIFocusManager.move(-1)
end
