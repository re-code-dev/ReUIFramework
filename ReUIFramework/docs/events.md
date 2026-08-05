# Events, Observables and Commands

## Events

Events decouple controls from application logic.

```lua
local subscription = button.clicked:subscribe(function(sender)
    print(sender.text)
end)

subscription:dispose()
```

## Observables

```lua
local value = ReUI.Observable:new(10)

value:subscribe(function(current, previous)
    print(previous, current)
end)

value:set(20)
```

## Commands

Commands combine execution and availability.

```lua
local saveCommand = ReUI.Command:new(
    function()
        save()
    end,
    function()
        return hasChanges()
    end
)
```

External callbacks should be protected so one consumer error does not destroy the framework event loop.
