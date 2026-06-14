# Agent notes — WB3S programming jig

This repo repurposes Tuya remote controllers (IR / IR+RF) with custom firmware.
The deliverable is the OpenSCAD jig **`wb3s_jig.scad`**, a clip-on UART-flashing
fixture for an SMD-soldered Tuya WB3S. `README.md` covers usage and the flashing
chain; `tuya-ir.md` / `tuya-ir-rf.md` are device guides.

**Read the `.scad` header comment and `README.md` first** — coordinate system,
pinout (and the top-view mirror gotcha), dimensions, and design rationale live
there; don't restate them here.

## Verify a change

```sh
openscad -o /tmp/out.stl --render=true wb3s_jig.scad 2>&1 | grep -iE 'warning|error'
```

Clean = no output. `Volumes: N` in the CGAL stats counts solids **plus the
unbounded outer volume**, so cap + clamp = `3` is normal, not a defect.
`--render=true` (CGAL) flattens colors; omit it (OpenCSG preview) when inspecting
colored ghost/section parts.

## When editing geometry

- **Overlap every `difference()` cut by `eps`** into the adjacent solid —
  coincident/coplanar faces trigger CGAL manifold errors.
- The clamp is a printed spring: if it cracks at the spine corners, *reduce*
  stiffness (thinner/taller spine, tune `press`) rather than adding material —
  inner-corner fillets would collide with the clamped stack.
