// @TODO: Add holes to pellet holder
// @TODO: Add screw holes to wall
// @TODO: Add screw holes to lid
// @TODO: Add power switch

$fn = 32;

fanWidth=180;
fanHeight=40;
fanOffset=0.25; // Extra space around the fan, so it fits nicely

screwLength=20;
screwLegWidth=3;
screwHeadWidth=6;
screwHeadHeight=4;
screwNutWidth=5;
screwNutHeight=3;

boxLipHeight=12;
boxLipWidth=8;
boxWallHeight=160;
boxWallWidth=12;
boxWallHoleWidth=16;
boxWallPillarWidth=boxWallWidth;
boxWallPillarHeight=32;
boxWallPillarZ=(
    boxWallHeight -
    boxWallPillarHeight -
    fanHeight +
    boxLipHeight
);
boxWallOuterHeight=boxWallHeight+boxLipWidth;

boxInnerWidth=fanWidth + fanOffset;
boxOuterWidth=fanWidth + 2*boxWallWidth;

boxLipInnerWidth=boxInnerWidth;
boxLipOuterWidth=fanWidth+boxLipWidth;

baseHeight=boxWallWidth;
baseWidth=boxOuterWidth;
baseLipHeight=24;
baseLipInnerWidth=boxInnerWidth-boxLipWidth;
baseLipOuterWidth=boxInnerWidth-fanOffset;
baseOuterHeight=baseHeight + boxLipHeight;

plugWidth=32;
plugHeight=16;
plugHole=true;
offsetPreviewParts=true;
renderScrews=true;
renderBoxLid=true;
renderWalls=true;
renderBase=true;
renderDustFilterHolder=true;
// The pellet holder perforations are compute heavy to render, so it is disabled by default
renderPelletHolder=false;
renderPelletHolderLid=true;

dustFilterWidth=35;
dustFilterWallWidth=4;
dustFilterLipWidth=2;
dustFilterHeight=boxWallHeight-fanHeight+boxLipHeight-dustFilterLipWidth;
dustFilterHolderOuterWidth=boxInnerWidth-dustFilterWidth-fanOffset;
dustFilterHolderInnerWidth=dustFilterHolderOuterWidth-dustFilterWallWidth-fanOffset;
dustFilterLipOuterWidth=boxInnerWidth-fanOffset;

baseDustFilterLipOuterWidth=dustFilterHolderOuterWidth+fanOffset+boxLipWidth;
baseDustFilterLipInnerWidth=dustFilterHolderOuterWidth+fanOffset;

pelletHolderHeight=5*dustFilterHeight/8;
pelletHolderWallWidth=2;
pelletHolderLipWidth=2;
pelletHolderOuterWidth=dustFilterHolderInnerWidth-fanOffset;
pelletHolderInnerWidth=pelletHolderOuterWidth-pelletHolderWallWidth;
pelletHolderLipOuterWidth=pelletHolderOuterWidth-fanOffset+boxLipWidth;
pelletHolderLipInnerWidth=pelletHolderInnerWidth;
pelletHolderConeBottomDiameter=120;
pelletHolderConeTopDiameter=40;
pelletHolderInnerPeakOffset=16;
pelletHolderConeHeight=pelletHolderHeight-pelletHolderInnerPeakOffset;

boxLidOuterHeight=3*boxLipHeight/4;
boxLidHoleSpacing=2;

function centerPos(pos) = -pos/2;

module roundedSquare(size, sqDepth=0) {
    borderRadius=max(0.02*size, 2);
    depth=sqDepth == 0 ? size : sqDepth;
    translate([centerPos(size), centerPos(depth)])
    translate([borderRadius, borderRadius, 0])
    minkowski() {
        bsx=2*borderRadius;
        square([size - bsx, depth - bsx]);
        circle(borderRadius);
    }
}

module hollowRect(outerWidth, innerWidth) {
    difference() {
        roundedSquare(outerWidth);
        roundedSquare(innerWidth);
    }
}

