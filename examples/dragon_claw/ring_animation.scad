use <../../kinematics.scad>
use <dragon_claw.scad>

$fn = $preview ? 16 : 128;

// --- Constants ---
sphere_rad = 90;
contact_rad = 70;
contact_centre = [0, 20, 90];
step_height = -10;
n_points = 5;
base_offset_angle = -15;

sphere_height = sqrt(sphere_rad * sphere_rad - contact_rad * contact_rad);

// --- Helpers ---
// Normalize t into [0,1)
function unit_phase(t) = t - floor(t);

// Ramp profile: rises linearly in first 1/n_points, then falls
function ramp_profile(t, n_points) =
  let (u = unit_phase(t)) u < 1 / n_points ? u * (n_points - 1) : 1 - u;

// Parabolic bump: peak at 0.5/n_points, width ~1/n_points
function parabola_profile(t, n_points) =
  let (
    u = unit_phase(t),
    center = 0.5 / n_points,
    halfspan = 0.5 / n_points
  ) 1 - pow((u - center) / halfspan, 2);

// Step profile: nonzero only in first 1/n_points, shaped by parabola
function step_profile(t, n_points) =
  let (u = unit_phase(t)) u < 1 / n_points ? parabola_profile(u, n_points) : 0;

// Angular spacing helpers
function angular_spacing(n_points) = 360 / n_points;
function step_amplitude(n_points) = 0.5 * angular_spacing(n_points);

// --- Kinematics ---
function target_point(i, t) =
  let (
    theta = base_offset_angle + i * angular_spacing(n_points) + step_amplitude(n_points) * ramp_profile(t + i / n_points, n_points),
    x = contact_centre[0] + contact_rad * sin(theta),
    y = contact_centre[1] - contact_rad * cos(theta),
    z = contact_centre[2] + step_height * step_profile(t + i / n_points, n_points)
  ) [x, y, z];

function pose(chain, target_position) =
  kinematics_inverse_position(
    chain=chain,
    target_position=target_position,
    tolerance=0.05,
    initial_angles=[0, 0, 0]
  );

// Wrapper for one claw’s pose given index and time
function claw_pose(i, t) =
  pose(
    chain=claw_kinematic_chains()[i],
    target_position=target_point(i, t)
  );

// Ring orientation
function ring_angle(t) = -t * angular_spacing(n_points);

// --- Control flags ---
debug = true;
animate = true;
show_sphere = true;

// --- Visualization ---
if (show_sphere) {
  translate(contact_centre + [0, 0, 1] * sphere_height)
    rotate([0, 0, ring_angle($t)])
      %sphere(r=sphere_rad);
}

if (debug) {
  // Show initial end effector positions
  for (i = [0:n_points - 1])
    color("red")
      dragon_claw_show_end_effector(claw_index=i, joint_angles=[0, 0, 0]);

  // Show target points
  for (i = [0:n_points - 1])
    color("blue")
      dragon_claw_show_end_effector(claw_index=i, joint_angles=claw_pose(i, $t));
}

if (animate) {
  target_points = [for (i = [0:n_points - 1]) target_point(i, $t)];
  claw_poses = [for (i = [0:n_points - 1]) claw_pose(i, $t)];
  echo("pose:", claw_poses);
  assembly(claw_poses);
} else {
  assembly([[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]);
}
