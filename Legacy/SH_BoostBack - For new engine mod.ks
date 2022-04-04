
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
    print "Air speed:    " at (0, 6).
    print "----------------------------" at (0, 7).
    print "Srf distance: " at (0, 8).
    print "Pad distance: " at (0, 9).
    print "----------------------------" at (0, 10).
    print "Pad bearing:  " at (0, 11).
    print "Vector angle: " at (0, 12).
    print "Target vAng:  " at (0, 13).
    print "Target vSpd:  " at (0, 14).
    print "----------------------------" at (0, 15).
    print "Throttle:     " at (0, 16).
    print "Max thrust:   " at (0, 17).
    print "Thrust:       " at (0, 18).
    print "Propellant %: " at (0, 19).

}

function write_screen {

    parameter phase.
    // clearScreen.
    print phase + "        " at (14, 0).
    // print "----------------------------".
    print round(SHIP:altitude, 0) + "    " at (14, 2).
    // print "----------------------------".
    print round(SHIP:groundspeed, 0) + "    " at (14, 4).
    print round(SHIP:verticalspeed, 0) + "    " at (14, 5).
    print round(SHIP:airspeed, 0) + "    " at (14, 6).
    // print "----------------------------".
    print round(surfDist, 0) + "    " at (14, 8).
    print round(padDist, 0) + "    " at (14, 9).
    // print "----------------------------".
    print round(padBear, 2) + "    " at (14, 11).
    print round(angVector, 2) + "    " at (14, 12).
    print round(tarVAngle, 2) + "    " at (14, 13).
    print round(tarVSpeed, 0) + "    " at (14, 14).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 16).
    print round(SHIP:MaxThrust, 0) + "    " at (14, 17).
    print round(SHEC:Thrust, 0) + "    " at (14, 18).
    print round(remProp, 2) + "    " at (14, 19).

    local logline is time:seconds + ",".
    set logline to logline + phase + ",".
    set logline to logline + round(SHIP:altitude, 0) + ",".
    set logline to logline + round(SHIP:groundspeed, 0) + ",".
    set logline to logline + round(SHIP:verticalspeed, 0) + ",".
    set logline to logline + round(SHIP:airspeed, 0) + ",".
    set logline to logline + round(surfDist, 0) + ",".
    set logline to logline + round(padDist, 0) + ",".
    set logline to logline + round(padBear, 2) + ",".
    set logline to logline + round(angVector, 2) + ",".
    set logline to logline + round(tarVAngle, 2) + ",".
    set logline to logline + round(tarVSpeed, 0) + ",".
    set logline to logline + round(throttle, 2) + ",".
    set logline to logline + round(engines, 0) + ",".
    set logline to logline + round(remProp, 2) + ",".
    log logline to sh_bb_log.csv.

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

// // Engine groups
// global colRB is list(RB01, RB02, RB03, RB04, RB05, RB06, RB07, RB08, RB09, RB10, RB11, RB12, RB13, RB14, RB15, RB16, RB17, RB18, RB19, RB20).
// global colRG is list(RG01, RG02, RG03, RG04, RG05, RG06, RG07, RG08, RG09).
// global colRGOdd is list(RG03, RG05, RG07, RG09).
// global colRG26 is list(RG02, RG06).
// global colRG48 is list(RG04, RG08).

// Grid fin group
global colGF is list(FLCS, FRCS, RLCS, RRCS).

// Landing pad - tower catch
//global landingPad is latlng(26.0384537, -97.1532676). // Tower catch
//global landingPad is latlng(26.0385378, -97.1531998). // mid-way
global landingPad is latlng(26.0386219, -97.1561320). // Aim point
//global landingPad is latlng(26.0383845, -97.1564766).
//set landingPad to latlng(26.0383845, -97.1565766).
//global padEntDir is 270.
global padEntDir is 262.
global engines is 29.

// Track remaining propellant
lock remProp to (FT:Resources[0]:amount / 2268046) * 100.

// Track distance and heading to pad
lock SHHeading to heading_of_vector(SHIP:srfprograde:vector).
lock padDist to landingPad:distance.
lock padBear to relative_bearing(SHHeading, landingPad:heading).
lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SHIP:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SHIP:geoposition:position)):mag.
lock angVector to 0.
lock tarVAngle to 0.
lock tarVSpeed to 0.

// Write first line of log
deletePath(sh_bb_log.csv).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Altitude,".
set logline to logline + "Horizontal speed,".
set logline to logline + "Vertical speed,".
set logline to logline + "Air Speed,".
set logline to logline + "Srf distance,".
set logline to logline + "Pad distance,".
set logline to logline + "Pad bearing,".
set logline to logline + "Vector angle,".
set logline to logline + "Target VAng,".
set logline to logline + "Target VSpd,".
set logline to logline + "Throttle,".
set logline to logline + "Engines,".
set logline to logline + "Rem prop,".
log logline to sh_bb_log.csv.

write_console().

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

set apoDist to 35000.

