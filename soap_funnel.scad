// the total volume of the vessel being filled (in mL)
total_volume = 350;

// the exterior radius of the stem (in mm)
stem_exterior = 10;

// length of the stem (in mm)
stem_length = 300; 

// thickness of the walls (in mm)
wall = 2;

$fn = 10;

// calculated variables
pi = 3.14159;
angle = 60;
stem_volume = pi * pow(stem_exterior - wall, 2) * stem_length / 2;
mouth_volume = (total_volume * 1000) - stem_volume;

// find height and width of the funnel
// start with volume of a cone sections v = pi * h * (d^2 + db + b^2) / 12
// d we already know (stem_exterior - wall) * 2 (its a diameter!)
d = (stem_exterior - wall) * 2;

// b = 2 * ((d/2) + (h / tan(angle))) (it's a diameter too!)
// simplify to b = d + (2h/t) 
// simplifing our equation (using t for tan(angle)) and subbing in b, we get: v = (pi h) (1/12 (d^2+d (d+2×h/t)+(d+2×h/t)^2))
t = tan(angle);
v = mouth_volume;

// use Wolfram|Alpha to solve for h and we get:
// h = 1/2 ((pi d^3 t^3+24 t^2 v)^(1/3)/pi^(1/3)-d t)
mouth_height = 
	(1 / 2) * 
	(	
		(
			pow((pi * pow(d, 3) * pow(t, 3)) + (24 * pow(t, 2) * v), 1/3)
			/
			pow(pi, 1/3)
		)
		- 
		(d * t)	
	);			

// this is the internal mouth width (radius)
mouth_width = (d + ((2 * mouth_height) / t)) / 2;


union() {
	mouth();
	translate([0, 0, mouth_height]) stem();
}

module mouth() {
	difference() {
		cylinder(mouth_height, mouth_width + wall, stem_exterior);
		cylinder(mouth_height, mouth_width, stem_exterior - wall);
	}
}

module stem() {
	union() {
		// seperate the stem into two halfs to let air out
		translate([-stem_exterior, -(wall / 2), (((stem_exterior * 2) - (wall * 2)) * tan(angle) / 2)]) 
		cube([(stem_exterior * 2), wall, stem_length - (((stem_exterior * 2) - (wall * 2)) * tan(angle) / 2)]);
		
		// create a flap at the top of the stem so stuff doesn't go down the air tube
		rotate(a=90, v=[0, 0, 1]) 
		translate([0, 0, ((stem_exterior * 2) - (wall * 2)) * tan(angle) / 2]) 
		rotate(a=60, v=[0, 1, 0]) linear_extrude(height = wall) 
		ellipsePart(height=(stem_exterior * 2) - (wall * 2), width=((stem_exterior * 2) - (wall * 2)) / cos(angle), numQuarters=2);
		
		
		difference() {
			union() {
				// the outside of the stem
				cylinder(stem_length, stem_exterior, stem_exterior);

				// flange to keep airhole out in the open
			//	cylinder(
			//		(((stem_exterior * 2) - (wall * 2)) * tan(angle)) + (wall * 2), 
			//		stem_exterior, 
			//		(tan(angle) * (((stem_exterior * 2) - (wall * 2)) * tan(angle)) + (wall * 2)) - stem_exterior
			//	);
			}
			
			// inside of the stem
			cylinder(stem_length, stem_exterior - wall, stem_exterior - wall);

			// hole for air
			rotate(a=90, v=[1, 0, 0])
			translate([0, (((stem_exterior * 2) - (wall * 2)) * tan(angle) / 2), -((((stem_exterior * 2) - (wall * 2)) * tan(angle)) + (wall * 2))]) 
			cylinder(((((stem_exterior * 2) - (wall * 2)) * tan(angle)) + (wall * 2)), stem_exterior / 2,  stem_exterior / 2);
		}
	}
}


/*
 *  ellipsePart and ellipse are from:
 *  OpenSCAD 2D Shapes Library (www.openscad.org)
 *  Copyright (C) 2012 Peter Uithoven
 *
 *  License: LGPL 2.1 or later
 */

module ellipsePart(width,height,numQuarters)
{
    o = 1; //slight overlap to fix a bug
	difference()
	{
		ellipse(width,height);
		if(numQuarters <= 3)
			translate([0-width/2-o,0-height/2-o,0]) square([width/2+o,height/2+o]);
		if(numQuarters <= 2)
			translate([0-width/2-o,-o,0]) square([width/2+o,height/2+o*2]);
		if(numQuarters < 2)
			translate([-o,0,0]) square([width/2+o*2,height/2+o]);
	}
}

module ellipse(width, height) {
  scale([1, height/width, 1]) circle(r=width/2);
}