use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

// --- Parameters ---
bolt_len = mg90s_shaft_len() + 1; // thread does not reach bottom of shaft
bolt_head_len = 30;
rear_flange = 5;
rear_flange_bush = 0.5;

servo_tail_shaft_dia = 5;
servo_tail_shaft_dia_shank = servo_tail_shaft_dia + 2;

servo_tail_thickness = 3;

motor_socket_clear_dia = 28;
motor_socket_clear_dia_neck = 20;

spline_mate_dia = 15;
spline_mate_len = 6.5; // longer than mg90s_shaft_len()
spline_mate_top_dia = 12;

// 623 bearing
bearing_len = 4;
bearing_bolt_len = 12 + 1; // bearing + spline length + self-tap length

// --- Aggregated dimensions ---
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);
function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len); // add clearance if needed
function joint_width() = joint_int_width() + 2 * spline_mate_len; // printed joint total width

// -----------------------------------------------------------------------------
// Bearing locator relative to finger motor pose
// -----------------------------------------------------------------------------
module knuckle_bearing_pos(i, finger_motor_pos, knuckle_range) {
  translate(finger_motor_pos[i][0])
    rotate(finger_motor_pos[i][1])
      translate([0, 0, -joint_int_width() / 2])
        translate([0, 0, -bearing_len])
          children();
}

// -----------------------------------------------------------------------------
// Tail arch helper for clearance over the servo horn
// -----------------------------------------------------------------------------
module knuckle_tail_arch() {
  translate(-mg90s_shaft_pos() + mg90s_base_pos()) {
    let (rad = 8)
    translate([20 - rad, 0, -(servo_tail_thickness + rear_flange + mg90s_shaft_len() - rad)])
      rotate([-90, 0, 0])
        linear_extrude(height=servo_tail_shaft_dia_shank, center=true)
          intersection() {
            circle(r=rad);
            square([rad, rad]);
          }
  }
}

// -----------------------------------------------------------------------------
// Knuckle segment: mates to knuckle spline and finger spline/bearing
// -----------------------------------------------------------------------------
module knuckle_part(i, finger_motor_pos, knuckle_range) {

  let (
    finger_origin = finger_motor_pos[i][0],
    jiw = joint_int_width()
  )
  difference() {
    // =========================
    // Positive geometry
    // =========================
    union() {
      // Main knuckle body
      hull() {
        // Mate to knuckle spline
        cylinder(d1=spline_mate_dia, d2=spline_mate_top_dia, h=spline_mate_len);

        // Mate to finger spline and bearing
        translate(finger_origin)
          rotate(finger_motor_pos[i][1]) {
            cylinder(d=spline_mate_dia, h=jiw, center=true);
            cylinder(d=spline_mate_top_dia, h=joint_width(), center=true);
          }

        // Wide span over the servo horn
        translate([spline_mate_dia, 10, 0]) cylinder(d=10, h=3);
        translate([spline_mate_dia, -10, 0]) cylinder(d=10, h=3);

        // Reach down to second shaft
        knuckle_tail_arch();
      }

      // Join arch to tail shaft
      hull() {
        translate(-mg90s_shaft_pos() + mg90s_base_pos())
          translate([0, 0, -(servo_tail_thickness + rear_flange + mg90s_shaft_len())])
            cylinder(d=servo_tail_shaft_dia_shank, h=rear_flange);
        knuckle_tail_arch();
      }

      // Tail shaft into palm
      translate(-mg90s_shaft_pos() + mg90s_base_pos())
        translate([0, 0, -(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())]) {
          cylinder(d=servo_tail_shaft_dia_shank, h=rear_flange + rear_flange_bush);
          translate([0, 0, -mg90s_shaft_len()])
            cylinder(d=servo_tail_shaft_dia, h=mg90s_shaft_len() + rear_flange + rear_flange_bush);
        }
    }

    // =========================
    // Negative / clearances
    // =========================
    union() {
      // Knuckle servo spline and through-bolt
      translate([0, 0, bolt_len]) cylinder(d=7, h=bolt_head_len); // bolt head
      cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); // through-bolt
      spline_shaft();

      // Palm motor negative space across knuckle range
      for (a = knuckle_range[i])
        rotate(v=[0, 0, 1], a=a) {
          let (
            clear_len = mg90s_shaft_len() + mg90s_shaft_pos()[2] - mg90s_base_pos()[2] + servo_tail_thickness,
            rad = mg90s_shaft_len()
          )
          translate([0, 0, -clear_len / 2])
            rotate([90, 0, 0])
              linear_extrude(height=1000, center=true)
                hull()for (x = [-1, 1])
                  for (y = [-1, 1])
                    translate([x * (13 - rad), y * (clear_len / 2 - rad)])
                      circle(r=rad);
        }

      // Finger-side interface: spline, bolt, body clearance, bearing
      translate(finger_motor_pos[i][0])
        rotate(finger_motor_pos[i][1]) {
          // Mate to finger servo spline with through-bolt
          translate([0, 0, jiw / 2]) {
            spline_shaft();
            translate([0, 0, bolt_len]) cylinder(d=7, h=bolt_head_len); // bolt head
            cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); // through-bolt
          }

          // Clearance for finger servo body
          hull() {
            cylinder(d=motor_socket_clear_dia_neck, h=jiw, center=true);
            cylinder(d=motor_socket_clear_dia, h=jiw - 10, center=true);
          }

          // Bearing pocket and tail bolt tunnel
          translate([0, 0, -jiw / 2]) {
            translate([0, 0, -bearing_len]) bearing(negative=true);
            translate([0, 0, -bearing_bolt_len - bearing_len]) cylinder(d=8.2, h=bearing_bolt_len); // match bearing spec
          }
        }
    }
  }
}
