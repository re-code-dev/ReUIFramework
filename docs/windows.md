# Window System

The window system owns:

- registration;
- z-order;
- activation;
- dragging;
- resizing;
- close behavior;
- modal ownership;
- popups;
- tooltips;
- disposal.

## Rules

- Keep one base window implementation.
- Do not create parallel legacy window classes.
- Bring active windows to front.
- Modal windows must block input, not only draw an overlay.
- Closing a window must release subscriptions and popup ownership.
