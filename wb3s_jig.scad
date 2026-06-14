// WB3S programming jig  (cap-over-the-top design)
// The WB3S is already SMD-soldered (shield-up) onto a host PCB. The jig is a
// cap with a pocket on its UNDERSIDE that is lowered down over the soldered
// module IN-CIRCUIT. The male-pin ends of female-to-male Dupont jumper wires
// are pushed into angled channels from above/outside the jig and contact the
// castellated edge pads for VCC, GND, TXD1, RXD1, CEN. The female ends plug
// normally into the UART adapter's pin header, so nothing gets worn out.
//
// Because the WB3S is soldered down, it can't be gripped directly: the clamp
// instead presses the JIG down onto the HOST PCB (see clamp() below), with the
// WB3S sandwiched, so the Dupont pins stay seated on its edge pads.
//
// Why shield-up / cap-from-top: keeping the module the same way up as a normal
// top/component-side view means the pad layout matches the libretiny reference
// SVG (= datasheet Fig 2-1 *front* view) directly. If the module were flipped
// silk-up instead, the operator would see the datasheet *rear/"BOT"* view,
// which is the left-right MIRROR, and VCC<->GND / CEN<->TXD,RXD would swap.
//
// Coordinate system (Z=0 is the host-PCB top = the WB3S's soldered underside):
//   X: 0..pcb_w   (16mm short edges, at Y=0 and Y=pcb_l)
//   Y: 0..pcb_l   (24mm long edges, at X=0 and X=pcb_w)
//   Z: 0..up      (WB3S substrate 0..pcb_t, shield can pcb_t..pcb_t+shield_h;
//                  host PCB is below, -host_pcb_t..0)
//
// All five contact pads are on the two LONG (X=0 / X=pcb_w) edges:
//   X=0  edge: CEN (top) and VCC (bottom corner, pin 8)
//   X=pcb_w edge: TXD1/RXD1 (top) and GND (bottom corner, pin 9)
// The Y=0 short edge carries only the flash/test pads (SCK/CS/SI/SO), which we
// do NOT contact (the smaller Tuya boards don't even connect them). The
// Y=pcb_l short edge (antenna side) has no pads - that's the back, where the
// clamp's spine runs down and its tongue reaches under the host PCB.
//
// NOTE: pad positions (*_y below) are derived from the WB3S datasheet pinout
// (Table 2-1) + recommended PCB footprint (Fig 6-3): 8 pads per long edge at
// 2mm pitch, with VCC/GND as the bottom corner pads 1.48mm from the Y=0 corner
// and CEN/TXD1/RXD1 counted up from there. Verify against your actual module
// with calipers before printing.
//
// References (datasheet & pinout are NOT bundled here for licensing reasons -
// see README.md; the dimensions above are transcribed from these):
//   WB3S datasheet (c) Tuya:       https://fcc.report/FCC-ID/2ANDL-WB3S/4580793.pdf
//   LibreTiny WB3S board / pinout: https://docs.libretiny.eu/boards/wb3s/

// spellchecker:ignore castellation datasheet deboss debossed halign libretiny
// spellchecker:ignore pinout tuya uart viewports

// ===================== Module geometry =====================
pcb_l   = 24;     // module length (Y)
pcb_w   = 16;     // module width (X)
pcb_t   = 0.8;    // PCB substrate thickness (Z) - castellation pad height
shield_h = 2.0;   // shield can height above PCB top
fit_clear = 0.3;  // clearance around module in pocket
host_pcb_t = 1.6; // thickness of the host PCB the WB3S is soldered to

// Shield-can footprint (datasheet Fig 6-1/6-2). The roof pocket drops over the
// can and the surrounding RIMS hug its sides to locate the jig in X/Y; the roof
// bears on the can top for Z. VERIFY with calipers - read off low-res figures.
shield_l  = 15.1;  // can length (Y), from the side view
shield_w  = 14.6;  // can width (X), estimated (inset ~0.7mm per side)
shield_y0 = 1.5;   // can front edge, measured from the Y=0 (pad) end
shield_clear = 0.25; // slip clearance around the can

