use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

// --- Fasteners / clearances ---
servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

// --- Interface diameters ---
motor_socket_dia = 25;
spline_mate_dia = 15;

// --- 623 bearing + tail bolt ---
bearing_len = 4;
bearing_bolt_len = 12 + 1; // bearing + spline length + self-tap length
M3_self_tap_dia = 2.5;

// --- Servo connector envelope (around 3-pin 2.54 header) ---
servo_connector_box = (2.54 * [1, 3]) + [1, 1];

// --- Aggregated dimensions ---
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);
// Total interior width = servo body + exposed bolt shank (minus bearing thickness)
function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len);
// Clearance to insert shaft from tail and spline sides
function joint_body_width() = joint_int_width() - 2 * mg90s_shaft_len();

// -----------------------------------------------------------------------------
// Claw tip + motor carrier
// -----------------------------------------------------------------------------
module claw_part(i, claw_point_pos) {

  // Local frames
  claw_origin = [0, 0, 0];
  claw_shaft_pos = claw_origin + [0, 0, joint_int_width() / 2];
  claw_tail_pos = claw_origin - [0, 0, joint_int_width() / 2];

  difference() {
    // =========================
    // Positive geometry
    // =========================
    union() {
      // Skin from claw tip to servo wrap
      hull() {
        color("red")
          translate(claw_point_pos[i][0]) sphere(r=1);

        // Wrap servo body + motor socket
        translate(claw_origin)
          linear_extrude(height=joint_body_width(), center=true) {
            mg90s_section(clearance=2);
            circle(d=motor_socket_dia);
          }
      }

      // Servo anchor pads (extruded around wing bottoms)
      translate(
        claw_shaft_pos - mg90s_shaft_pos() + [0, 0, mg90s_bolt_bottom_pos()[0][2]] // to wing bottom
        + [0, 0, -servo_bolt_depth] // to extrusion start
      )
        linear_extrude(height=servo_bolt_depth)
          mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
    }

    // =========================
    // Negative / clearances
    // =========================
    union() {
      // Servo cavity, wings, bolts, and wire channel (in servo coordinates)
      translate(claw_shaft_pos - mg90s_shaft_pos()) {
        // Main servo body
        translate(mg90s_base_pos())
          linear_extrude(height=40) mg90s_section();

        // Servo wings zone
        translate([0, 0, mg90s_bolt_bottom_pos()[0][2]])
          linear_extrude(height=40)
            mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);

        // Mounting bolts (treat servo_bolt_depth as bolt length)
        for (screw_pos = mg90s_bolt_top_pos())
          translate(screw_pos + [0, 0, -servo_bolt_depth])
            cylinder(d=servo_bolt_dia, h=servo_bolt_depth);

        // Wire channel
        mg90s_wire_channel(wrap_under=false);
      }

      // Connector exit + over-outside wire slot
      translate(claw_origin) {
        // Connector exit (sideways)
        rotate([0, 90, 0])
          linear_extrude(height=20)
            square(servo_connector_box, center=true);

        // Over-outside wire channel profile
        // Uses intersection of big ring and rectangular bite, minus socket circle
        // then extruded to slot width.
        linear_extrude(height=mg90s_wire_width(), center=true) {
          difference() {
            intersection() {
              circle(d=motor_socket_dia + 5);
              translate([-2, -motor_socket_dia, -mg90s_wire_width() / 2])
                square([motor_socket_dia, motor_socket_dia]);
            }
            translate([-2, 0, 0]) circle(d=motor_socket_dia);
          }
        }
      }

      // Tail spacer and assembly clearance around spline mate
      translate(claw_tail_pos) {
        // Self-tap M3 pilot through tail
        translate([0, 0, -bearing_len])
          cylinder(h=bearing_bolt_len, d=M3_self_tap_dia);

        // Spline mating clearance, widened by hull to give assembly space
        hull() {
          // TODO: maybe create an assembly clearance function that takes a path as an arg
          cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
          translate([motor_socket_dia / 2, 0, 0])
            cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
        }
      }
    }
  }
}
