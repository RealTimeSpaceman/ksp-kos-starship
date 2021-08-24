
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
    print "Zenith-Retro: " at (0, 6).
    print "----------------------------" at (0, 7).
    print "Srf distance: " at (0, 8).
    print "Pad distance: " at (0, 9).
    print "Pad bearing:  " at (0, 10).
    print "----------------------------" at (0, 11).
    print "Pitch (ret):  " at (0, 12).
    print "Yaw   (ret):  " at (0, 13).
    print "Roll   (up):  " at (0, 14).
    print "----------------------------" at (0, 15).
    print "Throttle:     " at (0, 16).
    print "Propellant %: " at (0, 17).

}

function write_screen {

    global curPitAng is get_pit(srfRetrograde).
    global curYawAng is get_yawnose(srfRetrograde).
    global curRolAng is get_rollnose(up).
    global zenRetAng is vAng(up:vector, srfRetrograde:vector).

    parameter phase.
    // clearScreen.
    print phase + "        " at (14, 0).
    // print "----------------------------".
    print round(SHIP:altitude / 1000, 2) + "    " at (14, 2).
    // print "----------------------------".
    print round(SHIP:groundspeed, 0) + "    " at (14, 4).
    print round(SHIP:verticalspeed, 0) + "    " at (14, 5).
    print round(zenRetAng, 2) + "    " at (14, 6).
    // print "----------------------------".
    print round(surfDist / 1000, 2) + "    " at (14, 8).
    print round(padDist, 2) + "    " at (14, 9).
    print round(padBear, 2) + "    " at (14, 10).
    // print "----------------------------".
    print round(curPitAng, 2) + "    " at (14, 12).
    print round(curYawAng, 2) + "    " at (14, 13).
    print round(curRolAng, 2) + "    " at (14, 14).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 16).
    print round(remProp, 2) + "    " at (14, 17).

    local logline is time:seconds + ",".
    set logline to logline + phase + ",".
    set logline to logline + round(SHIP:altitude / 1000, 0) + ",".
    set logline to logline + round(SHIP:groundspeed, 0) + ",".
    set logline to logline + round(SHIP:verticalspeed, 0) + ",".
    set logline to logline + round(zenRetAng, 2) + ",".
    set logline to logline + round(surfDist / 1000, 2) + ",".
    set logline to logline + round(padDist, 2) + ",".
    set logline to logline + round(padBear, 2) + ",".
    set logline to logline + round(curPitAng, 2) + ",".
    set logline to logline + round(curYawAng, 2) + ",".
    set logline to logline + round(curRolAng, 2) + ",".
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
runOncePath("MD_PYR_Funcs").
runPath("MD_Ini_SH_Launch").

//---------------------------------------------------------------------------------------------------------------------
// INITIALISE
//---------------------------------------------------------------------------------------------------------------------

// Engine groups
global colRB is list(RB01, RB02, RB03, RB04, RB05, RB06, RB07, RB08, RB09, RB10, RB11, RB12, RB13, RB14, RB15, RB16, RB17, RB18, RB19, RB20).
global colRG is list(RG01, RG02, RG03, RG04, RG05, RG06, RG07, RG08, RG09).
global colRGOdd is list(RG01, RG03, RG05, RG07, RG09).

// Grid fin group
global colGF is list(FLCS, FRCS, RLCS, RRCS).

// Landing pad - tower crane
global landingPad is latlng(26.035898, -97.149736).
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

// Write first line of log
deletePath(SH_BB_log).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Altitude,".
set logline to logline + "Horizontal speed,".
set logline to logline + "Vertical speed,".
set logline to logline + "Retro to Zenith,".
set logline to logline + "Surface distance,".
set logline to logline + "Pad distance,".
set logline to logline + "Pad bearing,".
set logline to logline + "Pitch ang,".
set logline to logline + "Yaw ang,".
set logline to logline + "Roll ang,".
set logline to logline + "Throttle,".
log logline to SH_BB_log.

