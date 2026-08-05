# Testing

## Static checks

- Lua syntax;
- duplicate module names;
- missing local `require` targets;
- Markdown links;
- archive structure.

## In-game smoke test

1. Remove older Re:UI copies.
2. Enable only Re:UI.
3. Start Project Zomboid Build 42.20.
4. Confirm a single framework load message.
5. Open the showcase manually.
6. Exercise every component.
7. Close and reopen repeatedly.
8. Test common resolutions.
9. Test mouse and keyboard.
10. Test controller support where available.
11. Test multiplayer client startup.
12. Test dedicated server startup.
13. inspect `console.txt`.

## Regression priorities

- recursive window opening;
- duplicate event handlers;
- missing Build methods;
- focus leaks;
- mouse capture not released;
- stale popup references;
- per-frame allocation growth.