// Pad center Y-positions, in the SVG / top-view orientation. CEN + VCC on the
// X=0 (left) edge; TXD1/RXD1 + GND on the X=pcb_w (right) edge.
txd1_y = 15.48;  // right edge (X=pcb_w), pin 16
rxd1_y = 13.48;  // right edge (X=pcb_w), pin 15
gnd_y  = 1.48;   // right edge (X=pcb_w), pin 9  (bottom corner)
cen_y  = 15.48;  // left edge (X=0), pin 1
vcc_y  = 1.48;   // left edge (X=0), pin 8  (bottom corner)

// ===================== Jig geometry =====================
wall_t      = 2.0;  // pocket wall thickness (uniform on all four sides)
roof_t      = 1.5;  // thickness of the cap roof above the shield can

pin_angle  = 55;   // channel angle from horizontal (deg)
fan_angle  = 15;   // TXD1/RXD1 channels splay apart by +-this about Z (their
                   // pads are only 2mm apart - too tight for adjacent Dupont
                   // shells), so the outer ends fan out while tips stay on pad
channel_w  = 0.9;  // channel cross-section, sized for a bare ~0.6-0.7mm
channel_h  = 0.9;  // dupont male pin (from a female-to-male jumper wire),
                   // plus print clearance
channel_len = 12;  // length of angled channel (long enough to break out the
                   // top/outside face of the wall)

// Debossed pin labels on the roof top
label_font  = "Liberation Sans:style=Bold";
label_depth = 0.6;  // deboss depth
label_size  = 2.6;  // text height (~0.45mm stems; largest that fits the top face)

eps = 0.2; // overlap used when cutting, avoids coplanar/zero-thickness faces

outer_w = pcb_w + 2*wall_t;
outer_l = pcb_l + 2*wall_t;

pad_z      = pcb_t/2;            // pad center height above the bench
cavity_top = pcb_t + shield_h;   // roof underside rests on the shield can
z_top      = cavity_top + roof_t;// top face of the cap

// An angled channel: the "tip" sits at the pad on the cavity wall face; the
// channel travels OUTWARD and UPWARD through the wall and breaks out of the
// top/outer face of the jig (Dupont pin pushed in from above-outside).
//   tip:     [x,y,z] position of the pad-side end of the channel
//   theta_y: rotation about Y (used for left/right walls)
//   theta_z: extra rotation about Z (used to swing into the Y-Z plane
//            for the front wall)
module angled_channel(tip, theta_y, theta_z = 0) {
    translate(tip)
        rotate([0, 0, theta_z])
        rotate([0, theta_y, 0])
        translate([-eps, -channel_w/2, -channel_h/2])
        cube([channel_len + eps, channel_w, channel_h]);
}

// Pad viewport: a slot cut straight down through the roof, sitting just INBOARD
// of a pocket wall and directly over the module's castellated edge, so you look
// down onto the pad (and the seated Dupont pin tip). It cuts only the roof and
// opens into the cavity below - the registration walls stay solid, so the
// pocket still grips the module squarely.
//   side: "left"/"right"; p0,p1 are the Y bounds of the window
view_w = 2.0; // how far inboard from the edge the window reaches
module pad_window(side, p0, p1) {
    z0 = -eps;             // full-depth cut: also slices the registration rim
    h  = z_top - z0 + eps; // here so the edge pad stays visible (rim survives
                           // as segments between the pad windows)
    if (side == "right") {
        x1 = wall_t + pcb_w + fit_clear;      // inner face of the right wall
        translate([x1 - view_w, wall_t + p0, z0]) cube([view_w, p1 - p0, h]);
    } else { // "left"
        translate([wall_t, wall_t + p0, z0]) cube([view_w, p1 - p0, h]);
    }
}

// Debossed pin label on the roof top, beside a viewport. halign "left" starts
// the text at x (label sits to the +X side); "right" ends it at x (-X side).
module pin_label(txt, x, y, size, halign) {
    translate([x, y, z_top - label_depth])
        linear_extrude(label_depth + eps)
            text(txt, size = size, font = label_font,
                 halign = halign, valign = "center");
}

