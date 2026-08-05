# Contributing to Re:UI

Thank you for helping improve Re:UI.

## Before starting

Read:

- `AGENTS.md`
- `ARCHITECTURE.md`
- `COMPATIBILITY.md`
- `STYLE_GUIDE.md`
- `ROADMAP.md`

For large changes, open an issue first so architecture and scope can be discussed.

## Development rules

- Keep changes focused.
- Do not duplicate framework services.
- Do not add direct Build-specific calls outside compatibility code.
- Use theme tokens.
- Update the showcase for visible features.
- Document public APIs.
- Add a changelog entry.
- State what was and was not tested.

## Pull request checklist

- [ ] Code follows the style guide
- [ ] Public APIs are documented
- [ ] Showcase or example updated
- [ ] No duplicate bootstrap or class introduced
- [ ] Compatibility-sensitive calls are isolated
- [ ] Static checks pass
- [ ] Changelog updated
- [ ] In-game test notes included

## Commit messages

Use concise imperative messages:

```text
Add dropdown keyboard navigation
Fix recursive showcase window opening
Refactor mouse capture compatibility
Document theme token inheritance
```

## Reporting bugs

Include:

- Project Zomboid build;
- Re:UI version or commit;
- enabled mods;
- reproduction steps;
- expected behavior;
- actual behavior;
- relevant `console.txt` stack trace;
- screenshots or video where useful.

Do not paste thousands of unrelated log lines. Include the first relevant exception and its stack trace.
