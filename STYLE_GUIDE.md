# Style Guide

## Lua naming

- Classes: `PascalCase`
- Methods and locals: `camelCase`
- Constants: `UPPER_CASE`
- Boolean fields: `isEnabled`, `hasFocus`, `canResize`
- Internal fields: `_subscription`, `_disposed`

## Files

Use one primary class or module per file. File names should match the public class.

## Constructors

Prefer options tables at public boundaries:

```lua
local button = ReUI.Button:new({
    text = "Save",
    width = 120
})
```

Normalize defaults once during construction.

## Functions

- Keep functions focused.
- Use early returns.
- Avoid deeply nested branches.
- Do not allocate temporary tables in render loops.
- Protect external callbacks, not every internal call.

## Visual system

- Colors come from themes.
- Spacing comes from spacing tokens.
- Typography comes from typography tokens.
- Metrics come from control tokens.
- Avoid random one-off values.

## Documentation

Public methods should document parameters, returns, events and side effects.

## Global state

Avoid globals except deliberate framework entry points required by the Project Zomboid loading model. Use unique `ReUI` prefixes to prevent collisions.
