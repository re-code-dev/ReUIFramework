# Theming

Themes define visual tokens instead of embedding style values in controls.

## Token categories

- colors;
- typography;
- spacing;
- control metrics;
- borders;
- radii;
- animation durations.

## Example

```lua
local theme = {
    colors = {
        background = { r = 0.04, g = 0.05, b = 0.07, a = 1.0 },
        surface = { r = 0.08, g = 0.10, b = 0.14, a = 1.0 },
        text = { r = 0.93, g = 0.95, b = 0.98, a = 1.0 },
        accent = { r = 0.15, g = 0.55, b = 1.00, a = 1.0 }
    },
    spacing = {
        sm = 8,
        md = 12,
        lg = 16
    }
}
```

Theme changes invalidate visuals. Metric changes also invalidate layout.
