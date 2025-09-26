
module bearing(od1 = 10, od2 = 8.2, id1 = 3, id2 = 4.8, l = 4, negative = false) {
  if (!negative) {
    translate([0, 0, l / 2]) {
      color("gray") difference() {
          cylinder(d=od1, h=l, center=true);
          cylinder(d=od2, h=l + 0.1, center=true);
        }
      difference() {
        union() {
          color("lightgray") cylinder(d=od2, h=l * 0.8, center=true);
          color("gray") cylinder(d=id2, h=l, center=true);
        }
        color("gray") cylinder(d=id1, h=l + 0.1, center=true);
      }
    }
  }
  if (negative) {
    translate([0, 0, l / 2]) {
      cylinder(d=od1, h=l + 0.1, center=true);
      cylinder(d=od2, h=l + 1, center=true);
    }
  }
}
