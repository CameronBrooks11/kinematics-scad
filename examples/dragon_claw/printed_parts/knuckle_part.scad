use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

bolt_len = mg90s_shaft_len() + 1; //not the true bolt length, the thread does not reach the bottom of the shaft.
bolt_head_len = 30;
rear_flange = 5;
rear_flange_bush = 0.5;

servo_tail_shaft_dia = 5;
servo_tail_shaft_dia_shank = servo_tail_shaft_dia + 2;

servo_tail_shaft_dia_int = servo_tail_shaft_dia + 0.5;
servo_tail_shaft_dia_shank_int = servo_tail_shaft_dia_shank + 2;
servo_tail_thickness = 3;

wrist_pos = [0, 0, -40];
wrist_dia = 60;
arm_pos = [-20, -30, -70];

motor_socket_dia = 25;
motor_socket_clear_dia = 28;
motor_socket_clear_dia_neck = 20;

spline_mate_dia = 15;
spline_mate_len = 6.5; //the length of the part that holds the spline and bearing, more than mg90s_shaft_len(),
spline_mate_top_dia = 12;

//623 bearing
bearing_len = 4;
bearing_od = 10;
bearing_id = 3;
bearing_bolt_len = 12 + 1; // the bolt through the bearing in the tail of the finger servo, needs to be bearing + servo spline length for assembly + length to self-tap
M3_self_tap_dia = 2.5;
servo_connector_box = (2.54 * [1, 3]) + [1, 1]; // plenty of space around 3-pin header

//a parameter describing the total width of servo and tail bolt
function servo_body_length() = (mg90s_shaft_pos()[2] - mg90s_base_pos()[2]);

function joint_int_width() = servo_body_length() + (bearing_bolt_len - bearing_len); // could add clearance here to avoid crushing the servo with the tail bolt
function joint_width() = joint_int_width() + 2 * spline_mate_len; //total width of the printed joint

function joint_body_width() = joint_int_width() - 2 * mg90s_shaft_len(); // clearance to insert the shaft at the tail side, mirrored on the shaft side
function finger_tail_bolt_len() = 3;

module knuckle_bearing_pos(i, finger_motor_pos, knuckle_range) {
  translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1])
      translate([0, 0, -joint_int_width() / 2])
        translate([0, 0, -bearing_len])
          children();
}

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

module knuckle_part(i, finger_motor_pos, knuckle_range) {

  finger_origin = finger_motor_pos[i][0];

  difference() {
    union() {
      // knuckle parts
      hull() {
        // mate to knuckle spline
        cylinder(d1=spline_mate_dia, d2=spline_mate_top_dia, h=spline_mate_len);
        // mate to finger spline and bearing
        translate(finger_origin) rotate(finger_motor_pos[i][1]) {
            cylinder(d=spline_mate_dia, h=joint_int_width(), center=true);
            cylinder(d=spline_mate_top_dia, h=joint_width(), center=true);
          }
        // wide span over the servo horn
        translate([spline_mate_dia, 10, 0]) cylinder(d=10, h=3);
        translate([spline_mate_dia, -10, 0]) cylinder(d=10, h=3);
        //reach down to second shaft
        knuckle_tail_arch();
      }
      // join arch to tail shaft
      hull() {
        translate(-mg90s_shaft_pos() + mg90s_base_pos())
          translate([0, 0, -(servo_tail_thickness + rear_flange + mg90s_shaft_len())])
            cylinder(d=servo_tail_shaft_dia_shank, h=rear_flange);
        knuckle_tail_arch();
      }
      //tail shaft into palm
      translate(-mg90s_shaft_pos() + mg90s_base_pos())
        translate([0, 0, -(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())]) {
          cylinder(d=servo_tail_shaft_dia_shank, h=rear_flange + rear_flange_bush);
          translate([0, 0, -mg90s_shaft_len()])
            cylinder(d=servo_tail_shaft_dia, h=mg90s_shaft_len() + rear_flange + rear_flange_bush);
        }
    }
    // knuckle negative space
    union() {
      // mate to knuckle servo spline
      translate([0, 0, bolt_len]) cylinder(d=7, h=bolt_head_len); //through-bolt head for spline
      cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); //through-bolt for spline
      spline_shaft();

      // palm motor negative space
      for (a = knuckle_range[i])
        rotate(v=[0, 0, 1], a=a) {
          let (
            clear_len = mg90s_shaft_len() + mg90s_shaft_pos()[2] - mg90s_base_pos()[2] + servo_tail_thickness,
            rad = mg90s_shaft_len()
          ) translate([0, 0, -clear_len / 2])
            rotate([90, 0, 0]) linear_extrude(height=1000, center=true) hull()for (x = [-1, 1])
                  for (y = [-1, 1])
                    translate([x * (13 - rad), y * (clear_len / 2 - rad)])
                      circle(r=rad);
        }
      translate(finger_motor_pos[i][0]) rotate(finger_motor_pos[i][1]) {
          // mate to finger servo spline
          translate([0, 0, joint_int_width() / 2]) {
            spline_shaft();
            translate([0, 0, bolt_len]) cylinder(d=7, h=bolt_head_len); //through-bolt head for spline
            cylinder(d=mg90s_shaft_bolt_dia(), h=bolt_len + bolt_head_len); //through-bolt for spline
          }

          // clearance for finger servo body
          hull() {
            cylinder(d=motor_socket_clear_dia_neck, h=joint_int_width(), center=true);
            cylinder(d=motor_socket_clear_dia, h=joint_int_width() - 10, center=true);
          }
          // space for bearing
          translate([0, 0, -joint_int_width() / 2]) {
            translate([0, 0, -bearing_len]) bearing(negative=true);
            translate([0, 0, -bearing_bolt_len - bearing_len]) cylinder(d=8.2, h=bearing_bolt_len); //8.2 should come from bearing module
          }
        }
    }
  }
}
