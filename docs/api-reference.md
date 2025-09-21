# API Reference

## Functions

### kinematics_forward_position(chain, joint_angles)

Calculate end-effector position.

```c
position = kinematics_forward_position(my_robot(), [30, 45]);
```

### kinematics_forward_transform(chain, joint_angles)

Calculate full 4x4 transformation matrix.

### kinematics_inverse_position(chain, target_position, ...)

Solve for joint angles to reach target position.

```c
angles = kinematics_inverse_position(
  chain = my_robot(),
  target_position = [60, 40, 0],
  tolerance = 0.1
);
```

Optional parameters: `initial_angles`, `step_size`, `tolerance`, `max_iterations`

### kinematics_show_end_effector(chain, joint_angles, marker_diameter)

Display sphere marker at end-effector.

```c
kinematics_show_end_effector(my_robot(), [30, 45], 5);
```

## Chain Definition

```c
function robot() = [
  [link1, link2, link3, ...],    // Transformations
  [axis1, axis2, ...]            // Rotation axes
];
```

- **Links**: 4x4 transformation matrices between joints
- **Axes**: 3D rotation axis vectors (e.g., `[0,0,1]` for Z-axis)
- **Rule**: `len(links) = len(axes) + 1`

## Constants

```c
KINEMATICS_VERSION = "1.0.0"
KINEMATICS_DEFAULT_MARKER_DIAMETER = 5
KINEMATICS_DEFAULT_IK_MARGIN = 0.1
KINEMATICS_DEFAULT_IK_STEP = 0.8
KINEMATICS_DEFAULT_IK_MAX_ITERATIONS = 20
```
