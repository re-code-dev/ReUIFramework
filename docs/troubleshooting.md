# Troubleshooting

## `Object tried to call nil`

Likely causes:

- missing `require`;
- renamed Build method;
- incorrect inheritance;
- calling an instance method statically;
- object not initialized.

Inspect the first Re:UI source line in the stack trace.

## Stack overflow

Usually indicates recursion:

- `open()` calling itself;
- cyclic layout invalidation;
- parent and child repeatedly resizing each other;
- recursive event forwarding.

## Duplicate windows or log messages

Search for duplicate bootstraps and duplicate event registration.

## Old code still runs

Delete the old mod folder completely before installing the new version.
