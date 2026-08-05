ReUIAnimation = ReUIAnimation or {
    items = {},
    registered = false
}

ReUIAnimation.easing = {
    linear = function(t) return t end,
    outQuad = function(t) return 1 - (1 - t) * (1 - t) end,
    inOutQuad = function(t)
        if t < 0.5 then return 2 * t * t end
        return 1 - ((-2 * t + 2) ^ 2) / 2
    end
}

local function now()
    return getTimestampMs and getTimestampMs() or 0
end

function ReUIAnimation.to(target, property, toValue, duration, easing, onComplete)
    if not target or type(property) ~= "string" then return nil end
    local fromValue = tonumber(target[property])
    toValue = tonumber(toValue)
    if fromValue == nil or toValue == nil then return nil end

    local item = {
        target = target,
        property = property,
        from = fromValue,
        to = toValue,
        duration = math.max(1, tonumber(duration) or 180),
        started = now(),
        ease = ReUIAnimation.easing[easing] or ReUIAnimation.easing.outQuad,
        onComplete = onComplete
    }
    table.insert(ReUIAnimation.items, item)
    return item
end

function ReUIAnimation.update()
    local time = now()
    for i = #ReUIAnimation.items, 1, -1 do
        local item = ReUIAnimation.items[i]
        if not item.target then
            table.remove(ReUIAnimation.items, i)
        else
            local t = math.min(1, (time - item.started) / item.duration)
            local eased = item.ease(t)
            item.target[item.property] = item.from + (item.to - item.from) * eased
            if t >= 1 then
                table.remove(ReUIAnimation.items, i)
                if item.onComplete then pcall(item.onComplete, item.target) end
            end
        end
    end
end

if not ReUIAnimation.registered and Events and Events.OnTick then
    ReUIAnimation.registered = true
    Events.OnTick.Add(ReUIAnimation.update)
end
