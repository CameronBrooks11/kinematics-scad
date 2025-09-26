use <animation.scad>

// -----------------------------------------------------------------------------
// Example Usage / Visual Debug
// -----------------------------------------------------------------------------
n_points = 5;

// Bar chart style visualization for profiles
module profile_examples(t) {
  profs = [
    ["Ramp", ramp_profile(t, n_points), "red"],
    ["Parabola", parabola_profile(t, n_points), "blue"],
    ["Step", step_profile(t, n_points), "green"],
  ];

  for (i = [0:len(profs) - 1]) {
    label = profs[i][0];
    val = profs[i][1];
    col = profs[i][2];
    space = 20;

    x_off = (i - 1) * space; // spacing between bars

    // Base rail
    color("gray") translate([x_off, 0, 0]) cube([2, 0.5, 1], center=true);

    // Moving sphere showing function value
    color(col) translate([x_off, val * 20, 0]) sphere(r=2, $fn=24);

    // Static text label
    translate([x_off, -8, 0]) color("black") linear_extrude(height=0.5)
          text(label, size=3, halign="center");
  }
}

// Demonstrate angular spacing and theta calculation
module theta_example(i, t) {
  theta = -15 + i * angular_spacing(n_points) + step_amplitude(n_points) * ramp_profile(t + i / n_points, n_points);

  r = 40;
  translate([r * sin(theta), -r * cos(theta), 0])
    color("Indigo") sphere(r=3, $fn=36);
}

// -----------------------------------------------------------------------------
// Graph plotter
// -----------------------------------------------------------------------------
module graph_profiles(samples = 200) {
  // Range [0,1] sampled in `samples` steps
  for (j = [0:samples]) {
    u = j / samples;

    ramp_val = ramp_profile(u, n_points);
    parabola_val = parabola_profile(u, n_points);
    step_val = step_profile(u, n_points);
    theta_val = -15 + step_amplitude(n_points) * ramp_profile(u, n_points);

    // Plot ramp (red)
    color("red") translate([u * 100, ramp_val * 30 + 40, 0]) sphere(r=0.8, $fn=12);

    // Plot parabola (blue)
    color("blue") translate([u * 100, parabola_val * 30, 0]) sphere(r=0.8, $fn=12);

    // Plot step (green)
    color("green") translate([u * 100, step_val * 30 - 40, 0]) sphere(r=0.8, $fn=12);

    // Plot theta (indigo, degrees scaled down)
    color("indigo") translate([u * 100, theta_val * 0.5 - 80, 0]) sphere(r=0.8, $fn=12);
  }

  // Labels for each row
  labels = ["Ramp", "Parabola", "Step", "Theta"];
  colors = ["red", "blue", "green", "indigo"];
  for (k = [0:3])
    translate([-10, 40 * ( -k + 1), 0])
      color(colors[k]) linear_extrude(height=0.5)
          text(labels[k], size=5, halign="right");
}

// -----------------------------------------------------------------------------
// Preview
// -----------------------------------------------------------------------------
render_select = "graphical"; // ["visual", "graphical"]

if (render_select == "visual") {
  profile_examples($t);
  for (i = [0:n_points - 1]) theta_example(i, $t);
} else if (render_select == "graphical") {
  graph_profiles();
} else {
  echo("Invalid render_select");
}
