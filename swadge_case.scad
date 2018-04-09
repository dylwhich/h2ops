echo(version=version());

$fs = .5;
$fa = 5;

//%import("projection.stl");

// projection() without the cut = true parameter will project
// the outline of the object onto the X/Y plane. The result is
// a 2D shape.

swadge_x = 60;
swadge_y = 50.5;

// Bottom layer height
floor_ht = 2;

// Battery pack height
battery_ht = 15;

// Thickness of PCB
pcb_ht = 1.5;

// Button diameter
button_d = 4;

// Button height
button_ht = 1;

// Diameter of the bottom part of the plunger
plunger_d = button_d - .5;

// Diameter of the top (pressable) part of the plunger
plunger_top_d = 2;

// Height of the plunger above the case
plunger_ht = 3;

// Extra space to give plunger
plunger_pad = .3;

// Outer wall thickness
wall_w = 2;

// Space above PCB before lid
cavity_ht = 2;

// Wall height
wall_ht = battery_ht + pcb_ht + cavity_ht;

// Depth of inset in lid
top_inset_ht = 1.25;

// Thickness of very top
top_ht = 1;

// Offset from board origin of ESP can
esp_off = [64, 23, 0];
esp_sz = [15, 12];

// LED positioning parameters
led_space = 16;
led_off_x = 1.5;
led_off_y = 42;
led_sz = [5, 5];

button_names = ["Up", "Left", "Right", "Down", "Select", "Start", "B", "A"];
button_xs = [13.0, 05.0, 22.0, 14.0, 39.0, 50.0, 71.0, 82.0];
button_ys = [20.0, 12.0, 12.0, 04.0, 05.0, 05.0, 11.0, 16.0];

screw_xs = [wall_w, wall_w+55, wall_w, wall_w+55];
screw_ys = [swadge_y + wall_w*2, swadge_y + wall_w*2, -wall_w, -wall_w];
screw_yo = [0, 0, -2, -2];
screw_hole_d = 1.5;
screw_len = 3;

swadge = true;
case = true;
top = false;
plunger = false;

function border_scale() = [(100 + 2*wall_w)/100, (swadge_y + 2*wall_w)/swadge_y, 1.0];

module swadge_shape(hole) {    
    square([swadge_x, swadge_y]);
    
    // This is more "accurate" [maybe?]
    /*translate([swadge_x, 0, 0]) {
        intersection() {
            translate([-8, 52, 0]) circle(55);
            square([50, 50]);
            translate([-8, -2, 0]) circle(55);
        }
    }*/

    translate([swadge_x, 0, 0]) {
        intersection() {
            circle(swadge_y);
            square([swadge_y, swadge_y]);
            
            translate([0, swadge_y, 0])
            circle(swadge_y);
        }
    }
}

module leds(circular=false) {
    // LEDs
    for (i = [0:3]) {
        translate([led_off_x + i * led_space, led_off_y, 0])
        if (circular) {
            translate([led_sz[0]/2, led_sz[0]/2])
            circle(d=led_sz[0], center=true);
        } else {
            square(led_sz);
        }
    }
}

if (swadge)
translate([wall_w, wall_w, floor_ht]) {
    // Battery Pack
    color("black", .7)
    translate([4, 7.5, 0]) {
        linear_extrude(battery_ht)
            square([57.5, 33.5]);
    }

    // Swadge Body
    translate([0, 0, battery_ht]) {
        color("red", .7)
        linear_extrude(pcb_ht)
        difference() {
            swadge_shape();

            translate([94.5, swadge_y/2, 0])
            circle(d=5);
        }

        // Components
        translate([0, 0, pcb_ht]) {
            // Buttons
            for (i = [0:7]) {
                translate([button_xs[i], button_ys[i], 0]) {
                    color("gold")
                    linear_extrude(button_ht)
                    circle(d=button_d, center=true);
                    
                    translate([0, -button_d, 0])
                    color("white")
                    text(button_names[i], .8);
                }
            }
            
            linear_extrude(1.5)
            leds();
            
            // ESP8266
            translate(esp_off)
            color("silver")
            linear_extrude(3)
            square(esp_sz);
        }
    }
}