write_console().

global curPitAng is 0.
global curYawAng is 0.
global curRolAng is 0.

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

if FT:Resources[0]:amount > 400000 {

    // ASCENT
    until FT:Resources[0]:amount < 400000 { write_screen("Ascent"). }

    // STAGE - shutdown engines
    for RB in colRB { RB:Shutdown. }
    for RG in colRG { RG:Shutdown. }
    stage.

    local timeStage is time:seconds + 2.
    until time:seconds > timeStage { write_screen("Stage"). }

    // FLIP - Enable grid fin control
    for GF in colGF{ GF:setfield("pitch", false). }
    for GF in colGF{ GF:setfield("yaw", false). }
    for GF in colGF{ GF:setfield("roll", false). }

    rcs on.
    set SHIP:control:pitch to 1. // Begin pitch over
    local timeRCS is time:seconds + 1.
    until time:seconds > timeRCS { write_screen("Flip"). }
    set SHIP:control:pitch to 0. // Slow spin
    set timeRCS to time:seconds + 4.
    until time:seconds > timeRCS { write_screen("Flip"). }
    local headBB is heading_of_vector(srfRetrograde:vector).
    lock steering to lookdirup(heading(headBB, 0):vector, heading(0, -90):vector). // Aim at horizon in direction of restrograde
    until vAng(SHIP:facing:vector, heading(headBB, 0):vector) < 10 { write_screen("Flip"). }

    // BOOSTBACK - Activate gimbal engines
    for RG in colRG { RG:Activate. }
    set throttle to 1.

    until abs(padBear) < 50 { write_screen("Boostback"). }

    // TARGET PAD
    set pidTarPad TO pidLoop(10, 0.5, 2, -30, 30).
    set pidTarPad:setpoint to 0.
    // Aim at horizon, reduce bearing to pad to zero
    lock steering to lookdirup(heading(landingPad:heading - pidTarPad:update(time:seconds, padBear), 0):vector, heading(0, -90):vector).

    // Shutdown 5 gimbal engines
    for RG in colRGOdd { RG:Shutdown. }

    local overshoot is 1000.
    local timeFall is sqrt((2 * SHIP:apoapsis) / 9.8).
    lock tarSrfVel to (surfDist + overshoot) / (eta:apoapsis + timeFall).

    until SHIP:groundspeed > tarSrfVel {
        write_screen("Target Pad").
        print "tarSrfVel:    " + round(tarSrfVel, 0) + "    " at(0, 18).
    }
    print "                                  " at(0, 18).
    unlock tarSrfVel.
}

// Post BoostBack
set throttle to 0.

// Shutdown boost engines
for RB in colRB { RB:Shutdown. }

// Activate gimbal engines
for RG in colRG { RG:Activate. }

// Enable grid fin control
for GF in colGF{ GF:setfield("pitch", false). }
for GF in colGF{ GF:setfield("yaw", false). }
for GF in colGF{ GF:setfield("roll", false). }

// Variables for entry burn
global altEntBrn is 33000.
global secEntBrn is 5.
global secEngSpl is 4.

// COAST
rcs off.

// Aim at retrograde
lock steering to lookdirup(heading(landingPad:heading + 180, 90 - vAng(up:vector, srfRetrograde:vector)):vector, heading(0, 90):vector).
until SHIP:altitude < altEntBrn { write_screen("Coast"). }

// ENTRY BURN
set pidEntBrn TO pidLoop(2, 0.1, 3, -5, 5).
set pidEntBrn:setpoint to 0.
rcs on.
set throttle to 1.

local timEngSpl is time:seconds + secEngSpl.
until time:seconds > timEngSpl { write_screen("Engine spool"). }

