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
- [scad-utils](https://github.com/openscad/scad-utils) for matrix operations

## Documentation

📚 **[Documentation](docs/README.md)** - Quick reference and usage

- [API Reference](docs/api-reference.md) - Function documentation
- [Theory](docs/theory.md) - Mathematical background

## Examples

- **Dragon Claw** (`examples/dragon_claw/`) - 5-finger robotic hand with 15 DOF

## License

Original work by BrettRD (2021-2024), enhanced by Cameron K. Brooks (2025).

## Related Projects

- [dragon_claw](https://github.com/BrettRD/dragon_claw) - ROS2 integration by BrettRD
