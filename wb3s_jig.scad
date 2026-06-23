// WB3S programming jig  (cap-over-the-top, sprung-arm contacts)
// The WB3S is already SMD-soldered (shield-up) onto a host PCB. The jig is a cap
// that registers over the soldered module (its pocket hugs the shield can) and
// carries printed SPRING ARMS for the five signals (VCC, GND, TXD1, RXD1, CEN) -
// four towers, since TXD1+RXD1 share one wide tower (see pair note below).
// Each arm holds a female-to-male Dupont jumper by its housing in a vertical SLEEVE,
// male pin pointing down. At rest the pin tip sits 'preload' below the host-PCB
// top; clamping the jig down (roof onto the shield can) flexes each arm up so the
// pin presses DOWN onto the exposed solder toe just outboard of the module's
// castellated edge. Pressing the horizontal toe makes the clamp/spring force load
// the contact DIRECTLY - unlike a rigid pin jammed against the vertical
// castellation, where the force is nearly orthogonal. The female ends plug into
// the UART adapter, so nothing wears.
//
// Each holder is a VERTICAL SLEEVE gripping the Dupont housing (cover up-stop at top,
// exposed pin pointing down through the foot). The pin sits 'preload' proud below the
// toe plane at rest, so seating the jig presses it flush onto the toe. The sleeve sits
// in a POCKET cut straight through the block; TWO radial flexure arms (a parallelogram)
// tie it to the central block so it translates vertically without tilting - that IS the
// spring. Every top (block, the
// holder covers, the labels) is COPLANAR at z_top, so the cap PRINTS FLIPPED (top face
// on the bed): no support, and each sleeve stands on the bed instead of levitating. The
// pin labels shrink to single letters (V/C/G/T/R) and move into the solid strip between
// the pockets. The sleeve's can-facing wall is notched inside the can envelope; the thin
// pin still reaches in to the toe. Footprint at the board surface is just the pin
// (edge + pin_land_out). NOTE: this makes the jig HOST-SPECIFIC - it relies on an
// exposed solder toe outboard of the module edge (verify your board has one).
//
// Because the WB3S is soldered down, it can't be gripped directly: the clamp
// presses the JIG down onto the HOST PCB (see clamp()), sandwiching the module.
// The clamp also supplies the arm preload, so it must resist the SUM of the five
// arm reaction forces, not merely seat the jig.
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
// (Table 2-1) + the MODULE mechanical drawing (Fig 6-1): 8 pads per long edge at
// 2mm pitch, with VCC/GND as the bottom corner pads pad_y0 from the Y=0 corner
// and CEN/TXD1/RXD1 counted up from there. (Fig 6-3 "recommended PCB layout" is
// the HOST land pattern, not the part - its pad centers are pulled ~0.07mm
// toward the board edge by a solder toe, so it's NOT the castellation geometry
// we probe.) Verify against your actual module with calipers before printing.
//
// References (datasheet & pinout are NOT bundled here for licensing reasons -
// see README.md; the dimensions above are transcribed from these):
//   WB3S datasheet (c) Tuya:       https://fcc.report/FCC-ID/2ANDL-WB3S/4580793.pdf
//   LibreTiny WB3S board / pinout: https://docs.libretiny.eu/boards/wb3s/

// spellchecker:ignore castellation centerlines datasheet deboss debossed dupont flexure
// spellchecker:ignore bambu differenced halign keepout libretiny pinout preload tuya uart
// spellchecker:ignore hous petg protosupplies txrx

$fn = 32;

// ===================== Module geometry =====================
pcb_l   = 24;     // module length (Y)
pcb_w   = 16;     // module width (X)
pcb_t   = 0.8;    // PCB substrate thickness (Z) - castellation pad height
shield_h = 2.0;   // shield can height above PCB top
fit_clear = 0.3;  // clearance around module in pocket
host_pcb_t = 1.0; // thickness of the host PCB the WB3S is soldered to

