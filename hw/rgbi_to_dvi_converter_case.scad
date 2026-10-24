// tandy2hdmi enclosure - first draft (UNTESTED: not rendered or printed yet)
// Coordinates = STEP/board coords: origin bottom-left of board, Z=0 is board underside, board top face Z=1.0.
// Render:  openscad -o base.stl -D 'PART="base"' tandy2hdmi_case.scad   (also "lid", "testfit", "assembly")
$fn = 48;
PART = "assembly";

// ---- board (measured from STEP) ----
bw = 65; bh = 50; bt = 1.0;
holes = [[3.576,3.954],[3.576,46.004],[61.357,3.878],[61.495,46.004]];   // dia 2.7

// ---- shell ----
wall = 2.4;  lip_t = 1.2;  lip_h = 2.0;  tol = 0.2;
ML = 1.5;  MR = 0.6;  MB = 0.6;  MT = 0.6;   // cavity margin left/right/bottom/top (left bigger for ribbon)
ro = 3;  rc = 1;                              // outer / cavity corner radius
floor_t = 3;  so_h = 3;  so_d = 6;            // J3/J4 tails stick 2.0 below board -> 1.0 clearance
zs = 10.8;                                    // split plane
j4_open = [0.3, 14.2, 12.5, 37.5];   // roof opening over J4 (x0,y0,x1,y1); header is x1.8-10.9, y15.7-36.0
Zin_lo = 13;  roof = 2;                         // lid inside height (J3 top 9.5) and roof thickness
// ---- screws (M2.5 from underneath, thread-forming into lid posts) ----
scr_clear = 2.9; head_d = 5.4; pilot_d = 1.95;   /* M2.3 screws; use 2.1 for M2.5 */ pilot_len = 8; post_d = 6;
// ---- ports / controls (VERIFY plug sizes and heights with a test fit) ----
J1_y = 24.99; J1_zc = 4.1; J1_w = 21; J1_h = 11;       // HDMI on right edge (z centre is an estimate)
J5_x = 34.99; J5_zc = 2.2; J5_w = 13; J5_h = 8;        // USB-C on top edge
SW1 = [17.27, 45.02]; sw1_tube_z = 5; sw1_hole = 3.4;  // BOOTSEL poke hole with guide tube
S1 = [23.89, 11.75];  s1_open = 9;                     // roof hole for the S1 cap shaft (shaft 4.5 -> 2.25 mm tilt room each side)

// J1 support pad under the board (clear of the shield-tab holes at y=17.7/32.2, and of the port cutout that starts at x=bw-1)
j1_pad = [55, 17.2, 63.5, 32.8];  j1_pad_gap = 0.0;   // x0,y0,x1,y1 ; gap between pad top and board underside
// J1 shield tangs below the board (from STEP): A x53.47-55.5 down to z=-1.16, B x60.0-60.8 down to z=-0.66,
// at both ends of the connector (y 17.49-18.0 and 32.0-32.49). Grooves = tang + 0.5 margin all round, 0.5 deeper.
tang_x = [[53.0,56.0],[59.5,61.3]];  tang_y = [[17.0,18.5],[31.5,33.0]];  tang_depth = 1.7;
module j1_tang_grooves(){
  for(tx=tang_x) for(ty=tang_y)
    translate([tx[0],ty[0],-tang_depth]) cube([tx[1]-tx[0], ty[1]-ty[0], tang_depth+0.5]);
}
// ---- S1 joystick cap (STEP: stick is 2.0 x 2.0 mm, corner R0.5, z 4.14..6.0 above board underside; base bump to z=4.0) ----
stick = 2.0; stick_r = 0.5; stick_rot = 0;   // stick_rot: 0 = square aligned to board axes as in the STEP; try 45 if the real stick is turned
cap_z0 = 4.3;  cap_pocket = 2.1;  cap_shaft = 4.5;  cap_top = 20.5;   // cap bottom, pocket depth, shaft dia, top (roof outer is 15)
cap_fl_d = 11;  cap_fl_z = 12.5;                                        // retaining flange (top at 12.5, roof underside 13)
module s1_cap(cl=0.1){   // cl = clearance per side around the stick; absolute board Z, centred on origin
  difference(){
    union(){
      translate([0,0,cap_z0]) cylinder(d=cap_shaft, h=cap_top-cap_z0-3.5);
      translate([0,0,cap_fl_z-1.25-(cap_fl_d-cap_shaft)/2]) cylinder(d1=cap_shaft, d2=cap_fl_d, h=(cap_fl_d-cap_shaft)/2);   // 45 deg cone under flange
      translate([0,0,cap_fl_z-1.25]) cylinder(d=cap_fl_d, h=1.25);
      translate([0,0,cap_top-3.5]) cylinder(d1=cap_shaft, d2=8, h=1.5);   // finger flare
      translate([0,0,cap_top-2]) cylinder(d=8, h=2);
    }
    translate([0,0,cap_z0-0.1]) rotate([0,0,stick_rot]) linear_extrude(cap_pocket+0.1) offset(r=stick_r) square(stick-2*stick_r+2*cl, center=true);
  }
}
// ---- S1 direction labels (engraved in the roof, readable from above with the USB-C edge at the top, HDMI at the right) ----
lab_r = 8;  lab_size = 3.5;  lab_depth = 0.6;  lab_rot = 0;   // lab_rot: 0 = letters on the board axes, 45 = on the diagonals
lab_font = "Liberation Sans:style=Bold";
module s1_labels(){
  for(l=[["U",90],["D",270],["L",180],["R",0]])
    translate([S1[0]+lab_r*cos(l[1]+lab_rot), S1[1]+lab_r*sin(l[1]+lab_rot), Zin_lo+roof-lab_depth])
      linear_extrude(lab_depth+0.1) text(l[0], size=lab_size, halign="center", valign="center", font=lab_font);
}
module rr(x0,y0,x1,y1,r){ translate([x0+r,y0+r]) offset(r=r) square([x1-x0-2*r, y1-y0-2*r]); }
module outer2d(){ rr(-ML-wall,-MB-wall,bw+MR+wall,bh+MT+wall,ro); }
module cav2d(){ rr(-ML,-MB,bw+MR,bh+MT,rc); }

