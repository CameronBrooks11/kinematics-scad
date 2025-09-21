# Kinematics.scad Documentation

Forward and inverse kinematics for OpenSCAD.

## Quick Reference

```c
use <kinematics.scad>

// Define robot as [links, axes]
function my_robot() = [
  [translation([0,0,0]), translation([50,0,0]), translation([30,0,0])],
  [[0,0,1], [0,0,1]]
];

// Forward kinematics
position = kinematics_forward_position(my_robot(), [30, 45]);

// Inverse kinematics
angles = kinematics_inverse_position(my_robot(), [60, 40, 0]);

// Visualize
kinematics_show_end_effector(my_robot(), angles);
```

## Documentation

- [API Reference](api-reference.md) - Function documentation
- [Theory](theory.md) - Mathematical background

## Dependencies

Requires [scad-utils](https://github.com/openscad/scad-utils) for matrix operations.