// Shield-can footprint (datasheet Fig 6-1/6-2). The roof pocket drops over the
// can and the surrounding RIMS hug its sides to locate the jig in X/Y; the roof
// bears on the can top for Z. VERIFY with calipers - read off low-res figures.
shield_l  = 15.1;  // can length (Y), from the side view
shield_w  = 14.6;  // can width (X), estimated (inset ~0.7mm per side)
shield_y0 = 1.5;   // can front edge, measured from the Y=0 (pad) end
shield_clear = 0.25; // slip clearance around the can

// Pad center Y-positions, in the SVG / top-view orientation. CEN + VCC on the
// X=0 (left) edge; TXD1/RXD1 + GND on the X=pcb_w (right) edge. Built up from
// the bottom corner pad at the module's 2mm pitch.
pad_y0    = 1.5485;  // bottom corner pad (VCC pin 8 / GND pin 9) center, from the
                     // Y=0 edge - WB3S MODULE mechanical drawing, Fig 6-1
pad_pitch = 2;       // pad pitch along each long edge (Fig 6-1)
txd1_y = pad_y0 + 7*pad_pitch;  // right edge (X=pcb_w), pin 16
rxd1_y = pad_y0 + 6*pad_pitch;  // right edge (X=pcb_w), pin 15
gnd_y  = pad_y0;                // right edge (X=pcb_w), pin 9  (bottom corner)
cen_y  = pad_y0 + 7*pad_pitch;  // left edge (X=0), pin 1
vcc_y  = pad_y0;                // left edge (X=0), pin 8  (bottom corner)

// ===================== Jig geometry =====================
wall_t  = 1.0;  // perimeter wall thickness (uniform); also the module-position
                // offset used throughout (cavity, reliefs, clamp). Thin to keep
                // the footprint small on cramped host PCBs.
// The cap is printed FLIPPED (top face on the bed): the cavity then opens upward and
// needs no support, and every coplanar top (block + holder covers + labels) is layer 1.

// Debossed pin labels on the roof top
label_font  = "Liberation Sans:style=Bold";
label_depth = 0.6;  // deboss depth
label_size  = 3.5;  // text height (single letters, two fit in the inter-pocket strip)

eps = 0.2; // overlap used when cutting, avoids coplanar/zero-thickness faces

outer_w = pcb_w + 2*wall_t;
outer_l = pcb_l + 2*wall_t;

cavity_top = pcb_t + shield_h;   // cavity ceiling rests on the shield can
// z_top is defined below, after the Dupont/holder params it depends on.

// ===================== Sprung-arm contacts =====================
// Each pad is contacted by a Dupont male pin held in a VERTICAL SLEEVE that sits in a
// pocket cut straight through the block. TWO flat radial flexure arms (low + high) run
// straight in (X) from the central block to the sleeve - a PARALLELOGRAM, so the sleeve
// translates vertically WITHOUT rotating and the pin stays vertical (no walk off the
// toe). They bend in Z and ARE the spring. Cover tops are coplanar with the block top,
// so the cap prints FLIPPED (top-down): every top is on the bed and the sleeves stand on
// it. Preload comes from the pin sitting 'preload' proud below the toe plane at rest;
// seating the jig pushes the pin up flush, flexing the arms and pressing the pin onto the
// solder toe just outboard of the module edge.
pin_land_out = 0.25;  // pin tip X, outboard of the module castellation edge
preload      = 0.4;   // pin tip below z=0 at rest -> flex (= contact travel) when seated
holder_tilt  = 0;     // sleeve lean from vertical (deg). 0 = vertical (best for the
                      // flipped print); the can-facing wall is notched to clear the
                      // can. Add a few deg only if your Dupont's pin_drop is short.
// TXD1/RXD1 are 2mm apart but the housings are ~2.54mm wide, so they can't sit in
// separate vertical towers. They SHARE one wide tower (pocket grown along the edge
// for both housings packed tight ~2.54mm apart); the two male pins are then bent in
// by hand ~0.27mm each onto the 2mm-pitch pads. One tower -> one shared spring.
// (pair pocket sizing: pair_slot below, after hous_clear is defined)