module wallHoles(
    width,
    height,
    spacing,
    segmentSize
) {
    segmentsX=(width-2*spacing)/segmentSize;
    segmentsY=(height-2*spacing)/segmentSize;
    move=segmentSize+spacing/2;
    base=spacing;
    for(segX=[(segmentsX-2)/-2:segmentsX/2]){
        for(segY=[0:segmentsY-1]) {
            translate([
                0,
                base+segX*move,
                base+segY*move
            ])
            translate([0,-segmentSize/2,segmentSize/2])
            rotate([0,90,0])
            cylinder(
                2*boxOuterWidth,
                d=segmentSize,
                center=true
            );
        }
    }
}



module screwHole(size, height) {
    if (renderScrews) {
        cylinder(h=height, d=size);
    }
}

module screwPosition() {
    
}

module screwHead() {
    translate([0,0,-screwHeadHeight])
    screwHole(screwHeadWidth, screwHeadHeight*2);
    screwHole(screwLegWidth, screwHeadHeight+screwLength*1.25);
    translate([0,0,screwLength-screwNutHeight])
    screwHole(screwNutWidth, screwNutHeight);
}


module boxBaseScrews() {
    off=baseWidth/2 - boxWallWidth/2;
    translate([off, off])
    screwHead();
    translate([off, -off])
    screwHead();
    translate([-off, off])
    screwHead();
    translate([-off, -off])
    screwHead();
}


module boxBaseWallLip() {
    translate([0,0,baseHeight])
    linear_extrude(baseLipHeight)
    difference(){
        hollowRect(baseLipOuterWidth, baseLipInnerWidth);
        translate([baseLipInnerWidth/2,0])
        square(plugHeight*2, true);
    }
}

module boxBaseDustFilterLip() {
    translate([0,0,baseHeight])
    linear_extrude(baseLipHeight/4)
    difference() {
        hollowRect(
            baseDustFilterLipOuterWidth,
            baseDustFilterLipInnerWidth
        );
        translate([baseLipInnerWidth/2,0])
        square(plugHeight*2, true);
    }
    
}

module boxBase() {
    difference() {
        linear_extrude(baseHeight)
        roundedSquare(baseWidth);
        boxBaseScrews();
    }
    boxBaseWallLip();
    boxBaseDustFilterLip();    
}

module boxWallFenceHoles() {
    translate([0,0,baseHeight+plugHeight])
    wallHoles(
        boxInnerWidth,
        dustFilterHeight-(baseHeight+plugHeight),
        boxLipWidth/2,
        boxWallHoleWidth
    );
}

module boxWallFence() {
     difference() {
        translate([0,0, baseHeight])
        linear_extrude(boxWallHeight)
        hollowRect(boxOuterWidth, boxInnerWidth);

        if (plugHole) {
            translate([boxOuterWidth/2,0,plugHeight+baseHeight])
            cube([boxWallWidth*6, plugWidth, plugHeight], true);
        }
        
        translate([0,boxLipWidth/4, baseHeight])
        boxWallFenceHoles();
        translate([-boxLipWidth/4,0, baseHeight])
        rotate([0,0,90])
        boxWallFenceHoles();
        
        boxBaseScrews();
    }
}

module boxWallLip() {
    translate([0,0,boxWallHeight+baseHeight])
    linear_extrude(boxLipHeight)
    hollowRect(boxLipOuterWidth, boxLipInnerWidth);
}

module boxWalls() {
    difference() {
        union() {
            boxWallFence();
            boxWallLip();
        }
        boxLidScrews();
    }
}


module boxLidScrews() {
    translate([0,0,boxWallHeight+baseHeight+boxLipHeight*3/2-1])
    rotate([0,180,0])
    boxBaseScrews();
}
module boxLid() {
    difference() {
        translate([0,0,baseHeight+boxWallHeight])
        union() {
            difference() {
                translate([0,0,boxLipHeight])
                linear_extrude(boxLipHeight/2)
                roundedSquare(baseWidth);

                translate([-boxLipInnerWidth/2,0])
                rotate([0,90,0])
                wallHoles(
                    boxLipInnerWidth,
                    boxLipInnerWidth,
                    boxLidHoleSpacing,
                    24
                );
            }
            linear_extrude(boxLipHeight)
            hollowRect(baseWidth, boxLipOuterWidth+fanOffset);
        }
        boxLidScrews();
    }
}
    
