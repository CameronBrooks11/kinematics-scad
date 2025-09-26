include <../settings.scad>

// -----------------------------------------------------------------------------
// Bearing model
// Parameters:
//   od1      - outer diameter (main body)
//   od2      - outer diameter (inner race / lip)
//   id1      - inner diameter (shaft clearance)
//   id2      - inner diameter (inner race)
//   l        - length of the bearing
//   negative - if true, generates a negative "cutout" volume instead of geometry
// -----------------------------------------------------------------------------
module bearing(
  od1 = 10,
  od2 = 8.2,
  id1 = 3,
  id2 = 4.8,
  l = 4,
  negative = false
) {
  translate([0, 0, l / 2]) {

    // --- Solid geometry ---
    if (!negative) {
      // Outer ring shell
      color("gray")
        difference() {
          cylinder(d=od1, h=l, center=true);
          cylinder(d=od2, h=l + 0.1, center=true);
        }

      // Inner race + shaft clearance
      difference() {
        union() {
          color("lightgray")
            cylinder(d=od2, h=l * 0.8, center=true);

          color("gray")
            cylinder(d=id2, h=l, center=true);
        }
        color("gray")
          cylinder(d=id1, h=l + 0.1, center=true);
      }
    }

    // --- Negative / cutout geometry ---
    if (negative) {
      cylinder(d=od1, h=l + 0.1, center=true);
      cylinder(d=od2, h=l + 1, center=true);
    }
  }
}

// Example preview
bearing();
