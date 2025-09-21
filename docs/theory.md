# Theory and Mathematical Background

Understanding the mathematics behind kinematics.scad.

## Forward Kinematics

Forward kinematics calculates the position and orientation of the end-effector given joint angles.

### Mathematical Foundation

For a serial kinematic chain with n joints, the forward kinematics equation is:

```
T = T₀ × R₁(θ₁) × T₁ × R₂(θ₂) × T₂ × ... × Rₙ(θₙ) × Tₙ
```

Where:

- `T` is the final transformation matrix
- `Tᵢ` are the fixed link transformations
- `Rᵢ(θᵢ)` are the joint rotations
- `θᵢ` are the joint angles

### Implementation

kinematics.scad implements this by:

1. **Chain representation**: `[links, axes]` format
2. **Rotation matrices**: Generated using scad-utils `rotation()`
3. **Matrix multiplication**: Sequential composition of transforms

```c
// Implementation pseudocode
transforms = []
for i in range(n_joints):
    transforms.append(links[i])
    transforms.append(rotation(axis=axes[i] * angles[i]))
transforms.append(links[n_joints])

result = multiply_all(transforms)
```

## Inverse Kinematics

Inverse kinematics solves for joint angles given a desired end-effector position.

### The IK Problem

Given target position `p_target`, find joint angles `θ = [θ₁, θ₂, ..., θₙ]` such that:

```
||f(θ) - p_target|| < ε
```

Where `f(θ)` is the forward kinematics function and `ε` is the tolerance.

### Gradient Descent Solution

kinematics.scad uses iterative gradient descent:

1. **Compute error**: `e = p_target - f(θ_current)`
2. **Compute Jacobian**: `J = ∂f/∂θ`
3. **Update angles**: `θ_new = θ_current + α × J⁻¹ × e`
4. **Repeat** until `||e|| < tolerance`

### Jacobian Calculation

The Jacobian matrix relates joint velocities to end-effector velocity:

```
ṗ = J(θ) × θ̇
```

For position-only IK, the Jacobian is a 3×n matrix:

```
J = [∂x/∂θ₁  ∂x/∂θ₂  ...  ∂x/∂θₙ]
    [∂y/∂θ₁  ∂y/∂θ₂  ...  ∂y/∂θₙ]
    [∂z/∂θ₁  ∂z/∂θ₂  ...  ∂z/∂θₙ]
```

### Numerical Differentiation

kinematics.scad computes the Jacobian numerically using finite differences:

```
∂f/∂θᵢ ≈ (f(θ + δeᵢ) - f(θ)) / δ
```

Where `eᵢ` is the i-th unit vector and `δ` is a small step size.

## Coordinate Systems and Transforms

### OpenSCAD Conventions

- **Right-handed coordinate system**: Z-up, X-forward, Y-left
- **Rotation order**: Applied right-to-left
- **Angle units**: Degrees (converted internally)
- **Matrix format**: 4×4 homogeneous transformation matrices

### Transform Composition

Transforms are composed using matrix multiplication:

```
T_final = T₁ × T₂ × T₃
```

This applies T₁ first, then T₂, then T₃.

### Joint Axes

Joint rotation axes are specified in local coordinates:

- `[1, 0, 0]`: Rotation around local X-axis
- `[0, 1, 0]`: Rotation around local Y-axis
- `[0, 0, 1]`: Rotation around local Z-axis

## Singularities and Limitations

### Kinematic Singularities

Singularities occur when the Jacobian matrix becomes singular (non-invertible):

1. **Boundary singularities**: At workspace boundaries
2. **Internal singularities**: When multiple joints align
3. **Algorithmic singularities**: Due to coordinate choice

### Handling Singularities

kinematics.scad uses:

- **Pseudo-inverse**: Moore-Penrose inverse for rank-deficient Jacobians
- **Damped least squares**: Adding regularization term
- **Multiple starting points**: Different initial guesses

### IK Limitations

- **Position-only**: Does not solve for orientation
- **Local minima**: Gradient descent may get stuck
- **No guarantees**: May not converge for unreachable targets
- **Single solution**: Returns one of possibly many solutions

## Performance Considerations

### Computational Complexity

- **Forward kinematics**: O(n) where n is number of joints
- **Jacobian calculation**: O(n) forward kinematics evaluations
- **Inverse kinematics**: O(k×n) where k is number of iterations

### Optimization Strategies

1. **Caching**: Store expensive calculations
2. **Early termination**: Stop when tolerance is reached
3. **Adaptive step size**: Adjust based on convergence
4. **Analytical solutions**: For simple geometries

## Extending the Library

### Adding Orientation Control

To include orientation in IK:

1. Expand error vector to 6D (position + orientation)
2. Compute full 6×n Jacobian
3. Handle orientation representation (Euler angles, quaternions)

### Alternative IK Methods

- **Jacobian transpose**: Simpler but slower convergence
- **Levenberg-Marquardt**: Combines gradient descent and Gauss-Newton
- **Cyclic coordinate descent**: Joint-by-joint optimization

### Analytical Solutions

For specific robot geometries:

- **2-DOF planar**: Closed-form solutions exist
- **6-DOF spherical wrist**: Geometric approach
- **Anthropomorphic arms**: Decoupled position/orientation

## References

### Robotics Textbooks

- Spong, M. W., et al. "Robot Modeling and Control"
- Craig, J. J. "Introduction to Robotics: Mechanics and Control"
- Lynch, K. M. "Modern Robotics: Mechanics, Planning, and Control"

### Papers and Resources

- Buss, S. R. "Introduction to Inverse Kinematics with Jacobian Transpose, Pseudoinverse and Damped Least Squares methods"
- Zhao, J., Badler, N. "Inverse kinematics positioning using nonlinear programming for highly articulated figures"

### OpenSCAD Resources

- [OpenSCAD Documentation](https://openscad.org/documentation.html)
- [scad-utils Library](https://github.com/openscad/scad-utils)
- [Transformation Mathematics](https://en.wikipedia.org/wiki/Transformation_matrix)