module dustFilterHolderHoles() {
    translate([0,0,baseHeight])
    wallHoles(
        dustFilterHolderOuterWidth,
        dustFilterHeight,
        dustFilterWallWidth,
        32
    );
}
module dustFilterHolderWallLip() {
    translate([0,0,dustFilterHeight+baseHeight])
    linear_extrude(dustFilterLipWidth)
    hollowRect(
        dustFilterLipOuterWidth,
        dustFilterHolderInnerWidth
    );
}

module dustFilterHolderWall() {
    translate([0,0,baseHeight])
    linear_extrude(dustFilterHeight)
    hollowRect(
        dustFilterHolderOuterWidth,
        dustFilterHolderInnerWidth
    );
}

module dustFilterHolder() {
    dustFilterHolderWallLip();
    difference() {
        dustFilterHolderWall();
        dustFilterHolderHoles();
        rotate([0,0,90])
        dustFilterHolderHoles();
    }
}




pi = 3.1415;
pelletHolderHoleDiameter = 2;
pelletHolderHoleDistance = 1.5; // Minimum distance between hole centers
pelletHolderHoleHeight = pelletHolderWallWidth * 4;

function getConeDiameter(z) = (pelletHolderConeBottomDiameter / 2) + z * ((pelletHolderConeTopDiameter - pelletHolderConeBottomDiameter) / (2 * pelletHolderConeHeight)) - pelletHolderHoleDiameter * 0.75;

function getHoleStep(diameter) = pi * diameter / (pelletHolderHoleDiameter * 2);

function getHoleCount(diameter) = floor(360/floor(getHoleStep(diameter)));

module pelletHolderConePerforation() {
    minHoleDistance = pelletHolderHoleDistance; // Minimum distance between hole centers
    maxHoleDiameter = pelletHolderHoleDiameter;

    coneSlope = atan((pelletHolderConeTopDiameter - pelletHolderConeBottomDiameter) / pelletHolderConeHeight);
    bottomLimit = pelletHolderWallWidth + maxHoleDiameter;
    topLimit = pelletHolderConeHeight - pelletHolderWallWidth - maxHoleDiameter;
    step = maxHoleDiameter+1;

    for (z = [bottomLimit : step : topLimit]) {
        // Calculate the radius at this height level
        radius = (pelletHolderConeBottomDiameter / 2) + z * ((pelletHolderConeTopDiameter - pelletHolderConeBottomDiameter) / (2 * pelletHolderConeHeight))-pelletHolderHoleHeight/2;

        // Determine the circumference at this height
        circumference = 2 * pi * radius;

        // Dynamically set the hole size based on available space
        holeDiameter = min(maxHoleDiameter, circumference / (circumference / (minHoleDistance + maxHoleDiameter)));
        holeHeight = pelletHolderHoleHeight;

        // Determine the number of holes that fit within the circumference while maintaining minimum spacing
        numHoles = max(3, floor(circumference / (holeDiameter + minHoleDistance)));

        for (i = [0 : 360 / numHoles : 360]) {
            // Calculate position for each hole
            x = radius * cos(i);
            y = radius * sin(i);

            translate([x, y, z])
            // Rotate the hole cylinder to align it perpendicular to the cone surface
            rotate([90, coneSlope * 180 / pi, i + 90])
            cylinder(h = pelletHolderHoleHeight, d = holeDiameter);
        }
    }

}


module pelletHolderConeWalls() {
    difference() {
        cylinder(
            h=pelletHolderConeHeight,
            d1=pelletHolderConeBottomDiameter,
            d2=pelletHolderConeTopDiameter
        );
        
        translate([0,0,(2*-pelletHolderWallWidth)-1])
        cylinder(
            h=pelletHolderConeHeight+1,
            d1=pelletHolderConeBottomDiameter,
            d2=pelletHolderConeTopDiameter
        );
    }
}

