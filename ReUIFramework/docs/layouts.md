# Layouts

Layouts own geometry. Controls should not manually position every sibling.

## StackPanel

Arranges children vertically or horizontally.

```lua
local panel = ReUI.StackPanel:new({
    orientation = "vertical",
    spacing = 8
})
```

## WrapPanel

Places children in lines and wraps when space is exhausted.

## Grid

Supports rows, columns and spans. Implement fixed and automatic sizing reliably before advanced weighted sizing.

## DockPanel

Docks children to top, bottom, left or right while the remaining child fills available space.

## Margin, padding and spacing

- Margin belongs outside a control.
- Padding belongs inside a container.
- Spacing belongs between children.