// Dupont female-to-male jumper, MALE end: 2.54mm housing. MEASURE YOURS - lengths vary a
// lot by brand (housing ~12-15mm, exposed pin ~3-6mm). Here: housing ~12mm, pin ~6mm
// below it (calipered). 'hous_grip' must equal the HOUSING length and 'pin_drop' the PIN
// length, because the housing top seats on the cover up-stop:
//   pin tip = cover - (hous_grip + pin_drop).
// If their SUM is too small, a longer real Dupont drives its pin straight through the board.
hous_clear = 0.6;         // pocket clearance around the Dupont housing (easy slide-in)
hous_w     = 2.54 + hous_clear;  // sleeve pocket (across)
hous_d     = 2.54 + hous_clear;  // sleeve pocket (depth)
hous_grip  = 12.0;        // Dupont housing length the sleeve wraps (cover seats on its top)
pin_drop   = 6.0;         // exposed male pin below the housing bottom (CALIPER YOURS)
tower_wall = 0.5;         // tower sleeve wall thickness
tower_cover = 1.0;        // top cap: the up-stop the housing seats against (reacts
                          // the contact force) and the vertical lock; slotted to center
bot_clear   = 0.5;        // sleeve bottom is cut flat this far above the can top, so the
                          // printed rim clears the can even if the pin is set low
load_slot   = 1.5;        // outboard slot (wire width): route the wire out / up
pair_slot   = 4.5;        // wide enough for BOTH cables side by side: housings sit ~2.54mm
                          // apart so the wires reach ~+/-2mm; 3.0 pinched them. The up-stop
                          // is unaffected (it's the cover's inboard-X half, always solid).

// ---- Flexure sizing, driven by the SLICER LAYER HEIGHT ----------------------------
// The arms are flat blades thin in Z, so their thickness is a whole number of layers and
// the spring force goes as thickness^3 - a fractional layer count makes the force a
// gamble. So: pick the layer height, force the arm to an integer (>=2) layers, then
// DERIVE the free length that holds the bending strain at 'strain_max'. Force follows
// (echoed). Downstream (pocket depth, label band) keys off arm_len, so it adapts.
layer_h    = 0.16; // slicer layer height. MAX 0.16 (asserted below): coarser layers
                   // thicken the arms, push the pockets inboard and starve the central
                   // block that carries the top-arm anchors + T/R labels. (Bambu: 0.16 /
                   // 0.12 / 0.08; 0.2 risks the center-block integrity.)
arm_layers = 2;    // arm thickness in layers; >=2 so the flexure is not a single bead
arm_t      = max(2, arm_layers) * layer_h;   // flexure thickness = whole number of layers
E_petg     = 2000; // PETG Young's modulus (MPa = N/mm^2); the design is PETG, NOT brittle PLA
strain_max = 0.02; // cap flexure surface strain (PETG yields ~2.5-4%; 2% for fatigue life)
arm_w      = 2.5;  // flexure leaf width (Y) - sets force (linear), not strain
// guided (parallelogram) beam: strain = 3*t*d/L^2  ->  length that just meets strain_max
arm_len    = sqrt(3 * arm_t * preload / strain_max);
relief_clear = 0.35;   // clearance each side (Y) between a holder and its pocket wall
// resulting per-pin contact force (two guided arms in parallel): F = 2*E*w*t^3*d/L^3
echo(str("flexure: arm_t=", arm_t, "mm (", max(2, arm_layers), " x ", layer_h,
         "), arm_len=", arm_len, "mm, force=",
         2*E_petg*arm_w*pow(arm_t, 3)*preload/pow(arm_len, 3), " N/pin"));