// 2D serpentine antenna trace, in the physical-module orientation (the two
// long parallel meander segments at high X = the right side, matching the chip
// viewed top-down). Engraved into the TOP of the roof as an orientation key.
module antenna_pattern_2d(region_w, region_h) {
    union() {
        translate([14.440, 0.681]) square([0.503, 5.232]);
        translate([10.314, 5.410]) square([4.629, 0.503]);
        translate([12.226, 0.681]) square([0.503, 5.232]);
        translate([10.314, 2.894]) square([0.503, 3.019]);
        translate([7.798,  2.894]) square([3.019, 0.503]);
        translate([7.799,  2.894]) square([0.503, 3.019]);
        translate([5.585,  5.410]) square([2.717, 0.503]);
        translate([5.585,  2.894]) square([0.503, 3.019]);
        translate([3.069,  2.894]) square([3.019, 0.503]);
        translate([3.069,  2.894]) square([0.503, 3.019]);
        translate([1.056,  5.410]) square([2.516, 0.503]);
        translate([1.057,  1.485]) square([0.503, 4.428]);
    }
}

module cap() {
    antenna_region_h = 6.6678;
    antenna_engrave_depth = 0.6; // orientation key debossed into the roof top

    difference() {
        // outer block
        cube([outer_w, outer_l, z_top]);

        // --- module cavity, OPEN AT THE BOTTOM (z=0) ---
        // PCB-body clearance: full module footprint, only up to the PCB top.
        // Clearance split evenly so the module sits centered (walls all equal).
        translate([wall_t - fit_clear/2, wall_t - fit_clear/2, -eps])
            cube([pcb_w + fit_clear, pcb_l + fit_clear, pcb_t + eps]);
        // Shield-can pocket: only the can footprint, from the PCB top to the
        // roof. The leftover shoulder material (PCB-footprint minus this pocket)
        // stays as RIMS that hug the can and locate the jig; the roof lands on
        // the can top (pocket top == cavity_top). Starts eps below the PCB top
        // so it overlaps the PCB-clearance cut (no coplanar seam at z=pcb_t).
        translate([wall_t + (pcb_w - shield_w)/2 - shield_clear/2,
                   wall_t + shield_y0 - shield_clear/2, pcb_t - eps])
            cube([shield_w + shield_clear, shield_l + shield_clear, shield_h + eps]);
        // Antenna relief: only a shallow clearance gap above the antenna trace
        // - the cap stays SOLID above it (no need to hollow the whole antenna
        // end; RF performance is irrelevant for a flashing jig). The gap also
        // absorbs the shield-height tolerance (the cap's Z rides on the can top).
        antenna_gap = 0.8;
        translate([wall_t, wall_t + pcb_l - antenna_region_h, pcb_t - eps])
            cube([pcb_w + fit_clear, antenna_region_h + eps, antenna_gap + eps]);

        // --- contact channels (outward + UP, breaking out near the top) ---
        // Right wall (X=pcb_w): TXD1, RXD1, GND. Points +X and up -> theta_y=-pin_angle.
        // TXD1/RXD1 also fan apart in Y (+-fan_angle) so their Dupont ends clear.
        angled_channel([wall_t + pcb_w + eps, wall_t + txd1_y, pad_z], -pin_angle,  fan_angle);
        angled_channel([wall_t + pcb_w + eps, wall_t + rxd1_y, pad_z], -pin_angle, -fan_angle);
        angled_channel([wall_t + pcb_w + eps, wall_t + gnd_y, pad_z], -pin_angle);

        // Left wall (X=0): CEN, VCC. Points -X and up -> theta_y = 180+pin_angle
        angled_channel([wall_t - eps, wall_t + cen_y, pad_z], 180 + pin_angle);
        angled_channel([wall_t - eps, wall_t + vcc_y, pad_z], 180 + pin_angle);


        // --- pad viewports through the roof, looking down onto each pad ---
        pad_window("right", min(rxd1_y, txd1_y) - 1, max(rxd1_y, txd1_y) + 1);
        pad_window("right", gnd_y - 1, gnd_y + 1);
        pad_window("left", cen_y - 1, cen_y + 1);
        pad_window("left", vcc_y - 1, vcc_y + 1);

        // --- debossed pin labels around each viewport ---
        le  = 0.5;                                        // left-edge start (+X)
        re  = outer_w - 0.5;                              // right-edge end (-X)
        ri  = wall_t + pcb_w + fit_clear - view_w - 0.7;  // inboard-right end
        off = 1 + 0.4 + label_size/2;                     // clearance past a window edge
        // VCC / GND: above their viewports, hugging the side edges
        pin_label("VCC", le, wall_t + vcc_y + off, label_size, "left");
        pin_label("GND", re, wall_t + gnd_y + off, label_size, "right");
        // CEN: below its viewport, left edge
        pin_label("CEN", le, wall_t + cen_y - off, label_size, "left");
        // TX1 beside its pad; RX1 stacked one line below it
        pin_label("TX1", ri, wall_t + txd1_y,                    label_size, "right");
        pin_label("RX1", ri, wall_t + txd1_y - label_size - 0.6, label_size, "right");

        // --- antenna orientation key, debossed into the roof top ---
        translate([wall_t, wall_t + pcb_l - antenna_region_h, z_top - antenna_engrave_depth])
            linear_extrude(height = antenna_engrave_depth + eps)
                antenna_pattern_2d(pcb_w, antenna_region_h);
    }
}

