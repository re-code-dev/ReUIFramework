# Installation

## Local development installation

Copy the Re:UI mod folder to:

```text
C:\Users\<YourUser>\Zomboid\mods\ReUI
```

Delete any older Re:UI folder before copying a replacement. Overwriting can leave removed Lua files behind, and Project Zomboid may still load them.

## Verify the folder

The directory containing `mod.info` must be the actual mod root. Avoid accidental nesting:

```text
Incorrect:
mods/ReUI/ReUI/mod.info

Correct:
mods/ReUI/mod.info
```

## Enable the mod

1. Start Project Zomboid.
2. Open **Mods**.
3. Enable **Re:UI Framework**.
4. Restart the game after replacing framework files.

## Troubleshooting

Search `Zomboid/console.txt` for:

```text
[Re:UI]
ERROR:
STACK TRACE
Object tried to call nil
Stack overflow
```

Include the first relevant Re:UI exception in bug reports.
