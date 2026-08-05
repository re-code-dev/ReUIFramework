ReUITheme = ReUITheme or {}

ReUITheme.current = ReUITheme.current or {
    name = "ReUI Dark",
    colors = {
        background = { r = 0.035, g = 0.040, b = 0.055, a = 0.99 },
        surface = { r = 0.065, g = 0.075, b = 0.100, a = 1.00 },
        surfaceAlt = { r = 0.095, g = 0.105, b = 0.135, a = 1.00 },
        surfaceRaised = { r = 0.125, g = 0.140, b = 0.175, a = 1.00 },
        titleBar = { r = 0.050, g = 0.060, b = 0.085, a = 1.00 },
        border = { r = 0.18, g = 0.23, b = 0.34, a = 1.00 },
        primary = { r = 0.28, g = 0.70, b = 1.00, a = 1.00 },
        primaryMuted = { r = 0.28, g = 0.70, b = 1.00, a = 0.22 },
        success = { r = 0.30, g = 0.78, b = 0.44, a = 1.00 },
        warning = { r = 0.95, g = 0.72, b = 0.20, a = 1.00 },
        danger = { r = 0.91, g = 0.30, b = 0.24, a = 1.00 },
        info = { r = 0.24, g = 0.72, b = 0.85, a = 1.00 },
        text = { r = 0.96, g = 0.97, b = 0.99, a = 1.00 },
        textMuted = { r = 0.62, g = 0.68, b = 0.78, a = 1.00 },
        textDisabled = { r = 0.39, g = 0.42, b = 0.46, a = 1.00 }
    },
    metrics = {
        radius = 5,
        spacing = 8,
        titleBarHeight = 44,
        borderSize = 1,
        resizeGrip = 14,
        controlHeight = 32,
        contentInset = 12,
        sidebarWidth = 190,
        sidebarHeaderHeight = 48,
        inspectorWidth = 220,
        navItemHeight = 34,
        navItemGap = 4
    }
}

-- xs/sm/md/lg/xl spacing scale used by the "sm"/"md"/... string shorthands
-- accepted for padding/spacing/margin options throughout the framework.
ReUITheme.spacingScale = {
    xs = 4,
    sm = 8,
    md = 12,
    lg = 16,
    xl = 24
}
-- Alias for direct table-style lookups (e.g. ReUITheme.spacing.md).
ReUITheme.spacing = ReUITheme.spacingScale

-- Alias for direct table-style lookups (e.g. ReUITheme.metrics.sidebarWidth),
-- kept in sync with ReUITheme.current.metrics whenever the theme changes
-- (see ReUITheme.set below).
ReUITheme.metrics = ReUITheme.current.metrics

function ReUITheme.color(role)
    local colors = ReUITheme.current and ReUITheme.current.colors
    return (colors and colors[role]) or { r = 1, g = 1, b = 1, a = 1 }
end

function ReUITheme.metric(name, fallback)
    local metrics = ReUITheme.current and ReUITheme.current.metrics
    local value = metrics and metrics[name]
    if value == nil then return fallback end
    return value
end

function ReUITheme.set(theme)
    if type(theme) ~= "table" then return false end
    ReUITheme.current = theme
    ReUITheme.metrics = theme.metrics or ReUITheme.metrics
    return true
end

-- Resolves a spacing value: a number is used as-is, a string looks up the
-- xs/sm/md/lg/xl scale, nil falls back to the theme's base spacing metric.
function ReUITheme.getSpacing(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "string" then
        return ReUITheme.spacingScale[value] or ReUITheme.metric("spacing", 8)
    end
    return ReUITheme.metric("spacing", 8)
end

-- Normalizes a padding/margin option into a {top, right, bottom, left} box.
-- Accepts nil (zero box), a number/spacing-token (uniform box), or an
-- already-built {top,right,bottom,left} table (missing sides default to 0).
function ReUITheme.normalizeBox(value)
    if type(value) == "table" then
        return {
            top = value.top or 0,
            right = value.right or 0,
            bottom = value.bottom or 0,
            left = value.left or 0
        }
    end

    if value == nil then
        return { top = 0, right = 0, bottom = 0, left = 0 }
    end

    local uniform = ReUITheme.getSpacing(value)
    return { top = uniform, right = uniform, bottom = uniform, left = uniform }
end

-- Vertically centers a line of `font` text inside a `height`-tall box
-- starting at `y`, returning the y to pass to drawText.
function ReUITheme.textY(font, y, height)
    local fontHeight = getTextManager():getFontHeight(font)
    return y + math.floor((height - fontHeight) / 2)
end

-- Draws `text` on `element` (any ISUIElement, via its :drawText), vertically
-- centered inside a `height`-tall box starting at `y`.
function ReUITheme.drawTextCenteredY(element, text, x, y, height, font, color)
    element:drawText(text, x, ReUITheme.textY(font, y, height),
        color.r, color.g, color.b, color.a, font)
end
