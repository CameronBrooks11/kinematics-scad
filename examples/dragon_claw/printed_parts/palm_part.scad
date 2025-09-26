use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

servo_bolt_depth = 10;
servo_bolt_dia = 1.6;

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

module palm_part(knuckle_motor_pos, knuckle_range, wrist_extension = false) {
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
      if (wrist_extension) {
        hull() {
          translate(wrist_pos) cylinder(d=wrist_dia); // extend hull into arm
          translate(arm_pos) cylinder(d=75); // extend hull into arm
        }
      }
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
                //extra clearance etc. can go here
              }
          }
        //cavity joining motor bases
        for (mot = knuckle_motor_pos) {
          //knuckle motor wires
          hull() {
            translate(mot[0]) rotate(mot[1]) {
                translate(mg90s_base_center_pos() + [-5, 0, 0]) {
                  linear_extrude(height=1) rotate(45) square([7, 7], center=true);
                }
              }
            // cylinder to cut out from -z surface of base part to create main bottom opening
            translate(wrist_pos - [0, 0, zFite]) cylinder(d=40); // extend hull into arm
          }
          //finger and claw wires
          hull() {
            translate(mot[0]) rotate(mot[1]) {
                translate([-19 + mg90s_body_center_pos()[0], 0, (mg90s_bolt_top_pos()[0]) [2]]) {
                  rotate([90, 0, 0]) cylinder(d=4, h=8, center=true);
                }
              }
            // cut from -z surface if first finger segment
            translate(wrist_pos) cylinder(d=20); // extend hull into arm
          }
        }
        if (wrist_extension) {
          hull() {
            translate(wrist_pos) cylinder(d=30); // extend hull into arm
            translate(arm_pos + [0, 0, -1]) cylinder(d=30); // extend hull into arm
          }
        }
      }
  }
}
