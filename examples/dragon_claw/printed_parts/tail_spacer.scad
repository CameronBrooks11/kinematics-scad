use <scad-utils/transformations.scad>
use <../lib/mg90s.scad>
include <../settings.scad>

// --- Bearing (623) ---
bearing_len = 4;
bearing_od = 10;
bearing_id = 3;

// --- Spline mate ---
spline_mate_dia = 15;

// Tail spacer: mates to spline and provides a through-hole for the tail bolt
module tail_spacer(clearance = 0.2) {
  let (
    cone_len = 1,
    bolt_dia = 3.2,
    hole_extra = 0.1
  )
  difference() {
    // Positive geometry: short cone + cylindrical sleeve
    union() {
      translate([0, 0, bearing_len])
        cylinder(h=cone_len, d1=5, d2=spline_mate_dia - clearance);

      translate([0, 0, bearing_len + cone_len])
        cylinder(
          h=mg90s_shaft_len() - cone_len - clearance / 2,
          d=spline_mate_dia - clearance
        );
    }

    // Negative geometry: through-hole for bolt
    cylinder(d=bolt_dia, h=bearing_len + mg90s_shaft_len() + hole_extra);
  }
}