// Coplanar tops: the block top, every holder cover top, and the labels all sit at z_top
// (the Dupont cover top) - the pockets are cut straight through, so flipping the cap puts
// all of them flat on the bed. With holder_tilt=0 the cover top lands exactly on z_top,
// so no trim is needed. The flexure arm meets each sleeve at its MID height. (Defined
// here, after deps - OpenSCAD has no forward refs.)
z_top        = -preload + (pin_drop + hous_grip + tower_cover)*cos(holder_tilt);
holder_bot_z = cavity_top + bot_clear;  // flat sleeve-bottom cut, just above the can top
sleeve_bot_z = max(-preload + pin_drop, holder_bot_z); // sleeve foot: housing bottom, or the
                                                       // can-clearance cut, whichever is higher
// Put the two flexures flush with the sleeve's BOTTOM and TOP: widest possible
// parallelogram, and the upper arm lands on z_top so it prints flat on the plate (when
// flipped) with NO bridging; only the lower arm bridges the pocket.
arm_z_lo     = sleeve_bot_z + arm_t/2; // lower flexure, flush with the sleeve foot
arm_z_hi     = z_top - arm_t/2;        // upper flexure, flush with the top (on the bed, flipped)

function c_edge_x(side) = (side == "right") ? wall_t + pcb_w : wall_t;
function c_sign(side)   = (side == "right") ? 1 : -1;

// Sleeve geometry along X, shared by the holder pocket and the arm: the sleeve's
// block-facing (inboard) wall, and how far inboard the pocket / arm anchor reaches.
function holder_in_x(side) =
    c_edge_x(side) + c_sign(side)*(pin_land_out - hous_w/2 - tower_wall);
function pocket_in_x(side) = holder_in_x(side) - c_sign(side)*arm_len;

// ===================== Sanity guards =====================
// The central strip between the left/right pockets carries BOTH top-arm anchor laps and
// the debossed T/R labels. Its width is holder_in_x("right")-holder_in_x("left") - 2*arm_len,
// and arm_len grows with layer_h/preload (and 1/strain_max) - so a coarser layer silently
// starves it. Cap the layer height and assert the strip stays solid; else the print is
// structurally unsound or the labels get shaved off.
assert(layer_h <= 0.16, str("layer_h=", layer_h,
       "mm > 0.16: thicker arms thin the central block below structural/label limits. ",
       "Print at <=0.16mm."));
strip_w    = pocket_in_x("right") - pocket_in_x("left");
anchor_lap = 1.0;  // must match the xi inboard lap in dupont_arm()
assert(strip_w > 2*anchor_lap, str("central strip ", strip_w,
       "mm <= 2x arm anchor lap (", 2*anchor_lap, "mm): no solid core between pockets"));
assert(strip_w > 0.65*label_size + 1.0, str("central strip ", strip_w,
       "mm too thin for the T/R label (~", 0.65*label_size, "mm glyph) + 0.5mm margins"));

// Printed holder SLEEVE in its LOCAL frame: pin tip at origin, pin axis along +Z. The
// sleeve grips the Dupont HOUSING (pin_drop..housing top) and the cover above it; the
// male pin hangs exposed below. The pocket is OPEN AT THE BOTTOM - the Dupont (pin
// down) loads from below and is pushed up until its housing meets the 'tower_cover',
// the up-stop that reacts the contact force and locks it vertically. The exposed pin
// reaches down past the foot to the toe. An outboard 'load_slot' (wire width) runs up
// the side wall and across the cover to its center, so the wire routes out.
//   slot_dir = +1/-1 puts the slot on the OUTBOARD face. pocket_d is the pocket
//   size ALONG THE EDGE (Y-local) - one housing, or two for the TX1/RX1 pair.
module holder_local(slot_dir, pocket_d, slot_w) {
    ow = hous_w + 2*tower_wall;          // across (X-local)
    od = pocket_d + 2*tower_wall;        // along the edge (Y-local)
    cap_top = pin_drop + hous_grip + tower_cover;
    difference() {
        translate([-ow/2, -od/2, pin_drop])
            cube([ow, od, cap_top - pin_drop]);
        // housing pocket, open at the BOTTOM, capped by the cover above
        translate([-hous_w/2, -pocket_d/2, pin_drop - eps])
            cube([hous_w, pocket_d, hous_grip + eps]);
        // outboard load/wire slot: from center out through the slot_dir wall and
        // up through the cover (cover stays solid on the inboard half = the lock)
        sx = (slot_dir > 0) ? -eps : -ow/2 - eps;
        translate([sx, -slot_w/2, pin_drop - eps])
            cube([ow/2 + 2*eps, slot_w, (cap_top - pin_drop) + 2*eps]);
    }
}

