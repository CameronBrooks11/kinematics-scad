use <scad-utils/transformations.scad>

use <../lib/mg90s.scad>
use <../lib/bearing.scad>

include <../settings.scad>

// --- Parameters ---
servo_bolt_depth = 10;
servo_bolt_dia   = 1.6;

rear_flange      = 5;
rear_flange_bush = 0.5;

servo_tail_shaft_dia        = 5;
servo_tail_shaft_dia_shank  = servo_tail_shaft_dia + 2;

servo_tail_shaft_dia_int       = servo_tail_shaft_dia + 0.5;
servo_tail_shaft_dia_shank_int = servo_tail_shaft_dia_shank + 2;
servo_tail_thickness           = 3;

wrist_pos = [0, 0, -40];
wrist_dia = 60;
arm_pos   = [-20, -30, -70];

module palm_part(knuckle_motor_pos, knuckle_range, wrist_extension = false) {
  // Common stack heights for clarity
  // Full tail stack includes 2× shaft length; rock stack includes 1×
  // These are used only for translations/heights; keep values identical to original.
  difference() {
    // === Positive volume =====================================================
    union() {
      for (i = [0:len(knuckle_motor_pos) - 1]) {
        let (
          mot                 = knuckle_motor_pos[i],
          tail_stack_full     = servo_tail_thickness + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len(),
          tail_stack_rock     = servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len(),
          base_center_z       = mg90s_base_center_pos()[2],
          bolt_top_z          = mg90s_bolt_top_pos()[0][2],
          bolt_bottom_z       = mg90s_bolt_bottom_pos()[0][2],
          house_extrude_h     = tail_stack_full + bolt_top_z - base_center_z,
          house_extrude_shift = mg90s_base_pos() - [0, 0, tail_stack_full]
        )
        hull() {
          // Servo housing + anchor pads
          translate(mot[0]) rotate(mot[1]) {
            // House body of servo
            translate(house_extrude_shift)
              linear_extrude(height = house_extrude_h)
                mg90s_section(use_hull = true, clearance = 5);

            // Servo anchor points
            translate([0, 0, bolt_bottom_z - servo_bolt_depth])
              linear_extrude(height = servo_bolt_depth)
                mg90s_section(slice_height = bolt_bottom_z, use_hull = true);
          }

          // Extend hull into wrist
          translate(wrist_pos) cylinder(d = wrist_dia);
        }
      }

      if (wrist_extension) {
        hull() {
          translate(wrist_pos) cylinder(d = wrist_dia);
          translate(arm_pos)   cylinder(d = 75);
        }
      }
    }

    // === Negative volume =====================================================
    color("red")
    union() {
      // Palm negative space at each motor location
      for (i = [0:len(knuckle_motor_pos) - 1]) {
        let (
          mot                 = knuckle_motor_pos[i],
          tail_stack_full     = servo_tail_thickness + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len(),
          tail_stack_rock     = servo_tail_thickness + rear_flange + rear_flange_bush + mg90s_shaft_len(),
          bolt_bottom_z       = mg90s_bolt_bottom_pos()[0][2]
        )
        translate(mot[0]) rotate(mot[1]) {

          // Main body and bolt-zone clearances
          translate(mg90s_base_pos()) linear_extrude(height = 40) mg90s_section();
          translate([0, 0, bolt_bottom_z])
            linear_extrude(height = 40)
              mg90s_section(slice_height = bolt_bottom_z, use_hull = true);

          // Wire channel
          mg90s_wire_channel(wrap_under = true);

          // Bolts for the MG90S
          translate([0, 0, -servo_bolt_depth]) {
            translate(mg90s_bolt_top_pos()[0]) cylinder(d = servo_bolt_dia, h = servo_bolt_depth);
            translate(mg90s_bolt_top_pos()[1]) cylinder(d = servo_bolt_dia, h = servo_bolt_depth);
          }

          // Clearance for knuckle tail shafts
          translate(mg90s_base_pos() + [mg90s_shaft_pos()[0], 0, 0]) {
            // Shaft proper + extended cleanup tunnel
            translate([0, 0, -tail_stack_full]) {
              cylinder(d = servo_tail_shaft_dia_int, h = rear_flange + rear_flange_bush + 2 * mg90s_shaft_len());
              cylinder(d = servo_tail_shaft_dia_int, h = 30 + rear_flange + rear_flange_bush + 2 * mg90s_shaft_len());
            }

            // Rocking clearance
            hull() {
              translate([0, 0, -tail_stack_rock])
                cylinder(d = servo_tail_shaft_dia_shank_int, h = rear_flange + rear_flange_bush + mg90s_shaft_len());

              for (a = knuckle_range[i])
                rotate(v = [0, 0, 1], a = a)
                  translate([15, 0, -tail_stack_rock])
                    cylinder(d = 16, h = rear_flange + rear_flange_bush + mg90s_shaft_len());
            }
          }

          // Extra clearance etc. can go here
        }
      }

      // Cavity joining motor bases — knuckle motor wires
      for (mot = knuckle_motor_pos) {
        hull() {
          translate(mot[0]) rotate(mot[1]) {
            translate(mg90s_base_center_pos() + [-5, 0, 0])
              linear_extrude(height = 1) rotate(45) square([7, 7], center = true);
          }
          // Cut from -Z surface of base to create bottom opening
          translate(wrist_pos - [0, 0, zFite]) cylinder(d = 40);
        }

        // Finger and claw wires
        hull() {
          translate(mot[0]) rotate(mot[1]) {
            translate([-19 + mg90s_body_center_pos()[0], 0, (mg90s_bolt_top_pos()[0])[2]])
              rotate([90, 0, 0]) cylinder(d = 4, h = 8, center = true);
          }
          // Cut from -Z surface if first finger segment
          translate(wrist_pos) cylinder(d = 20);
        }
      }

      if (wrist_extension) {
        hull() {
          translate(wrist_pos)               cylinder(d = 30);
          translate(arm_pos + [0, 0, -1])   cylinder(d = 30);
        }
      }
    }
  }
}
