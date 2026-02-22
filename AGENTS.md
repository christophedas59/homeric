# AGENTS.md
Repository: christophedas59/homeric
Engine: Godot 4.6.1
CI: GitHub Actions (Headless import + GUT tests)

This file defines how automated agents (e.g., Codex) must operate in this repository.

---

## 1) Workflow Orchestration

For any non-trivial task (3+ steps or architectural impact):

1. Enter plan mode before implementation.
2. Write a short implementation plan.
3. Identify validation steps (tests, logs, CI).
4. Only then implement.

If implementation deviates from plan:
- Stop.
- Re-evaluate assumptions.
- Update the plan before continuing.

Verification is mandatory:
- Do not consider a task complete without demonstrable correctness.
- Validate behavior, not just compilation.

Bug Fixing Protocol:
- Identify failing tests or logs first.
- Reproduce deterministically.
- Apply minimal fix.
- Re-run tests and verify CI.
- Avoid workaround patches.

## 2) Core Principles

- Simplicity first. Minimal, targeted diffs.
- No patchwork: prefer root-cause fixes.
- Verify before done: changes must be provably correct.
- If something goes sideways: stop, re-plan, then proceed.

---

## 3) Verification Before Done (Definition of Done)

A change is done only when:
- CI is green (import + tests).
- Gameplay logic changes have relevant tests, or a written justification.
- No cache/build artifacts are committed.
- The diff is minimal and scoped to the problem.

---

## 4) CI Constraints (Godot 4.6.1)

CI runs:
- Import (required for UID resolution):
  `godot --headless --import --path .`
- Tests (GUT):
  `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

Rules:
- Never require interactive editor UI.
- Do not disable tests to “make it pass”.
- If CI fails, fix the failure (don’t work around it).

---

## 5) Testing Requirements (GUT)

- Any gameplay logic change must add/update at least one test, or justify why not.
- Keep tests deterministic (avoid real-time waits when possible).
- Clean up nodes: use `queue_free()` or GUT helpers (e.g., `autofree`).
- One test = one reason to fail. Prefer AAA (Arrange/Act/Assert).
- Tests live in: `res://tests/`

---

## 6) Godot Architecture Guidelines (2D Top-Down)

- Separate data / logic / presentation:
  - Data: Resources (stats/config/items)
  - Logic: scripts that can be tested without scenes when possible
  - Presentation: scenes, visuals, UI
- Prefer composition over deep inheritance.
- Prefer signals/events over brittle node-path traversal.
- Scenes should have a single clear responsibility.

Autoloads: keep small and documented. Avoid “god singletons”.

---

## 7) GDScript Standards

- Type public APIs and core gameplay data.
- Prefer `const` and `@export` over magic numbers.
- Avoid hidden side effects in getters/setters.
- Use actionable errors/warnings (`push_error`, `push_warning`) when needed.

---

## 8) Repo Hygiene & Safety

Never commit:
- `.godot/`
- export/build outputs
- temporary/editor caches
- secrets (tokens/keys/credentials)

Avoid churn:
- Do not reformat unrelated files.
- Do not rename/move folders without a clear reason.

---

## 9) Performance & Determinism

- Avoid allocations in `_process` / `_physics_process` when possible.
- Use `_physics_process` for movement/collisions.
- Keep gameplay logic deterministic and testable.

---

## 10) External References

Godot Best Practices:
https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html

Rules:
- Align with Godot 4.6 best practices; otherwise closest Godot 4.x guidance.
- If external access is unavailable, apply standard Godot 4 principles.
- If documentation conflicts with this file, this file takes precedence.

---

CI must remain green.