module screw_things(hole=false) {
    for (i = [0:3]) {
        translate([screw_xs[i], screw_ys[i], 0]) {
            difference() {
                union() {
                    square([4, 2], center=false);

                    translate([2, 2+screw_yo[i], 0])
                    circle(2);
                }

                if (hole) {
                    translate([2, 2+screw_yo[i]])
                    circle(d=screw_hole_d);
                }
            }
        }
    }
}

module case_base() {
    // Exterior Stuff
    difference() {
        linear_extrude(floor_ht)
        scale(border_scale())
        swadge_shape();
        
        // Punch nicely chamfered holes for some zipties
        square_sz = 3;
        square_xs = [15, 15, 65, 65];
        square_ys = [12, swadge_y-12, 12, swadge_y-12];

        for (i = [0:3]) {
            translate([square_xs[i]+square_sz/2, square_ys[i]+square_sz/2, -.1])
            linear_extrude(floor_ht+.2, scale=1.8)
            square(square_sz, center=true);
        }
    }

    // Screw things at floor without holes
    linear_extrude(floor_ht)
    screw_things(false);

    // Walls
    translate([0, 0, floor_ht]) {
        linear_extrude(wall_ht) {
            difference() {
                scale(border_scale())
                swadge_shape();

                translate([wall_w, wall_w, 0])
                swadge_shape(false);
            }
        }

        // Screw things along wall without holes
        linear_extrude(wall_ht - screw_len)
        screw_things(false);

        // Screw things along wall top with holes
        translate([0, 0, wall_ht - screw_len])
        linear_extrude(screw_len)
        screw_things(true);
    }

    // Interior Stuff
    translate([wall_w, wall_w, floor_ht]) {
        // Post for lanyard hole
        translate([94.5, swadge_y/2, 0]) {
            // Support pillar
            linear_extrude(height=battery_ht)
            circle(d=8);

            // Alignment pin
            linear_extrude(height=wall_ht - top_inset_ht)
            circle(d=5);
        }
    }
}

module plunger() {
    linear_extrude(cavity_ht-button_ht)
    circle(d=plunger_d);

    translate([0, 0, cavity_ht-button_ht])
    linear_extrude(top_inset_ht + top_ht + plunger_ht)
    circle(d=plunger_top_d);
}

module case_top() {
    // Top stuff
    translate([0, 0, floor_ht + battery_ht + pcb_ht + cavity_ht - top_inset_ht]) {
        difference() {
            union() {
                translate([wall_w, wall_w, 0])
                linear_extrude(top_inset_ht)
                swadge_shape();

                translate([0, 0, top_inset_ht])
                linear_extrude(top_ht)
                scale(border_scale())
                swadge_shape();

                translate([0, 0, top_inset_ht])
                linear_extrude(top_ht)
                screw_things(true);
            }

            translate([wall_w, wall_w, -.1])
            scale([1, 1, 1]) {
                // Punch holes for each button
                // but skip the start button
                for (i = [0, 1, 2, 3, 4, 6, 7]) {
                    translate([button_xs[i], button_ys[i], 0]) {
                        linear_extrude(.1 + top_inset_ht)
                        circle(d=plunger_d + plunger_pad);

                        translate([0, 0, .1 + top_inset_ht])
                        linear_extrude(top_ht + .1)
                        circle(d=plunger_top_d + plunger_pad);
                    }
                }

                // Punch holes for the LEDs
                linear_extrude(top_inset_ht + top_ht + .2)
                leds(true);

                // Punch a hole for the ESP
                translate(esp_off - [.2, .2, 0])
                linear_extrude(top_inset_ht + top_ht + .2)
                square(esp_sz + [.4, .4, 0]);
            }
        }
    }
}

if (mode == "bottom") {
    case_base();
} else if (mode == "top") {
    case_top();
} else if (mode == "plunger") {
    plunger();
} else {
    if (case) {
        color("blue", .6)
        case_base();
    }

    if (plunger) {
        color("red")
        plunger();
    }

    if (top) {
        color("orange")
        case_top();
    }
}