// Aim retrograde but reduce bearing to pad
lock steering to lookdirup(heading(landingPad:heading + 180 + pidEntBrn:update(time:seconds, padBear), 90 - vAng(up:vector, srfRetrograde:vector)):vector, SHIP:up:vector).
local timEntBrn is time:seconds + secEntBrn.
until time:seconds > timEntBrn { write_screen("Entry burn"). }

// RE-ENTRY
set throttle to 0.

// Variables for long range pitch tracking
// global lrpTarDst is 1.
// global lrpTarAlt is 5.
// global lrpConst is 0.95.
// global lrpRatio is 0.0024.

// lock adjDst to ((surfDist / 1000) - lrpTarDst).
// lock adjAlt to ((SHIP:altitude / 1000) - lrpTarAlt).
// lock tarPitAng to ((adjAlt / adjDst) - lrpConst) / lrpRatio.
// lock tarPitAng to max(60, min(120, ((adjAlt / adjDst) - lrpConst) / lrpRatio)).

// Steer towards pad
lock steering to lookdirup(heading(landingPad:heading + 180 - (padBear * 5), 90 - vAng(up:vector, srfRetrograde:vector)):vector, heading(landingPad:heading, 90):vector).
until SHIP:altitude < 16000 { write_screen("Re-entry"). }

// FINAL APPROACH
global altFinal is 85.
global engAcl is 53.
lock altLndBrn to (0 - SHIP:verticalspeed * secEngSpl) + ((SHIP:verticalspeed * SHIP:verticalspeed) / (2 * engAcl)) + altFinal.

until SHIP:altitude < altLndBrn {

    write_screen("Final approach").
    print "Suicide burn at:" + round(altLndBrn, 0) + "    " at(0, 18).

}
print "                        " at(0, 18).
// unlock altLndBrn.
// unlock adjDst.
// unlock adjAlt.
// unlock tarPitAng.

// LANDING BURN
set shHeight to 70.
lock altAdj to alt:radar - shHeight.
set tarVSpd1 to -250.
set tarVSpd2 to -100.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.

lock steering to srfRetrograde.
lock throttle to 1.

until SHIP:verticalspeed > tarVSpd1 { write_screen("Landing burn"). }

// TARGET PAD
lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), heading(padEntDir, 0):vector).
until SHIP:verticalspeed > tarVSpd2 {
    write_screen("Landing burn").
    // set SHIP:CONTROL:STARBOARD to pidLat:update(time:seconds, padRelLat).
    // set SHIP:CONTROL:FORE to pidLng:update(time:seconds, padRelLng).
}

lock padRelLat to SHIP:geoPosition:lat - landingPad:lat.
lock padRelLng to SHIP:geoPosition:lng - landingPad:lng.
set pidLat TO pidLoop(0.1, 0.001, 0.2, -1, 1).
set pidLat:setpoint to 0.
set pidLng TO pidLoop(0.1, 0.001, 0.2, -1, 1).
set pidLng:setpoint to 0.

// PAD HOVER
lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), heading(padEntDir, 0):vector).
lock tarVSpeed to 0 - ((altAdj - altFinal) * (SHIP:groundspeed / surfDist)).
lock throttle to pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed).
// Shutdown odd gimbal engines
for RG in colRGOdd { RG:Shutdown. }

// Want to stifle any lateral movement here possibly using pilot translation controls + PID controller

until surfDist < 25 and SHIP:groundspeed < 4 {
    write_screen("Pad hover").
    set SHIP:CONTROL:STARBOARD to pidLat:update(time:seconds, padRelLat).
    set SHIP:CONTROL:FORE to pidLng:update(time:seconds, padRelLng).
}

// DESCENT
lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).
// Could change altFinal here instead
lock tarVSpeed to 0 - (SHIP:bounds:bottomaltradar / 10).

until SHIP:bounds:bottomaltradar < 1 {
    write_screen("Descent").
    set SHIP:CONTROL:STARBOARD to pidLat:update(time:seconds, padRelLat).
    set SHIP:CONTROL:FORE to pidLng:update(time:seconds, padRelLng).
}