module pelletHolderCone() {
    difference() {
        pelletHolderConeWalls();
        pelletHolderConePerforation();
    }
}

module pelletHolderBase() {
    linear_extrude(pelletHolderWallWidth)
    difference() {
        circle(d=pelletHolderOuterWidth);
        circle(d=pelletHolderConeBottomDiameter-2*pelletHolderWallWidth);
    }
}

module pelletHolderLip() {
    translate([0,0,pelletHolderHeight+pelletHolderLipWidth])
    linear_extrude(pelletHolderLipWidth)
    difference() {
        roundedSquare(boxInnerWidth);
        circle(d=pelletHolderInnerWidth);
    }
}


module pelletHolderCylinderPerforation() {
    radius=pelletHolderInnerWidth/2;
    wallThickness=pelletHolderWallWidth;
    minHoleDistance = pelletHolderHoleDistance;
    maxHoleDiameter = pelletHolderHoleDiameter;
    holeHeightFactor = 2; // Adjusts the height of each hole based on its diameter

    // Define the bottom and top limits to avoid perforating too close to the edges
    bottomLimit = wallThickness + maxHoleDiameter;
    topLimit = pelletHolderHeight - wallThickness - maxHoleDiameter;
    step=maxHoleDiameter+minHoleDistance;

    for (z = [bottomLimit : step : topLimit]) {
        // Circumference of the cylinder at the given radius
        circumference = 2 * pi * radius;

        // Dynamically set the hole size based on available space
        holeDiameter = min(maxHoleDiameter, circumference / (circumference / (minHoleDistance + maxHoleDiameter)));
        holeHeight = holeDiameter * holeHeightFactor;

        // Determine the number of holes that fit within the circumference while maintaining minimum spacing
        numHoles = max(3, floor(circumference / (holeDiameter + minHoleDistance)));
        radiusBase = radius - holeHeight/2;

        for (i = [0 : 360 / numHoles : 360]) {
            // Compute the position for each hole
            x = radiusBase * cos(i);
            y = radiusBase * sin(i);

            translate([x, y, z])
            // Rotate the hole cylinder to align it perpendicular to the cylinder surface
            rotate([0, 90, i])
            cylinder(h = holeHeight, d = holeDiameter);
        }
    }
}
module pelletHolderCylinder() {
    translate([0,0,pelletHolderWallWidth])
    difference() {
        linear_extrude(pelletHolderHeight)
        difference() {
            circle(d=pelletHolderOuterWidth);
            circle(d=pelletHolderInnerWidth);
        }
        pelletHolderCylinderPerforation();
    }
}

module pelletHolderBody() {
    pelletHolderCone();
    pelletHolderBase();
    pelletHolderCylinder();
}

module pelletHolder() {
    translate([0,0,baseHeight+dustFilterHeight-pelletHolderHeight])
    union() {
        pelletHolderBody();
        pelletHolderLip(); 
    }
}

module pelletHolderLid() {}

module all() {
    if (renderBase) {
        color("#673F69")
        boxBase();
    }

    off1=offsetPreviewParts?4*baseOuterHeight:0;
 
    if (renderWalls) {
        color("#FFAF45")
        translate([0,0,off1])
        boxWalls();
    }
    
    off2=off1+(offsetPreviewParts?3*boxWallOuterHeight/2:0);
    
    if (renderDustFilterHolder) {
        color("#FB6D48")
        translate([0,0,off2])
        dustFilterHolder();
    }

    off3=off2+(offsetPreviewParts?2*dustFilterHeight/2:0);

    if (renderPelletHolder) {
        color("#333333")
        translate([0,0,off3])
        pelletHolder();
    }

    if (renderPelletHolderLid) {
        pelletHolderLid();
    }

    if (renderBoxLid) {
        off5 = off3 + (offsetPreviewParts?3*boxLidOuterHeight:0);
        color("#BF3131")
        translate([0,0,off5])
        boxLid();
    }
}

all();