// Clamp: a sprung C-clip that hooks the back of the assembly and squeezes the
// JIG down onto the HOST PCB, with the soldered WB3S sandwiched between them, so
// the Dupont pins stay seated on the edge pads. The jaw therefore spans the full
// stack: jig top (z_top) down to the host-PCB underside (-host_pcb_t).
// Cross-section (Y-Z plane) is a "C" opening forward:
//   tongue: reaches forward UNDER the host PCB (z<0), pressing up
//   spine:  vertical section down the back of the jig
//   arm:    hooks over the jig top, pressing down
// The relaxed jaw is 'press' smaller than the stack, so installing it flexes the
// spine open and produces the clamping force.
// NOTE: assumes the host PCB is accessible from behind the module (WB3S near a
// board edge / cutout) so the tongue can hook under it.
module clamp() {
    tongue_t   = 2.0;             // bar hooking under the host PCB
    tongue_len = pcb_l * 0.5;     // how far forward under the host PCB it reaches
    spine_d    = 3.0;             // spine thickness (Y), behind the back wall
    arm_len    = pcb_l * 0.5;
    arm_t      = 2.4;
    press      = 0.4;             // interference: relaxed gap is 'press' less
                                  // than the stack -> spine flexes, clamping
    clamp_w    = 12;              // central band: wide for strength but still
    clamp_x    = wall_t + (pcb_w - clamp_w)/2; // clears the edge viewports

    tongue_top = -host_pcb_t;     // tongue hooks under the host-PCB underside
    arm_z      = z_top - press;   // arm underside (relaxed), 'press' below jig top

    // All three limbs run back to Y=outer_l+spine_d so they fuse into the
    // spine as one solid (overlap, not just touching faces).
    union() {
        // tongue (under the host PCB), pressing up
        translate([clamp_x, outer_l - wall_t - tongue_len, tongue_top - tongue_t])
            cube([clamp_w, tongue_len + wall_t + spine_d, tongue_t]);

        // spine (down the back of the jig), tying tongue to arm
        translate([clamp_x, outer_l, tongue_top - tongue_t])
            cube([clamp_w, spine_d, (arm_z + arm_t) - (tongue_top - tongue_t)]);

        // arm (over the jig top), pressing down
        translate([clamp_x, outer_l - arm_len, arm_z])
            cube([clamp_w, arm_len + spine_d, arm_t]);
    }
}

// ===================== Render =====================
cap();
translate([outer_w + 6, 0, 0]) clamp();
