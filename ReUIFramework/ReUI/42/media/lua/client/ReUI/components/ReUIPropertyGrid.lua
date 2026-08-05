require "ReUI/layout/ReUIScrollContainer"
require "ReUI/components/ReUIPanel"
require "ReUI/components/ReUILabel"
require "ReUI/components/ReUITextBox"
require "ReUI/components/ReUINumberBox"
require "ReUI/components/ReUICheckbox"
require "ReUI/components/ReUIDropdown"
require "ReUI/core/ReUITheme"

-- A label/editor row list ("property sheet"). Each row picks its editor
-- widget from `kind`: "text" | "number" | "checkbox" | "dropdown".
ReUIPropertyGrid = ReUIScrollContainer:derive("ReUIPropertyGrid")

function ReUIPropertyGrid:new(x, y, width, height, options)
    options = options or {}
    local o = ReUIScrollContainer.new(self, x, y, width, height, options)
    setmetatable(o, self)
    self.__index = self

    o.rows = {}
    o.rowHeight = tonumber(options.rowHeight) or 30
    o.labelWidth = tonumber(options.labelWidth) or math.floor((width or 260) * 0.42)
    o.target = options.target
    o.onChange = options.onChange

    return o
end

function ReUIPropertyGrid:addProperty(key, label, kind, value, opts)
    opts = opts or {}
    local content = self:getContent()
    local index = #self.rows + 1
    local viewportWidth = self:getViewportWidth()
    local editorX = self.labelWidth + 8
    local editorWidth = math.max(40, viewportWidth - editorX - 8)
    local editorHeight = math.min(self.rowHeight - 4, ReUITheme.metric("controlHeight", 32))
    local editorY = math.floor((self.rowHeight - editorHeight) / 2)

    local row = ReUIPanel:new(0, (index - 1) * self.rowHeight, viewportWidth, self.rowHeight, {
        drawBackground = false, drawBorder = false
    })
    row:initialise()
    row:instantiate()
    content:addChild(row)

    local rowLabel = ReUILabel:new(8, 0, self.labelWidth, self.rowHeight, label, { colorRole = "textMuted" })
    rowLabel:initialise()
    rowLabel:instantiate()
    row:addChild(rowLabel)

    local editor
    if kind == "checkbox" then
        editor = ReUICheckbox:new(editorX, editorY, editorWidth, editorHeight, "", { value = value == true })
        editor:on("change", function(control, newValue) self:onPropertyChanged(key, newValue) end)
    elseif kind == "number" then
        editor = ReUINumberBox:new(editorX, editorY, editorWidth, editorHeight, {
            value = tonumber(value) or 0, min = opts.min, max = opts.max, step = opts.step, decimals = opts.decimals
        })
        editor:on("change", function(control, newValue) self:onPropertyChanged(key, tonumber(newValue)) end)
    elseif kind == "dropdown" then
        editor = ReUIDropdown:new(editorX, editorY, editorWidth, editorHeight, { options = opts.options or {} })
        editor:selectValue(value, false)
        editor:on("change", function(control, newValue) self:onPropertyChanged(key, newValue) end)
    else
        editor = ReUITextBox:new(editorX, editorY, editorWidth, editorHeight, { text = tostring(value or "") })
        editor:on("change", function(control, newValue) self:onPropertyChanged(key, newValue) end)
    end

    editor:initialise()
    row:addChild(editor)

    table.insert(self.rows, { key = key, label = label, kind = kind, row = row, editor = editor })
    self:relayout()
    return editor
end

function ReUIPropertyGrid:getRow(key)
    for _, entry in ipairs(self.rows) do
        if entry.key == key then return entry end
    end
    return nil
end

function ReUIPropertyGrid:onPropertyChanged(key, value)
    if self.emit then self:emit("change", key, value) end
    if self.onChange then
        if self.target then
            self.onChange(self.target, self, key, value)
        else
            self.onChange(self, key, value)
        end
    end
end

function ReUIPropertyGrid:relayout()
    for i, entry in ipairs(self.rows) do
        entry.row:setY((i - 1) * self.rowHeight)
    end
    self:setContentHeight(#self.rows * self.rowHeight)
end

function ReUIPropertyGrid:clear()
    local content = self:getContent()
    for _, entry in ipairs(self.rows) do
        content:removeChild(entry.row)
    end
    self.rows = {}
    self:setContentHeight(0)
    return self
end

function ReUIPropertyGrid:prerender()
    ReUIScrollContainer.prerender(self)
    local border = ReUITheme.color("border")
    self:drawRect(self.labelWidth, 0, 1, self.height, border.a, border.r, border.g, border.b)
end
