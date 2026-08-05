# Controls

Controls should expose a consistent options-based API and support theme, focus, enabled and visible states.

## Common states

- normal;
- hovered;
- pressed;
- focused;
- disabled.

## Button

```lua
ReUI.Button:new({
    text = "Save",
    onClick = function(sender)
        print("Saved")
    end
})
```

## Label

```lua
ReUI.Label:new({
    text = "Settings"
})
```

## TextBox

```lua
ReUI.TextBox:new({
    placeholder = "Search...",
    password = false,
    maxLength = 128
})
```

## Slider

```lua
ReUI.Slider:new({
    minimum = 0,
    maximum = 100,
    value = 50,
    step = 5
})
```

## CheckBox

```lua
ReUI.CheckBox:new({
    text = "Enable animations",
    isChecked = true
})
```

Every control page in the showcase should demonstrate normal, focused, disabled and interactive states.