// One contact: a vertical sleeve in its pocket + a TWO-arm parallelogram flexure tying it
// to the block (no rotation -> vertical pin). Built so the pin tip lands at (edge +
// pin_land_out, pad, -preload); the cover top is coplanar with the block top.
module dupont_arm(pad_y, side, pocket_d = hous_d, slot_w = load_slot) {
    s  = c_sign(side);
    a  = s * holder_tilt;                // sleeve lean (0 = vertical)
    lx = c_edge_x(side) + s * pin_land_out;
    py = wall_t + pad_y;
    xi = pocket_in_x(side) - s*1.0;          // inboard anchor, lapped into the solid block
    xo = holder_in_x(side) + s*tower_wall/2; // outboard end, lapped only halfway into the
                                             // sleeve wall (NOT into the housing pocket)
    x0 = min(xi, xo);
    x1 = max(xi, xo);

    difference() {
        union() {
            // vertical holder sleeve
            translate([lx, py, -preload]) rotate([0, a, 0])
                holder_local(s, pocket_d, slot_w);

            // PARALLELOGRAM flexure: two flat blades (low + high) straight in (X) from
            // the block to the sleeve. Equal and parallel, so the sleeve translates
            // vertically WITHOUT rotating - the pin stays vertical, no walk off the toe.
            // The upper blade is flush with z_top, so it prints flat on the plate when
            // flipped (no bridge); only the lower blade bridges the pocket.
            for (az = [arm_z_lo, arm_z_hi])
                translate([x0, py - arm_w/2, az - arm_t/2])
                    cube([x1 - x0, arm_w, arm_t]);
        }
        // notch the sleeve's can-facing wall where it enters the module/can envelope
        module_keepout();
        // cut the sleeve bottom flat, just above the can, so the printed rim clears it
        translate([-50, -50, holder_bot_z - 50]) cube([200, 500, 50]);
    }
}

// Pocket the holder sleeve + its inboard arm run sit in: cut straight through (open at
// the bottom so the pin drops to the toe, open at the top so the sleeve's cover is on
// the bed when flipped), reaching inboard to pocket_in_x and out past the outer wall.
// Block survives between pads and in the central strip (where the labels go).
module pad_relief(pad_y, side, w) {
    py = wall_t + pad_y;
    x0 = (side == "right") ? pocket_in_x("right") : -0.5;
    x1 = (side == "right") ? outer_w + 0.5        : pocket_in_x("left");
    // break clean through the short edge if less than a full wall_t of block would
    // be left (else a narrow relief_clear leaves an unprintable sliver there)
    y0 = (py - w/2 < wall_t)          ? -0.5         : py - w/2;
    y1 = (py + w/2 > outer_l - wall_t) ? outer_l + 0.5 : py + w/2;
    translate([x0, y0, -eps])
        cube([x1 - x0, y1 - y0, z_top + 2*eps]);
}

// Debossed pin label on the roof top. halign "left" starts the text at x; "right"
// ends it at x.
module pin_label(txt, x, y, halign) {
    translate([x, y, z_top - label_depth])
        linear_extrude(label_depth + eps)
            text(txt, size = label_size, font = label_font,
                 halign = halign, valign = "center");
}