module port_cuts(){
  translate([bw-1, J1_y-J1_w/2, J1_zc-J1_h/2]) cube([30, J1_w, J1_h]);
  translate([J5_x-J5_w/2, bh-1, J5_zc-J5_h/2]) cube([J5_w, 30, J5_h]);
}

module base(){
  difference(){
    union(){
      translate([0,0,-so_h-floor_t]) linear_extrude(floor_t) outer2d();
      translate([0,0,-so_h]) linear_extrude(so_h+zs) difference(){ outer2d(); cav2d(); }
      translate([0,0,zs]) linear_extrude(lip_h) difference(){ outer2d(); offset(delta=-lip_t) outer2d(); }
      for(h=holes) translate([h[0],h[1],-so_h]) cylinder(d=so_d, h=so_h);
      translate([j1_pad[0],j1_pad[1],-so_h]) cube([j1_pad[2]-j1_pad[0], j1_pad[3]-j1_pad[1], so_h-j1_pad_gap]);
    }
    for(h=holes) translate([h[0],h[1],-so_h-floor_t-1]) cylinder(d=scr_clear, h=floor_t+so_h+2);
    for(h=holes) translate([h[0],h[1],-so_h-floor_t-1]) cylinder(d=head_d, h=3);
    j1_tang_grooves();
    port_cuts();
  }
}

module lid(){
  difference(){
    union(){
      difference(){
        translate([0,0,zs+lip_h]) linear_extrude(Zin_lo+roof-zs-lip_h) outer2d();
        translate([0,0,zs]) linear_extrude(Zin_lo-zs) cav2d();
      }
      translate([0,0,zs+tol]) linear_extrude(lip_h-tol+0.01)
        difference(){ offset(delta=-lip_t-tol) outer2d(); cav2d(); }
      for(h=holes){ c = Zin_lo;
        translate([h[0],h[1],bt]) cylinder(d=post_d, h=c+0.5-bt); }
      translate([SW1[0],SW1[1],sw1_tube_z]) cylinder(d=sw1_hole+3, h=Zin_lo+0.5-sw1_tube_z);
    }
    for(h=holes) translate([h[0],h[1],bt-1]) cylinder(d=pilot_d, h=pilot_len+1);
    translate([SW1[0],SW1[1],sw1_tube_z-1]) cylinder(d=sw1_hole, h=40);
    translate([j4_open[0],j4_open[1],Zin_lo-1]) cube([j4_open[2]-j4_open[0], j4_open[3]-j4_open[1], roof+2]);
    translate([S1[0],S1[1],Zin_lo-1]) cylinder(d=s1_open, h=roof+2);
    s1_labels();
    port_cuts();
  }
}

if (PART=="base") base();
else if (PART=="lid") translate([0,0,0]) lid();
else if (PART=="lid_print") translate([0,0,Zin_lo+roof]) rotate([180,0,0]) lid();   // roof on the bed, posts pointing up
else if (PART=="s1_caps") for(i=[0:2]) translate([i*14,0,-cap_z0]) s1_cap(0.05+0.05*i);   // clearance 0.05 / 0.10 / 0.15
else if (PART=="testfit") intersection(){ base(); translate([38,-20,-20]) cube([80,100,60]); }
else { base(); translate([0,0,12]) lid(); translate([S1[0],S1[1],0]) s1_cap(0.1); %cube([bw,bh,bt]); }   // assembly (lid exploded 12 mm up)
