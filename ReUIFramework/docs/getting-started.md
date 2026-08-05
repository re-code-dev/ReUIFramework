# Getting Started

## Requirements

- Project Zomboid Build 42.20
- Re:UI installed and enabled
- Basic Lua familiarity

## Import

```lua
require "ReUI/ReUI"
```

## Create a window

```lua
local window = ReUI.Window:new({
    title = "Hello Re:UI",
    width = 480,
    height = 320
})

window:show()
```

## Add controls

```lua
local content = ReUI.StackPanel:new({
    orientation = "vertical",
    spacing = 8
})

content:add(ReUI.Label:new({
    text = "Character name"
}))

content:add(ReUI.TextBox:new({
    placeholder = "Enter a name"
}))

content:add(ReUI.Button:new({
    text = "Continue"
}))

window:setContent(content)
```

The exact API must match the current source. Treat examples as documentation that must evolve together with code.
