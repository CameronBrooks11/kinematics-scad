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

module palm_part(knuckle_motor_pos, knuckle_range) {
  difference() {
    union() {
      for (i = [0:len(knuckle_motor_pos) - 1])
        let (mot = knuckle_motor_pos[i]) {
          hull() {
            translate(mot[0]) rotate(mot[1]) {
                // house body of servo
                translate(mg90s_base_pos() - [0, 0, servo_tail_thickness + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len()])
                  linear_extrude(height=servo_tail_thickness + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len() + mg90s_bolt_top_pos()[0][2] - mg90s_base_center_pos()[2])
                    mg90s_section(use_hull=true, clearance=5);
                // servo anchor points
                translate([0, 0, mg90s_bolt_bottom_pos()[0][2] - servo_bolt_depth])
                  linear_extrude(height=servo_bolt_depth)
                    mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
              }
            translate(wrist_pos) cylinder(d=wrist_dia); // extend hull into arm
          }
        }
      //hull(){
      //    translate(wrist_pos)cylinder(d=wrist_dia); // extend hull into arm
      //    translate(arm_pos)cylinder(d=50); // extend hull into arm
      //}
    }

    color("red") union() {
        // palm negative space
        for (i = [0:len(knuckle_motor_pos) - 1])
          let (mot = knuckle_motor_pos[i]) {
            translate(mot[0]) rotate(mot[1]) {

                //mg90s();
                translate(mg90s_base_pos()) linear_extrude(height=40) mg90s_section();
                translate([0, 0, mg90s_bolt_bottom_pos()[0][2]])
                  linear_extrude(height=40)
                    mg90s_section(slice_height=mg90s_bolt_bottom_pos()[0][2], use_hull=true);
                mg90s_wire_channel(wrap_under=true);

                //bolts for the mg90s
                translate([0, 0, -servo_bolt_depth]) {
                  translate(mg90s_bolt_top_pos()[0]) cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                  translate(mg90s_bolt_top_pos()[1]) cylinder(d=servo_bolt_dia, h=servo_bolt_depth);
                }

                // clearance for knuckle tail shafts
                translate(mg90s_base_pos() + [mg90s_shaft_pos()[0], 0, 0]) {
                  // shaft proper
                  translate([0, 0, -(servo_tail_thickness + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len())]) {
                    //shaft as required
                    cylinder(d=servo_tail_shaft_dia_int, h=rear_flange + rear_flange_bush + 2 * mg90s_shaft_len());
                    //shaft extended to allow cleaning the print
                    cylinder(d=servo_tail_shaft_dia_int, h=30 + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len());
                  }
                  // rocking clearance
                  hull() {
                    translate([0, 0, -(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())])
                      cylinder(d=servo_tail_shaft_dia_shank_int, h=rear_flange + rear_flange_bush + mg90s_shaft_len());
                    for (a = knuckle_range[i])
                      rotate(v=[0, 0, 1], a=a)
                        translate([15, 0, -(servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len())])
                          cylinder(d=16, h=rear_flange + rear_flange_bush + mg90s_shaft_len());
                  }
                }

                //extra clearance
                //etc
              }
          }
        //cavity joining motor bases
        for (mot = knuckle_motor_pos) {
          //knuckle motor wires
          hull() {
            translate(mot[0]) rotate(mot[1]) {
                translate(mg90s_base_center_pos() + [-5, 0, 0]) {
                  //linear_extrude(height=1)square([10,10], center=true);
                  linear_extrude(height=1) rotate(45) square([7, 7], center=true);
                }
              }
            // XXX duplicated cylinder
            translate(wrist_pos) cylinder(d=40); // extend hull into arm
          }
          //finger and claw wires
          hull() {
            translate(mot[0]) rotate(mot[1]) {
                translate([-19 + mg90s_body_center_pos()[0], 0, (mg90s_bolt_top_pos()[0]) [2]]) {
                  rotate([90, 0, 0]) cylinder(d=4, h=8, center=true);
                }
              }
            // XXX duplicated cylinder
            translate(wrist_pos) cylinder(d=20); // extend hull into arm
          }
        }
        //hull(){
        //    // XXX duplicated cylinder
        //    translate(wrist_pos)cylinder(d=30); // extend hull into arm
        //    translate(arm_pos + [0,0,-1])cylinder(d=30); // extend hull into arm
        //}
      }
  }
}
