use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

motor_socket_dia = 25;

spline_mate_dia = 15;

//623 bearing
bearing_len = 4;
bearing_bolt_len = 12 + 1; // the bolt through the bearing in the tail of the finger servo, needs to be bearing + servo spline length for assembly + length to self-tap
M3_self_tap_dia = 2.5;
servo_connector_box = (2.54 * [1, 3]) + [1, 1]; // plenty of space around 3-pin header

//a parameter describing the total width of servo and tail bolt
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);

function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len); // could add clearance here to avoid crushing the servo with the tail bolt

function joint_body_width() = joint_int_width() - 2 * mg90s_shaft_len(); // clearance to insert the shaft at the tail side, mirrored on the shaft side

module claw_part(i, claw_point_pos) {

  claw_origin = [0, 0, 0];
  claw_shaft_pos = claw_origin + [0, 0, joint_int_width() / 2];
  claw_tail_pos = claw_origin - [0, 0, joint_int_width() / 2];

  difference() {
    union() {
      hull() {
        color("red") translate(claw_point_pos[i][0]) sphere(r=1);
        //wrap servo body
        translate(claw_origin)
          linear_extrude(height=joint_body_width(), center=true) {
            mg90s_section(clearance=2);
            circle(d=motor_socket_dia);
          }
      }
      // servo anchor points
      translate(
        claw_shaft_pos - mg90s_shaft_pos() + [0, 0, mg90s_bolt_bottom_pos()[0][2]] + //to the bottom of the wings
        [0, 0, -servo_bolt_depth] //to the bottom of the extrusion
      ) {
        linear_extrude(height=servo_bolt_depth)
          mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
      }
    }

    union() {
      //claw negative space
      translate(claw_shaft_pos - mg90s_shaft_pos()) {
        //get into mg90s coords
        // servo body
        translate(mg90s_base_pos())
          linear_extrude(height=40)
            mg90s_section();
        // servo wings
        translate([0, 0, mg90s_bolt_bottom_pos()[0][2]])
          linear_extrude(height=40)
            mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
        //mounting bolts (treating servo_bolt_depth as bolt length)
        for (screw_pos = mg90s_bolt_top_pos())
          translate(screw_pos)
            translate([0, 0, -servo_bolt_depth])
              cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
        //#mg90s();
        //wire channel
        mg90s_wire_channel(wrap_under=false);
      }
      translate(claw_origin) {
        //servo connector exit
        rotate([0, 90, 0]) linear_extrude(height=20) square(servo_connector_box, center=true);
        slot_depth = 2;
        slot_width = mg90s_wire_width();
        //wire channel over outside
        linear_extrude(height=slot_width, center=true) {
          difference() {
            intersection() {
              circle(d=motor_socket_dia + 5);
              translate([-slot_depth, -motor_socket_dia, -slot_width / 2]) square([motor_socket_dia, motor_socket_dia]);
            }
            translate([-slot_depth, 0, 0]) circle(d=motor_socket_dia);
          }
        }
      }
      //tail spacer and assembly clearance
      translate(claw_tail_pos) {
        translate([0, 0, -bearing_len]) {
          cylinder(h=bearing_bolt_len, d=M3_self_tap_dia);
        }
        hull() {
          // TODO: maybe create an assembly clearance function that takes a path as an arg
          cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
          translate([motor_socket_dia / 2, 0, 0]) cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
        }
      }
    }
  }
}