// 2D serpentine antenna trace, in the physical-module orientation (the two
// long parallel meander segments at high X = the right side, matching the chip
// viewed top-down). Engraved into the TOP of the roof as an orientation key.
// 'grow' widens every line by 2*grow (centerlines unchanged) so the debossed
// groove clears one extrusion width: native trace = 0.503mm, +2*0.1 -> 0.703mm.
antenna_line_grow = 0.1;
module antenna_pattern_2d() {
    offset(r = antenna_line_grow) union() {
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

// The volume the inserted module occupies: PCB body (full footprint to the PCB top)
// + shield can (can footprint, PCB top to the roof underside). Used as the cap cavity
// AND differenced from each contact sleeve, so a sleeve's can-facing wall is notched
// away inside this envelope (the thin pin still reaches in).
module module_keepout() {
    translate([wall_t - fit_clear/2, wall_t - fit_clear/2, -eps])
        cube([pcb_w + fit_clear, pcb_l + fit_clear, pcb_t + eps]);
    translate([wall_t + (pcb_w - shield_w)/2 - shield_clear/2,
               wall_t + shield_y0 - shield_clear/2, pcb_t - eps])
        cube([shield_w + shield_clear, shield_l + shield_clear, shield_h + eps]);
}

module cap() {
    antenna_region_h = 6.6678;
    antenna_engrave_depth = 0.6; // orientation key debossed into the roof top
    // Clear band (Y) between the front (VCC/GND) and back (CEN / TX-RX pair) pockets, and
    // the centre margin so a debossed letter keeps >=0.5mm of material all round (worst
    // case: cap height = label_size).
    pkt_hw  = (hous_d + 2*tower_wall + 2*relief_clear)/2;  // single pocket half-Y
    band_lo   = wall_t + pad_y0 + pkt_hw;               // front pocket top edge
    band_hi_L = wall_t + cen_y  - pkt_hw;               // CEN pocket bottom edge (left)
    lm = 0.5 + label_size/2;                            // band edge -> letter centre margin

    union() {
        difference() {
            // outer block (simple cube - uniform thin perimeter)
            cube([outer_w, outer_l, z_top]);

            // --- module cavity, OPEN AT THE BOTTOM (z=0) ---
            // PCB body + shield-can pocket the module occupies. Factored into
            // module_keepout() and reused to notch the contact sleeves (above).
            // Leftover shoulder around the can = RIMS that locate the jig; the roof
            // lands on the can top (pocket top == cavity_top).
            module_keepout();
            // Antenna relief: a shallow clearance gap above the antenna trace; the
            // cap stays solid above it. Also absorbs the shield-height tolerance.
            antenna_gap = 0.8;
            translate([wall_t, wall_t + pcb_l - antenna_region_h, pcb_t - eps])
                cube([pcb_w + fit_clear, antenna_region_h + eps, antenna_gap + eps]);

            // --- long-wall reliefs (tower Y-extent + relief_clear each side) ---
            pad_relief((txd1_y + rxd1_y)/2, "right", (2*2.54 + hous_clear) + 2*tower_wall + 2*relief_clear);
            pad_relief(gnd_y, "right", hous_d + 2*tower_wall + 2*relief_clear);
            pad_relief(cen_y, "left",  hous_d + 2*tower_wall + 2*relief_clear);
            pad_relief(vcc_y, "left",  hous_d + 2*tower_wall + 2*relief_clear);

            // --- debossed pin labels, inboard of the edge reliefs ---
            // Labels on the OUTSIDE of the block, in the clear band beside their holders.
            // X is bounded by the block edge (left edge at 1.7, right at 16.3 -> 1.7mm of
            // material outboard); Y centres sit 'lm' inside the band so the letters keep
            // >=0.5mm all round. T/R can't go outboard (the antenna key blocks above the
            // pair), so both sit CENTRED in the narrow central strip - T high, R below it -
            // splitting the margin both sides so a thinner strip won't shave them.
            strip_cx = (pocket_in_x("left") + pocket_in_x("right"))/2;  // central strip centre (X)
            pin_label("V", 1,  band_lo   + lm, "left");   // above the VCC holder
            pin_label("C", 1,  band_hi_L - lm, "left");   // below the CEN holder
            pin_label("G", 17, band_lo   + lm, "right");  // above the GND holder
            pin_label("T", strip_cx, wall_t + txd1_y, "center"); // in the strip by the pair
            // R stacked 0.5mm below T (centre-to-centre = a full letter + the 0.5mm gap)
            pin_label("R", strip_cx, wall_t + txd1_y - (label_size + 0.5), "center");

            // --- antenna orientation key, debossed into the roof top ---
            translate([wall_t, wall_t + pcb_l - antenna_region_h, z_top - antenna_engrave_depth])
                linear_extrude(height = antenna_engrave_depth + eps)
                    antenna_pattern_2d();
        }

        // --- sprung-arm contacts (TX1+RX1 share one wide tower) ---
        dupont_arm((txd1_y + rxd1_y)/2, "right", 2*2.54 + hous_clear, pair_slot);
        dupont_arm(gnd_y,  "right");
        dupont_arm(cen_y,  "left");
        dupont_arm(vcc_y,  "left");
    }
}

// Clamp: a sprung C-clip that hooks the back of the assembly and squeezes the
// JIG down onto the HOST PCB, with the soldered WB3S sandwiched between them, so
// the arm preload is maintained. The jaw spans the full stack: jig top (z_top)
// down to the host-PCB underside (-host_pcb_t).
// Cross-section (Y-Z plane) is a "C" opening forward:
//   tongue: reaches forward UNDER the host PCB (z<0), pressing up
//   spine:  vertical section down the back of the jig
//   arm:    hooks over the jig top, pressing down
// The relaxed jaw is 'press' smaller than the stack, so installing it flexes the
// spine open and produces the clamping force. NOTE: this must now exceed the SUM
// of the five contact-arm reactions (~5 x per-pin force), not just seat the jig.
// Assumes the host PCB is accessible from behind the module so the tongue can hook.
module clamp() {
    tongue_t   = 2.0;             // bar hooking under the host PCB
    tongue_len = pcb_l * 0.5;     // how far forward under the host PCB it reaches
    spine_d    = 3.0;             // spine thickness (Y), behind the back wall
    arm_len    = 7;               // short: bear on the back only (y beyond the pad
                                  // rows) so the top arm clears the radial flexure
                                  // leaves, which now reach inboard at each pad
    arm_t      = 2.4;
    press      = 0.2;             // interference: relaxed gap is 'press' less than
                                  // the stack -> spine flexes, clamping
    clamp_w    = 12;              // central band, between the side contact arms
    clamp_x    = wall_t + (pcb_w - clamp_w)/2;

    tongue_top = -host_pcb_t;     // tongue hooks under the host-PCB underside
    arm_z      = z_top - press;   // arm underside (relaxed), 'press' below jig top

    // All three limbs run back to Y=outer_l+spine_d so they fuse into the
    // spine as one solid (overlap, not just touching faces).
    union() {
        translate([clamp_x, outer_l - wall_t - tongue_len, tongue_top - tongue_t])
            cube([clamp_w, tongue_len + wall_t + spine_d, tongue_t]);
        translate([clamp_x, outer_l, tongue_top - tongue_t])
            cube([clamp_w, spine_d, (arm_z + arm_t) - (tongue_top - tongue_t)]);
        translate([clamp_x, outer_l - arm_len, arm_z])
            cube([clamp_w, arm_len + spine_d, arm_t]);
    }
}

// ===================== Render =====================
show = "all";   // "all" | "cap" | "clamp" | "none"  (use -D show=\"none\" for sections)
if (show == "all" || show == "cap")   cap();
if (show == "all" || show == "clamp") translate([outer_w + 18, 0, 0]) clamp();