if remProp > 18 {

    // HOLD DOWN
    until SHEC:Thrust > 75000 { write_screen("Hold Down"). }
    OPLC:DoAction("release clamp", true).

    // ASCENT
    until remProp < 18 { write_screen("Ascent"). }

    // STAGE - shutdown engines
    // for RB in colRB { RB:Shutdown. }
    // for RG in colRG { RG:Shutdown. }
    SHEC:Shutdown.
    set engines to 0.
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
    lock steering to lookdirup(heading(headBB, 0):vector, up:inverse:vector). // Aim at horizon in direction of retrograde
    until vAng(SHIP:facing:vector, heading(headBB, 0):vector) < 20 { write_screen("Flip"). }

    // BOOSTBACK - Activate gimbal engines
    // for RG in colRG { RG:Activate. }
    // Ullage control
    set SHIP:control:fore to 1.
    set timUllage to time:seconds + 1.
    until time:seconds > timUllage { write_screen("Ullage motors"). }

    // Activate middle inner engines
    until ECSW:GetField("mode") = "Middle Inner" { ECSW:DoAction("next engine mode", true). }
    ECAE:DoAction("shutdown engine", true).
    ECMI:DoAction("activate engine", true).
    ECCT:DoAction("activate engine", true).
    SHEC:Activate.
    set engines to 9.
    set throttle to 1.
    set SHIP:control:fore to 0.

    until abs(padBear) < 50 { write_screen("Boostback"). }

    // TARGET PAD
    set pidTarPad TO pidLoop(10, 0.5, 2, -30, 30).
    set pidTarPad:setpoint to 0.
    // Aim at horizon, reduce bearing to pad to zero
    lock steering to lookdirup(heading(landingPad:heading - pidTarPad:update(time:seconds, padBear), 0):vector, up:vector).

    // Shutdown 4 gimbal engines ***************************
    // for RG in colRGOdd { RG:Shutdown. }
    // set engines to 5.

    // Activate centre three engines
    // until ECSW:GetField("mode") = "Center Three" { ECSW:DoAction("next engine mode", true). }
    // ECAE:DoAction("shutdown engine", true).
    // ECMI:DoAction("shutdown engine", true).
    // ECCT:DoAction("activate engine", true).
    until SHIP:maxthrust < 7000 { ECSW:DoAction("next engine mode", true). }
    set engines to 3.

    local overshoot is 700.
    local timeFall is sqrt((2 * SHIP:apoapsis) / 9.8).
    lock tarSrfVel to (surfDist + overshoot) / (eta:apoapsis + timeFall).

    until SHIP:groundspeed > tarSrfVel {
        write_screen("Target Pad").
        print "tarSrfVel:    " + round(tarSrfVel, 0) + "    " at(0, 20).
    }
    print "                                  " at(0, 20).
    set apoDist to timeFall * tarSrfVel.
    unlock tarSrfVel.
    
    // COAST
    rcs off.

}

// Post BoostBack
set throttle to 0.

// Shutdown boost engines ***************************
// for RB in colRB { RB:Shutdown. }

// Activate gimbal engines ***************************
// for RG in colRGOdd { RG:Activate. }
// set engines to 9.

// Activate centre three engines
// until ECSW:GetField("mode") = "Center Three" { ECSW:DoAction("next engine mode", true). }
// ECAE:DoAction("shutdown engine", true).
// ECMI:DoAction("shutdown engine", true).
// ECCT:DoAction("activate engine", true).
ECSW:DoAction("next engine mode", true).
until SHIP:maxthrust > 7000 and SHIP:maxthrust < 25000 { ECSW:DoAction("next engine mode", true). }
set engines to 9.
SHEC:Shutdown.

// Enable grid fin control
for GF in colGF{ GF:setfield("pitch", false). }
for GF in colGF{ GF:setfield("yaw", false). }
for GF in colGF{ GF:setfield("roll", false). }

// Variables for entry burn
global altEntRCS is 36000.
global altEntBrn is 33000.
global secEntBrn is 10.
global secEngSpl is 0.

// Activate RCS
lock steering to lookdirup(srfRetrograde:vector, heading(0, 90):vector).
until SHIP:altitude < altEntRCS { write_screen("Coast"). }
rcs on.

// Aim at retrograde
lock steering to lookdirup(srfRetrograde:vector, heading(0, 90):vector).
until SHIP:altitude < altEntBrn { write_screen("Coast"). }

// ******** ENTRY BURN ********
SHEC:Activate.
set throttle to 1.

// Calculate desired angle for falling trajectory - not using yet
// set arcShape to 10.
// lock tarVAngle to arcTan(arcShape - ((surfDist / apoDist) * arcShape)).

// Calculate attack vector to drag motion vector towards landingPad:position
lock angVector to vAng(srfPrograde:vector, landingPad:position). //Angle between direction of travel and direction of landing pad
lock angCorrect to max(5, angVector * 6).
lock tarDirect to angleAxis(angCorrect, vcrs(landingPad:position, srfRetrograde:vector)).
lock steering to lookdirup(tarDirect * srfRetrograde:vector, heading(padEntDir, 0):vector).

local timEngSpl is time:seconds + secEngSpl.
until time:seconds > timEngSpl { write_screen("Engine spool"). }

//lock steering to lookdirup(srfRetrograde:vector, heading(padEntDir, 0):vector).

