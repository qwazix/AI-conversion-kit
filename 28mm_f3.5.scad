//lens specific parameters
innerDiameter=57.62;//59.1; //on my 3D printer I had to increase that to 59.1 in order to fit 
thickness=1.33; //ring thickness
originalHeight=12.03; //original non AI ring height
rimHeight=2; //the height that you would actually need to file if you did the conversion by modifying the original aperture ring
apertureClicks=5; //how many aperture clicks does this lens have
AIridgePosition=4.66; //see http://www.chr-breitkopf.de/photo/aiconv.en.html#ai_pos
maxApertureInStopsOver5point6=1.2; //e.g. f/4 is 1 stop faster than 5.6 f/2.8 is 2 etc.
minApertureInStopsUnder5point6=3;

fatInnerRingThickness=0.53; 
fatInnerRingHeight=3;
fatInnerRingZ=1.25;
thinInnerRingThickness=0.9;
thinInnerRingHeight=2;
thinInnerRingZ=8;
//thinInnerRingDistanceFromRimTop=1.44;
//44.29

//parameters that should be the same throughout the NIKKOR line
apertureClickAngle=7; //this should be the same in all lenses

//cosmetic parameters
handleHeight=3.20; //the height of the fluted part of the aperture ring (cosmetic)
handleThickness=2.2; //the thickness of the above part (cosmetic)
handleRecessRadius=6; //the recess circle radius (cosmetic)
handleZ=5;

//implementation details
$fa = 3; //circle resolution
$fs = 1; //circle resolution 2
tolerance=2; //this is used so that the F5 openscad preview looks better


//intermediate values
outerDiameter=innerDiameter+thickness;
innerRadius=innerDiameter/2;
outerRadius=outerDiameter/2;

//rim
difference(){
    rim(originalHeight-rimHeight,innerRadius,thickness);
    //screw hole
    screw_hole();
}

//handle
difference(){
    translate([0,0,handleZ]) union() {
        cylinder(handleHeight,outerRadius+handleThickness,outerRadius+handleThickness);
        translate([0,0,handleHeight]) cylinder(1,outerRadius+handleThickness,outerRadius);
        translate([0,0,-1]) cylinder(1,outerRadius,outerRadius+handleThickness);
    }
    cylinder(originalHeight,outerRadius,outerRadius);   
    Radial_Array(30,12,outerRadius+handleRecessRadius*0.55) rotate([0,0,90]) scale([0.4,1,1]) cylinder(originalHeight+tolerance,handleRecessRadius,handleRecessRadius);
}

//fat(high) inner ring
difference(){
    translate([0,0,fatInnerRingZ]) rim(fatInnerRingHeight,innerRadius-fatInnerRingThickness,fatInnerRingThickness);
    mirror([0,1,0]) slice(2,originalHeight);
    
    rotate([0,0,-52]) mirror([0,1,0]) slice(2,originalHeight);
    //aperture clicks
    Radial_Array(apertureClickAngle,apertureClicks,innerRadius-fatInnerRingThickness) cylinder(originalHeight,0.7,0.7);
    //special min aperture click
    rotate([0,0,-apertureClicks*apertureClickAngle+4]) translate([0,innerRadius-fatInnerRingThickness,0]) cylinder(originalHeight,0.5,0.5);
    screw_hole();
}

//    rotate([0,0,-155]) mirror([0,1,0]) slice(2,originalHeight);
intersection(){
    translate([0,0,originalHeight-rimHeight]) rim(rimHeight,innerRadius,thickness+1);
    union(){
        //d80 max aperture switch ridge
        //our zero is f/11 so 2 stops under 5.6
        rotate([0,0,(minApertureInStopsUnder5point6-2)*apertureClickAngle-124]) slice(8, originalHeight,outerRadius+3);
        //actual AI ridge
        rotate([0,0,(-2-maxApertureInStopsOver5point6+AIridgePosition)*apertureClickAngle]) slice(60, originalHeight,outerRadius+3);
    }
}

//thin(upper) inner ring
difference(){
    union(){
        translate([0,0,thinInnerRingZ]) rim(thinInnerRingHeight,innerRadius-thinInnerRingThickness,thinInnerRingThickness);
    //small ridge to help with printing (balcony)
        translate([0,0,thinInnerRingZ-0.5]) coneRim(0.5,innerRadius-thinInnerRingThickness,thinInnerRingThickness);
    }
    mirror([0,1,0]) slice(54,originalHeight);
}

module screw_hole(){
    rotate([0,0,25]) translate([-innerRadius-thickness-tolerance*2,0,2.6]) rotate([90,0,90]) cylinder(7,1,1);
}

//Radial_Array(a,n,r){child object}
// produces a clockwise radial array of child objects rotated around the local z axis   
// a= interval angle 
// n= number of objects 
// r= radius distance 
//
module Radial_Array(a,n,r)
{
 for (k=[0:n-1])
 {
 rotate([0,0,-(a*k)])
 translate([0,r,0])
 for (k = [0:$children-1]) child(k);
 }
}

module slice(angle, height,radius=innerRadius){
    intersection() {
        mirror([1,0,0]) translate([-radius*1.2,0,0]) a_triangle(angle, radius*1.2, height);  
        cylinder(height,radius,radius);
    }
}

module rim(height,innerRadius,thickness){
    outerRadius = innerRadius+thickness;
    tolerance=2;
    difference(){
        cylinder(height,outerRadius,outerRadius);
        translate([0,0,-tolerance/2]) cylinder(height+tolerance,innerRadius,innerRadius);
    }
}

module coneRim(height,innerRadius,thickness){
    outerRadius = innerRadius+thickness;
    tolerance=2;
    difference(){
        cylinder(height,outerRadius,outerRadius);
        union(){
			cylinder(height,outerRadius,innerRadius);
			translate([0,0,-tolerance/2]) cylinder(height+tolerance,innerRadius,innerRadius); //this just helps to create a nice preview
		}
    }
}


/**
 * Standard right-angled triangle (tangent version)
 *
 * @param number angle of adjacent to hypotenuse (ie tangent)
 * @param number a_len Lenght of the adjacent side
 * @param number depth How wide/deep the triangle is in the 3rd dimension
 */
module a_triangle(tan_angle, a_len, depth)
{
    linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,tan(tan_angle) * a_len]], paths=[[0,1,2]]);
    }
}
