
//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------

function write_console {
    
    clearScreen.
    print "Phase:        " at (0, 0).
    print "----------------------------" at (0, 1).
    print "Altitude:     " at (0, 2).
    print "----------------------------" at (0, 3).
    print "Hrz speed:    " at (0, 4).
    print "Vrt speed:    " at (0, 5).
    print "----------------------------" at (0, 6).
    print "Srf distance: " at (0, 7).
    print "Pad distance: " at (0, 8).
    print "Pad bearing:  " at (0, 9).
    print "L/R delta(m): " at (0, 10).
    print "----------------------------" at (0, 11).
    print "Pad rel. lat: " at (0, 12).
    print "Pad rel. lng: " at (0, 13).
    print "RCS Port/Stb: " at (0, 14).
    print "RCS Fore/Bak: " at (0, 15).
    print "----------------------------" at (0, 16).
    print "Throttle:     " at (0, 17).
    print "Propellant %: " at (0, 18).

}

function write_screen {

    parameter phase.
    // clearScreen.
    print phase + "        " at (14, 0).
    // print "----------------------------".
    print round(SHIP:altitude / 1000, 2) + "    " at (14, 2).
    // print "----------------------------".
    print round(SHIP:groundspeed, 0) + "    " at (14, 4).
    print round(SHIP:verticalspeed, 0) + "    " at (14, 5).
    // print "----------------------------".
    print round(surfDist / 1000, 2) + "    " at (14, 7).
    print round(padDist, 2) + "    " at (14, 8).
    print round(padBear, 2) + "    " at (14, 9).
    print round(lrDelta, 0) + "    " at (14, 10).
    // print "----------------------------".
    print round(padRelLat, 4) + "    " at (14, 12).
    print round(padRelLng, 4) + "    " at (14, 13).
    print round(SHIP:control:starboard, 2) + "    " at (14, 14).
    print round(SHIP:control:fore, 2) + "    " at (14, 15).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 17).
    print round(remProp, 2) + "    " at (14, 18).

    local logline is time:seconds + ",".
    set logline to logline + phase + ",".
    set logline to logline + round(SHIP:altitude / 1000, 0) + ",".
    set logline to logline + round(SHIP:groundspeed, 0) + ",".
    set logline to logline + round(SHIP:verticalspeed, 0) + ",".
    set logline to logline + round(surfDist / 1000, 2) + ",".
    set logline to logline + round(padDist, 2) + ",".
    set logline to logline + round(padBear, 2) + ",".
    set logline to logline + round(padRelLat, 6) + ",".
    set logline to logline + round(padRelLng, 6) + ",".
    set logline to logline + round(SHIP:control:starboard, 2) + ",".
    set logline to logline + round(SHIP:control:fore, 2) + ",".
    set logline to logline + round(throttle, 2) + ",".
    set logline to logline + round(remProp, 2) + ",".
    log logline to SH_BB_log.

}

function heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
    parameter vecT.
    local east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).
    local trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
    local trig_y IS VDOT(east, vecT).
    local result IS ARCTAN2(trig_y, trig_x).
    if result < 0 { return 360 + result. } else { return result. }
}

function relative_bearing {
    parameter headA.
    parameter headB.
    local delta is headB - headA.
    if delta > 180 { return delta - 360. }
    if delta < -180 { return delta + 360. }
    return delta.
}

//---------------------------------------------------------------------------------------------------------------------
// SHIP CONTROLS
//---------------------------------------------------------------------------------------------------------------------

runOncePath("MD_SH_Bind").
runPath("MD_Ini_SH_Launch").

//---------------------------------------------------------------------------------------------------------------------
// INITIALISE
//---------------------------------------------------------------------------------------------------------------------

// Engine groups
global colRB is list(RB01, RB02, RB03, RB04, RB05, RB06, RB07, RB08, RB09, RB10, RB11, RB12, RB13, RB14, RB15, RB16, RB17, RB18, RB19, RB20).
global colRG is list(RG01, RG02, RG03, RG04, RG05, RG06, RG07, RG08, RG09).
global colRGOdd is list(RG03, RG05, RG07, RG09).

// Grid fin group
global colGF is list(FLCS, FRCS, RLCS, RRCS).

// Landing pad - tower catch
global landingPad is latlng(26.0359779, -97.1531888).
global padEntDir is 270.

// Track remaining propellant
lock remProp to (FT:Resources[0]:amount / 2268046) * 100.

// Track distance and heading to pad
lock SHHeading to heading_of_vector(SHIP:srfprograde:vector).
lock padDist to landingPad:distance / 1000.
lock padBear to relative_bearing(SHHeading, landingPad:heading).
lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SHIP:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SHIP:geoposition:position)):mag.
lock lrDelta to sin(padBear) * surfDist.
lock padRelLat to (SHIP:geoPosition:lat - landingPad:lat) * 1000.
lock padRelLng to (SHIP:geoPosition:lng - landingPad:lng) * 1000.

// Write first line of log
deletePath(SH_BB_log).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Altitude,".
set logline to logline + "Horizontal speed,".
set logline to logline + "Vertical speed,".
set logline to logline + "Surface distance,".
set logline to logline + "Pad distance,".
set logline to logline + "Pad bearing,".
set logline to logline + "Throttle,".
log logline to SH_BB_log.

write_console().

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

// Enable grid fin control
for GF in colGF{ GF:setfield("pitch", false). }
for GF in colGF{ GF:setfield("yaw", false). }
for GF in colGF{ GF:setfield("roll", false). }

// Ascent
global altFinal is 130.
set shHeight to 20.
lock altAdj to alt:radar - shHeight.
set tarVSpd1 to 40.
set tarVSpd2 to -20.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.

lock steering to up.
lock throttle to 1.
rcs on.

stage.

// Shutdown boost engines
for RB in colRB { RB:Shutdown. }


until SHIP:verticalspeed > tarVSpd1 { write_screen("Ascent"). }

// TARGET PAD
lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), heading(padEntDir, 0):vector).
until SHIP:verticalspeed > tarVSpd2 { write_screen("Target pad"). }

// PAD HOVER
lock tarVSpeed to 0 - ((altAdj - altFinal) * (SHIP:groundspeed / surfDist)).
lock throttle to pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed).

// Shutdown odd gimbal engines
for RG in colRGOdd { RG:Shutdown. }


until surfDist < 10 and SHIP:groundspeed < 2 { write_screen("Pad hover"). }

// DESCENT

// Shutdown centre engine
RG01:Shutdown.

set pidLat TO pidLoop(5, 0.1, 2, -1, 1).
set pidLat:setpoint to 0.
set pidLng TO pidLoop(5, 0.1, 2, -1, 1).
set pidLng:setpoint to 0.

lock velNorth to vxcl(heading(90, 0):vector, vecSrfVel).
lock velEast to vxcl(heading(0, 0):vector, vecSrfVel).

lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).

// Lower altFinal
// set altFinal to 10.
set tarVSpeed to -3.

// Stifle any lateral movement using pilot translation controls + PID controller
until SHIP:altitude < 150 and abs(SHIP:verticalspeed) < 1 {
    write_screen("Descent").
    print "vel North:    " + round(velNorth:mag, 2) + "    " at(0, 19).
    print "vel East:     " + round(velEast:mag, 2) + "    " at(0, 20).
    set SHIP:control:starboard to 0 - pidLat:update(time:seconds, padRelLat).
    set SHIP:control:fore to pidLng:update(time:seconds, padRelLng).
}

set throttle to 0.
rcs off.

