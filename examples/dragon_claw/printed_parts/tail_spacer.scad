use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>

// Bearing parameters (623 bearing)
bearing_len = 4;
bearing_od = 10;
bearing_id = 3;

// Spline mate parameters
spline_mate_dia = 15;

module tail_spacer(clearance = 0.2) {
  difference() {
    union() {
      cone_len = 1;
      translate([0, 0, bearing_len]) cylinder(h=cone_len, d1=5, d2=spline_mate_dia - clearance);
      translate([0, 0, bearing_len + cone_len]) cylinder(h=mg90s_shaft_len() - cone_len - clearance / 2, d=spline_mate_dia - clearance);
    }
    union() {
      cylinder(d=3.2, h=bearing_len + mg90s_shaft_len() + 0.1);
    }
  }
}
