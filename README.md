# Kinematics for OpenSCAD

A clean, modern kinematics library for OpenSCAD featuring forward and inverse kinematics for serial robotic chains.

![Dragon Claw Animation](animation/animation.gif)

## Features

- **Clean API** with consistent `kinematics_*` naming
- **Forward kinematics** for position and full transforms
- **Inverse kinematics** using gradient descent with Jacobian
- **Visualization tools** for debugging and animation
- **Well-documented** with comprehensive examples

## Requirements

- OpenSCAD 2019.05+
- [scad-utils](https://github.com/openscad/scad-utils) for matrix operations, pinned in
  `scadman.lock` to commit `26f8c2c` (upstream has no tags). With
  [scadman](https://github.com/CameronBrooks11/scadman) installed, `scadman sync` puts it in
  `.scadman/env/`; add the folder `scadman env` prints to `OPENSCADPATH`, or render with
  `scadman run`. Without scadman, clone scad-utils into your OpenSCAD libraries folder and
  check out that commit.

## Examples

- **Dragon Claw** (`examples/dragon_claw/`) - 5-finger robotic hand with 15 DOF

## License

Original work by BrettRD (2021-2024), enhanced by Cameron K. Brooks (2025).

## Related Projects

- [dragon_claw](https://github.com/BrettRD/dragon_claw) - ROS2 integration by BrettRD
