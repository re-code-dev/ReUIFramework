# Architecture

## Overview

Re:UI separates application-facing APIs from Project Zomboid's Build-specific UI implementation.

```text
Application / Mod
        │
        ▼
Public Re:UI API
        │
        ├─ Controls
        ├─ Layouts
        ├─ Windows
        ├─ Events / Observables / Commands
        └─ Theme / Animation
        │
        ▼
Managers and Rendering Services
        │
        ▼
Compatibility Layer
        │
        ▼
Project Zomboid ISUI / Engine APIs
```

## Layers

### Public API

The public API exposes stable constructors and methods such as:

```lua
ReUI.Button:new({ text = "Save" })
```

Application code should not need to know how ISUI constructors, mouse capture, clipping or text measurement work internally.

### Core

Core contains lifecycle, events, observables, commands, logging, service registration, version information and defensive utilities.

### Controls

Controls expose reusable behavior and visual states. They should be themeable and should not directly contain Build-specific API calls.

### Layout

Layouts measure and arrange children. Geometry calculations should not be mixed with rendering or input dispatch.

### Input

Keyboard, mouse, focus, clipboard and controller actions are centralized. Individual controls react to routed input.

### Windows

The window system owns z-order, activation, modality, popups, tooltips and disposal relationships.

### Rendering

Rendering helpers normalize game drawing calls and minimize duplicated parameter ordering. Rendering should avoid per-frame allocations.

### Theme

Theme tokens define colors, typography, spacing, metrics and state-specific styles.

### Compatibility

The compatibility layer owns unstable or Build-specific Project Zomboid calls. Future Build migrations should primarily modify this layer.

## Dependency direction

High-level modules may depend on lower-level services. Lower-level modules must not depend on showcase pages or application-specific code.

```text
Showcase → Public API → Controls/Layout/Windows → Core/Services → Compatibility
```

Avoid cyclic dependencies.

## Bootstrapping

The framework must have one idempotent bootstrap. Required properties:

- registers global events once;
- does not auto-open the showcase;
- initializes services in deterministic order;
- logs framework and game versions once;
- supports clean shutdown or reload where practical.

## Public API stability

Breaking public API changes require:

- a migration note;
- a major or clearly documented pre-1.0 version change;
- updated examples;
- updated showcase usage;
- changelog entry.
