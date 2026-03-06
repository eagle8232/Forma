Plan: Fix zero `rect` in `buildIconImageView`

TL;DR — `iconBackgroundView.bounds` is zero because you're reading it before Auto Layout has given the view a concrete size (or you're preventing later layout with the `isLayedOut` guard). Fix by building/updating the circle layer after the subview has a non-zero bounds: call `layoutIfNeeded()` before reading bounds, or move/update the layer creation into `layoutSubviews()` without prematurely setting `isLayedOut`. Also make the layer creation idempotent so repeated layouts update the path instead of adding duplicate sublayers. (Files: `Forma/Presentation/Screens/Main/Components/CurrentTaskView.swift`, symbol: `buildIconImageView()` / `layoutSubviews`).

### Steps
1. Inspect the early layout timing in `CurrentTaskView.layoutSubviews()`:
   - Check that `super.layoutSubviews()` is called and that you don’t set `isLayedOut = true` before confirming subview frames are non-zero (file: `CurrentTaskView.swift`, method `layoutSubviews()`).
2. Defer reading `iconBackgroundView.bounds` until it has a non-zero size:
   - Option A (simple): call `iconBackgroundView.layoutIfNeeded()` in `layoutSubviews()` before `buildIconImageView()` and only set `isLayedOut = true` after you confirm `iconBackgroundView.bounds` is not empty.
   - Option B (robust): remove the `isLayedOut` guard and make `buildIconImageView()` idempotent (update existing `CAShapeLayer` frame/path if present, otherwise create it). This handles future size changes and rotation.
3. Make `buildIconImageView()` safe and repeatable:
   - If you create a new `CAShapeLayer`, store it as a property (e.g., `private var iconCircleLayer: CAShapeLayer?`) so you can update `iconCircleLayer.path` and `frame` on each layout instead of adding new sublayers.
   - Before adding a layer, remove or reuse existing `iconBackgroundView.layer.sublayers` entry to avoid stacking duplicates.
4. Example behavior (no code block): In `layoutSubviews()` call `iconBackgroundView.layoutIfNeeded()`; then:
   - if `iconBackgroundView.bounds.isEmpty` -> return (wait for next layout pass)
   - else update/create `iconCircleLayer` using the computed rect
   - set `isLayedOut = true` only after successful creation (if you keep this flag)
5. Additional polish:
   - Use `circleLayer.position = CGPoint.zero` or set `circleLayer.frame = iconBackgroundView.bounds` so it correctly maps to the view coordinate system.
   - Use `contentMode`/`autoresizingMask` or constraints as needed; avoid relying only on one-time setup if the view will resize (e.g., rotation, dynamic type).
   - If using retina rendering for shapes, set `circleLayer.contentsScale = UIScreen.main.scale` if needed.

### Further Considerations
1. Which strategy do you prefer? Option A (quick fix: call `layoutIfNeeded()` then build once) or Option B (robust: make `buildIconImageView()` idempotent and update on every `layoutSubviews()`)? I recommend Option B for resilience to size changes.
2. Do you want me to produce the exact code edits to `CurrentTaskView.swift` to implement Option B (rename/add `iconCircleLayer` property, update `layoutSubviews()` logic, and remove duplicate-sublayer creation)? If yes, I will prepare the edits and run the build checks.