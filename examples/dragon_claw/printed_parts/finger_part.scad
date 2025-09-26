use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

bolt_len = mg90s_shaft_len() + 1; //not the true bolt length, the thread does not reach the bottom of the shaft.
bolt_head_len = 30;

motor_socket_dia = 25;
motor_socket_clear_dia = 28;
motor_socket_clear_dia_neck = 20;

spline_mate_dia = 15;
spline_mate_len = 6.5; //the length of the part that holds the spline and bearing, more than mg90s_shaft_len(),
spline_mate_top_dia = 12;

// 623 bearing
bearing_len = 4;
bearing_bolt_len = 12 + 1; // the bolt through the bearing in the tail of the finger servo, needs to be bearing + servo spline length for assembly + length to self-tap
servo_connector_box = (2.54 * [1, 3]) + [1, 1]; // plenty of space around 3-pin header

//a parameter describing the total width of servo and tail bolt
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);

function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len); // could add clearance here to avoid crushing the servo with the tail bolt
function joint_width() = joint_int_width() + 2 * spline_mate_len; //total width of the printed joint

function joint_body_width() = joint_int_width() - 2 * mg90s_shaft_len(); // clearance to insert the shaft at the tail side, mirrored on the shaft side
function finger_tail_bolt_len() = 3;

module finger_bearing_pos(i, claw_motor_pos) {
  finger_origin = [0, 0, 0];
  claw_origin = finger_origin + claw_motor_pos[i][0];
  claw_tail_pos = claw_origin - [0, 0, joint_int_width() / 2];
  translate(claw_origin) rotate(claw_motor_pos[i][1])
      translate([0, 0, -joint_int_width() / 2])
        translate([0, 0, -bearing_len])
          children();
}

module finger_part(i, claw_motor_pos) {

  finger_origin = [0, 0, 0];
  finger_shaft_pos = finger_origin + [0, 0, joint_int_width() / 2];
  finger_tail_pos = finger_origin - [0, 0, joint_int_width() / 2];

  claw_origin = finger_origin + claw_motor_pos[i][0];

  difference() {
    union() {
      //finger parts
      hull() {
        //fill the knuckle socket and enclose the motor
        translate(finger_origin)
          linear_extrude(height=joint_body_width(), center=true) {
            mg90s_section(clearance=2);
            circle(d=motor_socket_dia);
          }
        //accept the servo spline and bearing
        translate(claw_origin) rotate(claw_motor_pos[i][1]) {
            cylinder(d=spline_mate_dia, h=joint_int_width(), center=true);
            cylinder(d=spline_mate_top_dia, h=joint_width(), center=true);
          }
      }
    }
    //finger negative space
    union() {
      // mounting space for finger servo motor
      translate(finger_shaft_pos - mg90s_shaft_pos()) {
        //get into mg90s coords
        translate(mg90s_base_pos())
          linear_extrude(height=40)
            mg90s_section();
        translate([0, 0, mg90s_bolt_bottom_pos()[0][2]])
          linear_extrude(height=40)
            mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
        for (screw_pos = mg90s_bolt_top_pos())
          translate(screw_pos)
            translate([0, 0, -servo_bolt_depth])
              cylinder(d=servo_bolt_dia, h=servo_bolt_depth);

        //#mg90s();
        //wire channel
        mg90s_wire_channel(wrap_under=false);
      }
      translate(finger_origin) {
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
      //finger motor tail bolt
      translate(finger_origin + [0, 0, mg90s_base_pos()[2] - finger_tail_bolt_len()]) cylinder(h=finger_tail_bolt_len(), d=2.5);
      //finger_bolt spacer slides in from underside
      hull() {
        translate(finger_origin + [0, 0, mg90s_base_pos()[2] - finger_tail_bolt_len() - mg90s_shaft_len()]) cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
        translate(finger_origin + [motor_socket_dia / 2, 0, mg90s_base_pos()[2] - finger_tail_bolt_len() - mg90s_shaft_len()]) cylinder(h=mg90s_shaft_len(), d=spline_mate_dia + 0.5);
      }
      translate(claw_origin) rotate(claw_motor_pos[i][1]) {
          // mate to claw servo spline
          translate([0, 0, joint_int_width() / 2]) {
            spline_shaft();
            cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); //through-bolt for spline
            translate([0, 0, bolt_len]) cylinder(d=7, h=bolt_head_len); //through-bolt head for spline
          }
          // clearance for claw servo body
          hull() {
            cylinder(d=motor_socket_clear_dia_neck, h=joint_int_width(), center=true);
            cylinder(d=motor_socket_clear_dia, h=joint_int_width() - 10, center=true);
          }
          // bearing
          translate([0, 0, -joint_int_width() / 2]) {
            translate([0, 0, -bearing_len]) bearing(negative=true);
            translate([0, 0, -bearing_bolt_len - bearing_len]) cylinder(d=8.2, h=bearing_bolt_len); //8.2 should come from bearing module
          }
        }
    }
  }
}