local timEntBrn is time:seconds + secEntBrn.
until time:seconds > timEntBrn {
    write_screen("Entry burn").
    if (SHEC:Thrust > SHIP:maxThrust) { until SHEC:Thrust > 7000 and SHEC:Thrust < 25000 { ECSW:DoAction("next engine mode", true). } }
}

// ******** RE-ENTRY ********
set throttle to 0.
ECSW:DoAction("next engine mode", true).
until SHIP:maxthrust > 7000 and SHIP:maxthrust < 25000 { ECSW:DoAction("next engine mode", true). }
set engines to 9.
SHEC:Shutdown.

lock tarDirect to angleAxis(0 - angCorrect, vcrs(landingPad:position, srfRetrograde:vector)).
//lock steering to lookdirup(tarDirect * srfRetrograde:vector, heading(padEntDir, 0):vector).

until SHIP:altitude < 16000 { write_screen("Re-entry"). }

// ******** FINAL APPROACH ********
global altFinal is 220.
global engAcl is 60.
lock altLndBrn to (0 - SHIP:verticalspeed * secEngSpl) + ((SHIP:verticalspeed * SHIP:verticalspeed) / (2 * engAcl)) + altFinal.

until SHIP:altitude < altLndBrn {

    write_screen("Final approach").
    print "Suicide burn at:" + round(altLndBrn, 0) + "    " at(0, 20).

}
print "                        " at(0, 20).

// ******** ENGINE SPOOL ********
// Activate middle engines
// until ECSW:GetField("mode") = "Middle Inner" { ECSW:DoAction("next engine mode", true). }
// ECAE:DoAction("shutdown engine", true).
// ECMI:DoAction("activate engine", true).
// ECCT:DoAction("activate engine", true).
SHEC:Activate.
until SHIP:maxthrust > 7000 and SHIP:maxthrust < 25000 { ECSW:DoAction("next engine mode", true). }
set engines to 9.
lock throttle to 1.
set timEngSpl to time:seconds + secEngSpl.
until time:seconds > timEngSpl { write_screen("Engine spool"). }

// ******** LANDING BURN ********
set shHeight to 20.
lock altAdj to alt:radar - shHeight - altFinal.

lock angVector to vAng(srfPrograde:vector, landingPad:position).
lock tarDirect to angleAxis(angVector * 2, vcrs(srfRetrograde:vector, landingPad:position)).
lock steering to lookdirup(tarDirect * srfRetrograde:vector, heading(padEntDir, 0):vector).
lock tarVSpeed to 0 - (sqrt(altAdj / 1000) * 200).

until SHIP:verticalspeed > tarVSpeed { write_screen("Landing burn"). }

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.1, 1).
set pidThrottle:setpoint to 0.
lock throttle to max(0.1, pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed)).

until altAdj < 200 { write_screen("Balance throttle"). }

// ******** TARGET PAD ********
until SHIP:verticalspeed > -25 { write_screen("Target pad"). }
lock steering to lookdirup(vecLndPad + (max(150, padDist * 5) * up:vector) - (9 * vecSrfVel), heading(padEntDir, 0):vector).

// Shutdown gimbal engines ***************************
// for RG in colRGOdd { RG:Shutdown. }
// set engines to 5.

lock tarVSpeed to (0 - altAdj) / 3.

// ******** PAD HOVER ********
until surfDist < 5 and SHIP:groundspeed < 2 and SHIP:altitude < 300 {
    write_screen("Pad approach").
    if verticalspeed > tarVSpeed + 2 {
        // for RG in colRG26 { RG:Shutdown. } // ***************************
        // until ECSW:GetField("mode") = "Center Three" { ECSW:DoAction("next engine mode", true). }
        // ECAE:DoAction("shutdown engine", true).
        // ECMI:DoAction("shutdown engine", true).
        // ECCT:DoAction("activate engine", true).
        until SHIP:maxthrust < 7000 { ECSW:DoAction("next engine mode", true). }
        set engines to 3.
    }
}

//set landingPad to latlng(26.0359779, -97.1531888).
//set landingPad to latlng(26.0383845, -97.1565766).
set landingPad to latlng(26.0384537, -97.1532676).
set altFinal to 200.

until surfDist < 5 and SHIP:groundspeed < 1 and SHIP:altitude < 300 {
    write_screen("Pad descent").
    if verticalspeed > tarVSpeed + 2 {
        // for RG in colRG26 { RG:Shutdown. } // ***************************
        // until ECSW:GetField("mode") = "Center Three" { ECSW:DoAction("next engine mode", true). }
        // ECAE:DoAction("shutdown engine", true).
        // ECMI:DoAction("shutdown engine", true).
        // ECCT:DoAction("activate engine", true).
        until SHIP:maxthrust < 7000 { ECSW:DoAction("next engine mode", true). }
        set engines to 3.
    }
}

// ******** DESCENT ********

lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).

set tarVSpeed to -3.

until SHIP:altitude < 150 and abs(SHIP:verticalspeed) < 1 { write_screen("Descent"). }

// Tower Catch
set throttle to 0.
rcs off.
write_screen("Tower Catch").
