# Re:UI Agent Instructions

## Mission

Continue development of Re:UI and its official showcase as a production-quality UI framework for Project Zomboid Build 42.20.

Do work instead of repeatedly proposing roadmaps. When the requested direction is clear, inspect the repository, implement the next coherent milestone, update documentation and provide a testable result.

## Source of truth

Read these files before modifying code:

1. `AGENTS.md`
2. `ARCHITECTURE.md`
3. `COMPATIBILITY.md`
4. `STYLE_GUIDE.md`
5. `ROADMAP.md`
6. relevant files in `docs/`
7. the current source tree

The existing code is authoritative. Do not invent classes or claim functionality exists without verifying it.

## Product goals

Re:UI should provide:

- reusable controls;
- responsive layouts;
- themes;
- animations;
- focus and input management;
- windows, dialogs, popups and notifications;
- observables and commands;
- compatibility wrappers around Project Zomboid APIs;
- a polished official showcase.

The showcase should feel like a real desktop application, not a debug sandbox.

## Primary target

- Project Zomboid Build 42.20
- Build-specific behavior belongs in the compatibility layer.
- Do not scatter version checks throughout controls.
- Prefer feature detection over raw version comparisons.

## Required workflow

For every implementation task:

1. Inspect the existing files and architecture.
2. Identify dependencies and likely regressions.
3. Implement the smallest coherent feature set.
4. Update or add the showcase page.
5. Update documentation.
6. Update `CHANGELOG.md`.
7. Run available static checks.
8. Search for duplicate bootstraps, classes and global names.
9. Report what was changed and what still requires in-game testing.

## Autonomous development

Continue through the current milestone without waiting for approval after every file.

Break large milestones into logical commits or work units. Stop only when:

- the requested milestone is complete;
- a real technical blocker requires user input;
- required source files are missing;
- in-game runtime verification is necessary.

Never substitute a plan for implementation when implementation is possible.

## Architecture rules

- One primary responsibility per module.
- No duplicated base window implementations.
- One supported showcase bootstrap.
- No automatic demo opening.
- Centralized keyboard, mouse and focus handling.
- Theme tokens instead of hardcoded presentation values.
- Public constructors use options tables where practical.
- Public callbacks must be protected at extension boundaries.
- Dispose subscriptions, manager registrations, popup ownership and mouse capture.
- Avoid globals except deliberate framework entry points.

## Compatibility rules

All potentially unstable Project Zomboid calls belong in `ReUICompatibility.lua` or a dedicated compatibility service, including:

- mouse capture;
- keyboard capture;
- clipboard;
- text-entry behavior;
- focus;
- clipping;
- text measurement;
- texture loading;
- UI manager integration;
- controller integration.

Controls call stable Re:UI wrappers.

## Runtime safety

Watch especially for:

- recursive `open()` implementations;
- duplicate event registration;
- stale legacy files loaded alongside new files;
- missing or renamed Build APIs;
- circular `require` calls;
- repeated layout invalidation;
- object creation inside render loops;
- event subscriptions not removed on close.

## Showcase requirements

The official showcase must include:

- dashboard;
- component gallery;
- layouts;
- theme editor;
- settings example;
- windows and dialogs;
- notifications;
- animation examples;
- accessibility page;
- diagnostics and compatibility report;
- performance stress tests.

Every page must be polished and useful. Avoid placeholder rectangles and meaningless controls.

## Visual direction

- dark, modern, restrained;
- black, graphite and blue foundation;
- consistent spacing and typography;
- subtle borders;
- clear hierarchy;
- smooth but optional motion;
- no random colors;
- no inconsistent icon styles.

## Documentation requirements

Every public class must document:

- purpose;
- constructor;
- options;
- properties;
- methods;
- events;
- example;
- disposal behavior;
- compatibility notes.

## Definition of done

A feature is complete when:

- code is integrated;
- the showcase demonstrates it;
- documentation exists;
- naming follows the style guide;
- no obvious duplicate code was introduced;
- static checks pass;
- limitations and in-game test requirements are stated honestly.
