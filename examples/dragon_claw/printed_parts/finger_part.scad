use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

// --- Fasteners / clearances ---
servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

// --- Spline + bolt geometry ---
bolt_len = mg90s_shaft_len() + 1; // thread does not reach bottom of shaft
bolt_head_len = 30;

// --- Motor socket ---
motor_socket_dia = 25;
motor_socket_clear_dia = 28;
motor_socket_clear_dia_neck = 20;

// --- Spline mate ---
spline_mate_dia = 15;
spline_mate_len = 6.5; // longer than mg90s_shaft_len()
spline_mate_top_dia = 12;

// --- 623 bearing and tail bolt stack ---
bearing_len = 4;
bearing_bolt_len = 12 + 1; // bearing + spline len + self-tap allowance

// --- Servo connector envelope (around 3-pin 2.54 header) ---
servo_connector_box = (2.54 * [1, 3]) + [1, 1];

// --- Aggregated dimensions ---
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);
function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len); // add clearance if needed
function joint_width() = joint_int_width() + 2 * spline_mate_len; // printed joint total width
function joint_body_width() = joint_int_width() - 2 * mg90s_shaft_len(); // tail and spline side insert clearance
function finger_tail_bolt_len() = 3;

// -----------------------------------------------------------------------------
// Bearing locator for the finger (positions child content at bearing pocket)
// -----------------------------------------------------------------------------
module finger_bearing_pos(i, claw_motor_pos) {
  let (
    finger_origin = [0, 0, 0],
    claw_origin = finger_origin + claw_motor_pos[i][0],
    jiw = joint_int_width()
  )
  translate(claw_origin)
    rotate(claw_motor_pos[i][1])
      translate([0, 0, -jiw / 2])
        translate([0, 0, -bearing_len])
          children();
}

// -----------------------------------------------------------------------------
// Finger segment with motor cavity, connector exit, wire slots, and spline/bearing interface
// -----------------------------------------------------------------------------
module finger_part(i, claw_motor_pos) {

  // Local frames
  let (
    finger_origin = [0, 0, 0],
    jiw = joint_int_width(),
    jbw = joint_body_width(),
    jw = joint_width(),
    finger_shaft_pos = finger_origin + [0, 0, jiw / 2],
    finger_tail_pos = finger_origin - [0, 0, jiw / 2],
    claw_origin = finger_origin + claw_motor_pos[i][0],
    base_z = mg90s_base_pos()[2]
  )
  difference() {
    // =========================
    // Positive geometry
    // =========================
    union() {
      // Finger shell: wrap servo body and form socket to claw motor
      hull() {
        // Fill the knuckle socket and enclose the motor
        translate(finger_origin)
          linear_extrude(height=jbw, center=true) {
            mg90s_section(clearance=2);
            circle(d=motor_socket_dia);
          }

        // Accept the servo spline and bearing (at claw origin)
        translate(claw_origin)
          rotate(claw_motor_pos[i][1]) {
            cylinder(d=spline_mate_dia, h=jiw, center=true);
            cylinder(d=spline_mate_top_dia, h=jw, center=true);
          }
      }
    }

    // =========================
    // Negative / clearances
    // =========================
    union() {
      // Mounting space for finger servo motor (in MG90S coordinates)
      translate(finger_shaft_pos - mg90s_shaft_pos()) {
        // Main body
        translate(mg90s_base_pos())
          linear_extrude(height=40) mg90s_section();

        // Wing zone
        translate([0, 0, mg90s_bolt_bottom_pos()[0][2]])
          linear_extrude(height=40)
            mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);

        // Mounting bolts (servo_bolt_depth as bolt length)
        for (screw_pos = mg90s_bolt_top_pos())
          translate(screw_pos + [0, 0, -servo_bolt_depth])
            cylinder(d=servo_bolt_dia, h=servo_bolt_depth);

        // Wire channel
        mg90s_wire_channel(wrap_under=false);
      }

      // Connector exit and over-outside wire slot
      translate(finger_origin) {
        // Connector exit
        rotate([0, 90, 0])
          linear_extrude(height=20)
            square(servo_connector_box, center=true);

        // Over-outside wire channel
        let (slot_depth = 2, slot_width = mg90s_wire_width())
        linear_extrude(height=slot_width, center=true) {
          difference() {
            intersection() {
              circle(d=motor_socket_dia + 5);
              translate([-slot_depth, -motor_socket_dia, -slot_width / 2])
                square([motor_socket_dia, motor_socket_dia]);
            }
            translate([-slot_depth, 0, 0])
              circle(d=motor_socket_dia);
          }
        }
      }

      // Finger motor tail bolt (self-tap pilot)
      translate(finger_origin + [0, 0, base_z - finger_tail_bolt_len()])
        cylinder(h=finger_tail_bolt_len(), d=2.5);

      // Finger bolt spacer slides in from underside (assembly clearance)
      hull() {
        translate(finger_origin + [0, 0, base_z - finger_tail_bolt_len() - mg90s_shaft_len()])
          cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
        translate(finger_origin + [motor_socket_dia / 2, 0, base_z - finger_tail_bolt_len() - mg90s_shaft_len()])
          cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
      }

      // Claw-side interface: spline, through-bolt, body clearance, and bearing pocket
      translate(claw_origin)
        rotate(claw_motor_pos[i][1]) {
          // Mate to claw servo spline
          translate([0, 0, jiw / 2]) {
            spline_shaft();
            cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); // through-bolt for spline
            translate([0, 0, bolt_len])
              cylinder(d=7, h=bolt_head_len);
            // bolt head
          }

          // Clearance for claw servo body
          hull() {
            cylinder(d=motor_socket_clear_dia_neck, h=jiw, center=true);
            cylinder(d=motor_socket_clear_dia, h=jiw - 10, center=true);
          }

          // Bearing pocket and tail bolt tunnel
          translate([0, 0, -jiw / 2]) {
            translate([0, 0, -bearing_len]) bearing(negative=true);
            translate([0, 0, -bearing_bolt_len - bearing_len]) cylinder(d=8.2, h=bearing_bolt_len); // match bearing module spec
          }
        }
    }
  }
}
