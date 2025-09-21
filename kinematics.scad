// kinematics.scad
// A simple forward and inverse kinematics implementation for OpenSCAD
// by BrettRD 2021-2024
// modified by Cameron K. Brooks 2025

use <scad-utils/se3.scad>
use <scad-utils/linalg.scad>
use <scad-utils/lists.scad>
use <scad-utils/transformations.scad>
use <scad-utils/spline.scad>

// ---------------------------------------------------------------------------
// Overview
// This kinematics system supports series kinematic linkages.
// A "chain" has the form [links, axes] where:
//
// - links: array of transforms in 4x4 matrix format, e.g. translation([x,y,z])
// - axes:  array of 3D vectors defining joint axes in local coordinates
//
// Example: links[0] is the transform from the global origin to axis[0].
// The frame links[1] builds on is rotated about axes[0].
// ---------------------------------------------------------------------------

// Version and constants
KINEMATICS_VERSION = "1.0.0";
KINEMATICS_DEFAULT_MARKER_DIAMETER = 5;
KINEMATICS_DEFAULT_IK_MARGIN = 0.1;
KINEMATICS_DEFAULT_IK_STEP = 0.8;
KINEMATICS_DEFAULT_IK_MAX_ITERATIONS = 20;
KINEMATICS_DEFAULT_JACOBIAN_DELTA = 0.1;

echo("Kinematics.scad version ", KINEMATICS_VERSION);

// ---------------------------------------------------------------------------
// Private Utility Functions
// ---------------------------------------------------------------------------

// Create identity matrix of size n
function _kinematics_identity_matrix(n) =
  [for (i = [0:n - 1]) [for (j = [0:n - 1]) i == j ? 1 : 0]];

// Zip two arrays element-wise  
function _kinematics_zip_arrays(array_a, array_b, index = 0, output = []) =
  index >= len(array_a) || index >= len(array_b) ? output
  : _kinematics_zip_arrays(
    array_a, array_b, index + 1,
    concat(output, [array_a[index], array_b[index]])
  );

// ---------------------------------------------------------------------------
// Forward Kinematics - Public API
// ---------------------------------------------------------------------------

// Create transformation list by inserting joint rotations into kinematic chain
// Parameters:
//   chain: [links, axes] where links are 4x4 matrices, axes are 3D vectors
//   joint_angles: array of joint angles in degrees
function kinematics_forward_chain_transforms(chain, joint_angles) =
  assert(joint_angles != undef, "Joint angles must be defined")
  assert(len(chain) == 2, "Chain must have exactly 2 elements: [links, axes]")
  assert(
    len(chain[0]) == 1 + len(chain[1]),
    "Number of links must equal number of axes plus one"
  )
  let (
    links = chain[0],
    axes = chain[1],
    num_joints = len(axes),
    joint_rotations = [
      for (i = [0:num_joints - 1]) rotation(axis=axes[i] * joint_angles[i]),
    ]
  ) concat(_kinematics_zip_arrays(links, joint_rotations), [links[num_joints]]);

// Flatten transformation list into single 4x4 matrix
function _kinematics_flatten_transforms(transform_list, accumulated_matrix = identity4()) =
  len(transform_list) == 0 ? accumulated_matrix
  : _kinematics_flatten_transforms(
    remove(transform_list, 0),
    accumulated_matrix * transform_list[0]
  );

// Calculate end-effector transformation matrix for given joint angles
// Parameters:
//   chain: [links, axes] kinematic chain definition
//   joint_angles: array of joint angles in degrees
function kinematics_forward_transform(chain, joint_angles) =
  _kinematics_flatten_transforms(
    kinematics_forward_chain_transforms(chain, joint_angles)
  );

// Calculate end-effector position for given joint angles
// Parameters:
//   chain: [links, axes] kinematic chain definition  
//   joint_angles: array of joint angles in degrees
function kinematics_forward_position(chain, joint_angles) =
  transform(
    kinematics_forward_transform(chain, joint_angles),
    [[0, 0, 0]]
  )[0];

// Visualize end-effector position with a sphere marker
// Parameters:
//   chain: [links, axes] kinematic chain definition
//   joint_angles: array of joint angles in degrees (default: all zeros)
//   marker_diameter: diameter of visualization sphere
module kinematics_show_end_effector(
  chain,
  joint_angles = [],
  marker_diameter = KINEMATICS_DEFAULT_MARKER_DIAMETER
) {

  final_angles =
    len(joint_angles) == 0 ?
      [for (i = [0:len(chain[1]) - 1]) 0]
    : joint_angles;

  translate(kinematics_forward_position(chain, final_angles))
    sphere(d=marker_diameter);
}

// ---------------------------------------------------------------------------
// Inverse Kinematics - Public API  
// ---------------------------------------------------------------------------

// Calculate numerical Jacobian matrix for the kinematic chain
// Parameters:
//   chain: [links, axes] kinematic chain definition
//   joint_angles: current joint angles in degrees
//   delta: small step size for numerical differentiation
function kinematics_jacobian(
  chain,
  joint_angles,
  delta = KINEMATICS_DEFAULT_JACOBIAN_DELTA
) =
  let (num_joints = len(chain[1])) [
      for (direction = _kinematics_identity_matrix(num_joints)) (
        kinematics_forward_position(chain, joint_angles + delta * direction) - kinematics_forward_position(chain, joint_angles)
      ) / delta,
  ];

// Solve inverse kinematics using gradient descent (position only)
// Note: This solver only addresses end-effector position, not orientation
// Parameters:
//   chain: [links, axes] kinematic chain definition
//   target_position: desired 3D end-effector position
//   initial_angles: starting joint angles (default: all zeros)
//   step_size: gradient descent step size
//   tolerance: position error tolerance for convergence
//   max_iterations: maximum number of iterations before giving up
function kinematics_inverse_position(
  chain,
  target_position,
  initial_angles = [],
  step_size = KINEMATICS_DEFAULT_IK_STEP,
  tolerance = KINEMATICS_DEFAULT_IK_MARGIN,
  max_iterations = KINEMATICS_DEFAULT_IK_MAX_ITERATIONS
) =

  let (
    start_angles = len(initial_angles) == 0 ?
      [for (i = [0:len(chain[1]) - 1]) 0]
    : initial_angles
  ) _kinematics_ik_iterate(
    chain, target_position, step_size, tolerance,
    max_iterations, start_angles
  );

// Private recursive function for IK iteration
function _kinematics_ik_iterate(
  chain,
  target_position,
  step_size,
  tolerance,
  iterations_remaining,
  current_angles
) =

  iterations_remaining == 0 ?
    let (dummy = echo("IK: Maximum iterations reached")) current_angles
  : let (
    position_error = target_position - kinematics_forward_position(chain, current_angles),
    jacobian_matrix = kinematics_jacobian(chain, current_angles),
    angle_delta = position_error * matrix_invert(jacobian_matrix),
    next_angles = current_angles + step_size * angle_delta
  ) norm(position_error) < tolerance ?
    next_angles
  : _kinematics_ik_iterate(
    chain, target_position, step_size, tolerance,
    iterations_remaining - 1, next_angles
  );

// ---------------------------------------------------------------------------
// End of kinematics.scad
// ---------------------------------------------------------------------------
