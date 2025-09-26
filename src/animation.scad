// Generic animation and interpolation utilities for OpenSCAD
// Parameterized functions for motion profiles and timing

// Linear ramp with plateau - useful for coordinated multi-object animations
function animation_ramp(t, n_segments) = 
  let (t_norm = t % 1) 
  t_norm < 1 / n_segments ? t_norm * (n_segments - 1) : 1 - t_norm;

// Parabolic motion profile - smooth acceleration/deceleration
function animation_parabola(t, n_segments) = 
  let (t_norm = t % 1) 
  1 - (pow(t_norm - (1 / (2 * n_segments)), 2) / pow(1 / (2 * n_segments), 2));

// Step function with smooth transitions
function animation_step(t, n_segments) = 
  let (t_norm = t % 1) 
  t_norm < 1 / n_segments ? animation_parabola(t_norm, n_segments) : 0;

// Debug visualization for motion profiles
module animation_debug_profiles(n_segments = 5, scale = 10) {
  for(t=[0:0.01:1]) {
    translate([scale*t, scale*animation_ramp(t, n_segments)]) circle(d=0.5);
  }
}



// function ramp(t) = let (t_ = t % 1) t_ < 1 / n_points ? t_ * (n_points - 1) : 1 - t_;
// function parabola(t) = let (t_ = t % 1) 1 - (pow(t_ - (1 / (2 * n_points)), 2) / pow(1 / (2 * n_points), 2));
// function step(t) = let (t_ = t % 1) t_ < 1 / n_points ? parabola(t_) : 0;
// n_points = 5;

// for(t=[0:0.01:1]) translate([10*t, 10*ramp(t)]) circle(d=1);
// //for(t=[0:0.001:1]) translate([10*t, 10*parabola(t)]) circle(d=1);
// //for(t=[0:0.001:1]) translate([10*t, 10*step(t)]) circle(d=1);

