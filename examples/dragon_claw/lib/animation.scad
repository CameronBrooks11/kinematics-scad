// --- Animation Helpers ---
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
  ) max(0, 1 - pow((u - center) / halfspan, 2));

// Step profile: nonzero only in first 1/n_points, shaped by parabola
function step_profile(t, n_points) =
  let (u = unit_phase(t)) u < 1 / n_points ? parabola_profile(u, n_points) : 0;

// Angular spacing helpers
function angular_spacing(n_points) = 360 / n_points;
function step_amplitude(n_points) = 0.5 * angular_spacing(n_points);
