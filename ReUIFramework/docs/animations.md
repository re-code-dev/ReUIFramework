# Animations

Animations should use shared scheduling and easing helpers.

## Supported concepts

- fade;
- move;
- resize;
- scale;
- color interpolation;
- delay;
- completion callbacks;
- grouped transitions.

## Accessibility

Respect a reduced-motion option. Functional state changes must not depend on animation completion.

## Performance

Do not create a new scheduler or event registration for every control. Use one central animation service.
