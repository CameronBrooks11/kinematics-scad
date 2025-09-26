use <../../kinematics.scad>

use <dragon_claw.scad>

$fn = $preview ? 16 : 128;

sphere_rad = 90;
contact_rad = 70;
contact_centre = [0, 20, 90];
step_height = -10;
n_points = 5;
step_size = (0.5) * 360 / n_points;

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

function angular_spacing(n_points) = 360 / n_points;
function step_amplitude(n_points) = 0.5 * angular_spacing(n_points);

function target_point(i, t) =
  let (
    theta = -15 + i * (360 / n_points) + (step_size) * ramp_profile(t + i / n_points, n_points),
    x = contact_centre[0] + contact_rad * sin(theta),
    y = contact_centre[1] + contact_rad * -cos(theta),
    z = contact_centre[2] + step_height * step_profile(t + i / n_points, n_points)
  ) [x, y, z];

function pose(chain, target_position) = kinematics_inverse_position(chain=chain, target_position=target_position, tolerance=0.05, initial_angles=[0, 0, 0]);

//describes the orientation of the held object
function ring_angle(t) = -t * step_size;

// ------------

debug = false;
animate = true;
show_sphere = true;

if (show_sphere) {

  sphere_height = sqrt(sphere_rad * sphere_rad - contact_rad * contact_rad);

  translate(contact_centre + [0, 0, 1] * sphere_height)
    rotate([0, 0, ring_angle($t)])
      %sphere(r=sphere_rad);
}

if (debug) {
  for (i = [0:n_points - 1]) color("red") kinematics_show_end_effector(claw_kinematic_chains()[i], [0, 0, 0]);
  for (i = [0:n_points - 1]) color("red") dragon_claw_show_end_effector(claw_index=i, joint_angles=pose(i, $t));

  for (i = [0:4]) {
    %translate(target_point(i, $t)) sphere(d=5);
    color("red") kinematics_show_end_effector(chain=claw_kinematic_chains()[i], joint_angles=pose(chain=claw_kinematic_chains()[i], target_position=target_point(i, $t)));
  }
}

if (animate) {
  target_points = [for (i = [0:n_points - 1]) target_point(i, $t)];
  claw_pose = [for (i = [0:n_points - 1]) pose(chain=claw_kinematic_chains()[i], target_position=target_points[i])];
  echo("pose:", claw_pose);
  assembly(claw_pose);
} else {
  assembly([[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]);
}
