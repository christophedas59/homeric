# AGENTS.md
Repository: christophedas59/homeric
Engine: Godot 4.6.1
CI: GitHub Actions (Headless import + GUT tests)

This file defines how automated agents (e.g., Codex) must operate in this repository.

---

## 1. Core Principles

- Simplicity first.
- Minimal changes.
- No temporary hacks.
- Every non-trivial change must be verifiable.
- Never break CI intentionally.

If something fails, stop and re-evaluate before pushing further changes.

---

## 2. Git Workflow Rules

Before modifying anything:

1. Ensure branch is up-to-date with `main`.
2. Pull latest changes.
3. Never force-push unless explicitly requested.
4. Never rewrite public history.

When asked to push:

- Create a feature branch.
- Commit with a clear, scoped message.
- Open a Pull Request.
- Ensure CI passes before merge.

---

## 3. CI Constraints (Godot 4.6.1)

The CI pipeline performs:

1. Headless project import:
   `godot --headless --import --path .`

2. GUT tests:
   `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

Agents must ensure:

- The project imports without errors.
- Tests pass.
- No editor-only features break headless execution.

---

## 4. Testing Requirements

Any change affecting gameplay logic must:

- Add or update at least one GUT test.
- Keep tests deterministic.
- Avoid reliance on editor UI.

Tests live in:
res://tests/


---

## 5. Architecture Guidelines

- Separate data, logic, and presentation.
- Prefer composition over deep inheritance.
- Avoid tight node path coupling.
- Keep gameplay logic testable outside scenes when possible.

---

## 6. Forbidden Actions

- Do not commit `.godot/`.
- Do not remove CI.
- Do not disable tests to “make it pass”.
- Do not introduce editor-only dependencies in runtime logic.

---

## 7. External Reference

Godot Best Practices:
https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html

If external documentation is unavailable, apply standard Godot 4 principles.

---

CI must remain green.
