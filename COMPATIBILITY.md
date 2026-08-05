# Compatibility Policy

## Primary target

Re:UI targets Project Zomboid Build 42.20.

## Principle

Controls and layouts must not call unstable Project Zomboid APIs directly. Those calls belong in the compatibility layer.

## Compatibility-owned concerns

- mouse capture and release;
- keyboard capture;
- clipboard access;
- text-entry configuration;
- focus integration;
- controller integration;
- clipping;
- text measurement;
- texture loading;
- UI manager registration;
- screen and resolution queries.

## Feature detection

Prefer feature detection:

```lua
if object and type(object.someMethod) == "function" then
    object:someMethod()
end
```

over raw version comparisons.

## Build migration procedure

1. Record the new game build.
2. Diff relevant vanilla `media/lua` files.
3. Run the showcase smoke test.
4. Update compatibility wrappers.
5. Add regression coverage for every discovered breakage.
6. Update this document and the changelog.
7. Release a patch version.

## Support matrix

| Re:UI branch | Project Zomboid | Status |
|---|---:|---|
| `main` | 42.20 | Primary |
| legacy development snapshots | 42.19 | Best effort only |
| Build 41 | 41.x | Not supported |

## Runtime verification

Static checks cannot prove compatibility with the Project Zomboid runtime. Every release requires an in-game test on the target Build.
