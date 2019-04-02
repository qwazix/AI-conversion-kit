$fn=64;
d=15; //diameter of the ears
sd=2; //diameter of the hole
h=5;
e=0.01;
2e=2*e;
lensd=60;

rotate([90,0,0])
rabbit_ears();
ringd=65;
translate([0,ringd/2,-h/2]) ring(ringd);

module rabbit_ears(slope=0){
    difference(){
        rotate([90,0,0]) cylinder(d=d, h=h);
        // translate([0,0,-d/4]) cube([d,d,d/2], true);
        translate([0,-h,d/3]) rotate([-slope,0,0]) cube([d,h,d],true);
        translate([0, e, -lensd/2]) rotate([90,0,0]) cylinder(d=lensd, h=2*h);
        hull(){
            rotate([90,0,0]) {
                translate([0,sd,-e]) cylinder(d=sd+0.1, h=2*h);
                translate([0,d,-e]) cylinder(d=sd+0.1, h=2*h);
            }

        }
    }

}



module ring(d=65, t=2){
    difference(){
        cylinder(d=d, h=5);
        cylinder(d=d-t, h=5+2e);

    }

}