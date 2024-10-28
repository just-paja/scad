include <Round-Anything/polyround.scad>;
include <Round-Anything/unionRoundMask.scad>;

$fn=50;

// Render this part to generate STL
target = 1; // [1:Frame,2:Window,3:Test Frame]

slice=true;

// Will render on the cut index, so you do not have to slice STLs
cutIndex=0;

// Max part size you can part on the printer (not counting the connector unfortunately)
maxPartWidth=155;


/* [Frame] */
// Width of the longer wall in mm
wallWidth=770;
// Width of the wall touching the bath in mm
bathWidth=675;
// Far gap size (the smaller one) in mm
farGap=213;
// Near gap size (the larger one) in mm
nearGap=229;
// Frame height in mm
height=27.5;
// How much height of the frame should be cut off the bottom to save material
reducerHeight=0.4;

connectorWidth=height*2;

bathConnectorWidth=15;

/* [Windows] */
// Fit this many windows inside the frame
windowCount = 8;
// Window frame width base in mm
frameWidth = 40;

windowWidth = (bathWidth - (windowCount + 1) * frameWidth) / windowCount;
windowLength = (farGap - 2 * frameWidth);
winShift=-frameWidth - windowLength;

glassBorderRadius=10;

ofs=3*frameWidth / 7;
ifs=frameWidth / 6;

module base() {
    linear_extrude(height) polygon([
        [0, 0],
        [bathWidth, 0],
        [wallWidth, -nearGap],
        [0, -farGap],
    ]);
}

module window() {
    union() {
        translate([0, 0, -height/10])
        linear_extrude(height)
        polygon([
            [-ifs, -ifs],
            [windowWidth + ifs, -ifs],
            [windowWidth + ifs, windowLength + ifs],
            [-ifs, windowLength + ifs],
        ]);
        translate([0,0,height - height/4]) glass(true);
    }
}


module glass(doubleHeight) {
    linear_extrude(doubleHeight ? height/2 : height/4)
    polygon(polyRound([
        [-ofs, -ofs, glassBorderRadius],
        [windowWidth + ofs, -ofs, glassBorderRadius],
        [windowWidth + ofs, windowLength + ofs, glassBorderRadius],
        [-ofs, windowLength + ofs, glassBorderRadius],
    ], $fn));
}

module windows() {
    union() {
        for (i = [0:windowCount - 1]) {
            translate([
                (i + 1) * frameWidth + i * windowWidth,
                winShift,
                0
            ])
            window();
        }
    }
}

module baseReducer() {
    ofs = frameWidth/2;
    linear_extrude(
        height * (reducerHeight + 0.1)
    ) 
    translate([0,0, height*0.1])
    polygon([
        [ofs, -ofs],
        [bathWidth - ofs, -ofs],
        [wallWidth - 2* ofs, -nearGap + ofs],
        [ofs, -farGap + ofs],
    ]);
}

module bathConnector() {
    rotate([0,0,-90])
    difference() {
        translate([-bathConnectorWidth, 0])
        cube([bathConnectorWidth, bathWidth, height]);

        translate([
            -bathConnectorWidth/2,
            -bathWidth/2,
            height - bathConnectorWidth / 2
        ])
        rotate([-90, 0])
        cylinder(h=bathWidth*2, d=bathConnectorWidth, $fn=$fn);
        
        translate([
            -1.5 * bathConnectorWidth,
            -bathWidth/2,
            -height/2
        ])
        cube([bathConnectorWidth, bathWidth*2, height*2]);

        translate([
            -bathConnectorWidth,
            -bathWidth/2,
            -height - bathConnectorWidth/2
        ])
        cube([bathConnectorWidth, 2*bathWidth, 2*height]);
    }
}

module frameEnder() {
    hull()
    polyhedron(
        [
            [bathWidth, 0, 0],
            [bathWidth, 0, height],
            [bathWidth, bathConnectorWidth/2, 0],
            [bathWidth, bathConnectorWidth/2, height],
            [wallWidth, -nearGap, height],
            [wallWidth, -nearGap, 0],
        ],
        [
            [0,2,3,1],
            [2,3,4,5],
            [4,5,0,1],
            [0,2,5],
            [1,3,4],
        ]
    );
}

module ohShitItDoesNotFit() {
    ofs=2;
    off=3;
    color([1,0,0,1])
    hull()
    linear_extrude(height) 
    translate([0,0,-height/2])
    polygon([
        [4*wallWidth/5, -nearGap],
        [wallWidth, -nearGap],
        [wallWidth, -nearGap - ofs],
        [4*wallWidth/5, -nearGap],
    ]);
}

module frame() {
    rotate([0, 0, 90])
    ohShitItDoesNotFit();
 
    rotate([0, 0, 90])
    color([0.5,1,0,0.2])
    union() {
        bathConnector();
        difference() {
            base();
            windows();
            baseReducer();
        }
        frameEnder();
    }
}

/* Cutter is a part that is supposed to be iteratively applied on the model, to split the object into connectable parts that fit the printer heatbed.
*/
module cutter(cutObjectBack=true) {
    inf=3000;
    boxOfs=inf - maxPartWidth;
    connectorBottom = height * reducerHeight - 200;
    connectorLength=connectorWidth/2;
    
    // upper forward part
    translate([
        -50,
        maxPartWidth,
        height * reducerHeight
    ])
    cube([300, inf, 200]);
    
    // lower forward part
    translate([
        -50,
        maxPartWidth + connectorLength,
        connectorBottom
    ])
    cube([300, inf, 200]);
    
    if (cutObjectBack) {
        // upper back part
        translate([
            -50,
            - inf,
            height * reducerHeight
        ])
        cube([300, inf, 200]);
        
        // lowerback part
        translate([
            -50,
            - inf + connectorLength,
            connectorBottom
        ])
        cube([300, inf, 200]);
    }
}


if (target == 1) {
    cutterCount=floor(wallWidth/maxPartWidth);
    for (i = [0:cutterCount]) {
        if (i == cutIndex || !slice) {
            translate([slice ? i * (nearGap + frameWidth):0,0,0])
            difference() {
                frame();
                
                translate([0, i * maxPartWidth, 0])
                cutter(i != 0);
            }
        }
    }
    
}

if (target == 2) {
    rotate([0, 0, 90]) 
    color([0,1,0,0.25])
    glass();
}

if (target == 3) {
    rotate([0, 0, 90]) difference() {
        base();
        windows();
        translate([180, -280, -20]) cube([700, 300, 200]);
    }   
}