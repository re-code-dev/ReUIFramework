# Performance

## Avoid per-frame allocation

Do not create temporary tables, closures, controls or formatted strings inside `render` and `prerender`.

## Cache

Cache text measurements, textures, layout results and visible list ranges.

## Invalidate selectively

Use separate dirty flags for layout, text metrics and visuals.

## Virtualize large lists

Do not create one child control for every item in a large data source. Render only visible rows and recycle row objects.

## Centralize polling

Prefer events and observables. When polling is required, centralize it and use an appropriate interval.
