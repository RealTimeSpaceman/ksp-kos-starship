
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
    print "Attack angle: " at (0, 13).
    print "Target vSpd:  " at (0, 14).
    print "----------------------------" at (0, 15).
    print "Throttle:     " at (0, 16).
    print "Engines:      " at (0, 17).
    print "Propellant %: " at (0, 18).

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
    print round(angAttack, 2) + "    " at (14, 13).
    print round(tarVSpeed, 0) + "    " at (14, 14).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 16).
    print round(engines, 0) + "    " at (14, 17).
    print round(remProp, 2) + "    " at (14, 18).

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
    set logline to logline + round(angAttack, 2) + ",".
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

// Engine groups
global colRB is list(RB01, RB02, RB03, RB04, RB05, RB06, RB07, RB08, RB09, RB10, RB11, RB12, RB13, RB14, RB15, RB16, RB17, RB18, RB19, RB20).
global colRG is list(RG01, RG02, RG03, RG04, RG05, RG06, RG07, RG08, RG09).
global colRGOdd is list(RG03, RG05, RG07, RG09).
global colRG26 is list(RG02, RG06).
global colRG48 is list(RG04, RG08).

// Grid fin group
global colGF is list(FLCS, FRCS, RLCS, RRCS).

// Landing pad - tower catch
//global landingPad is latlng(26.0384593, -97.1533248). // Catch point
//global landingPad is latlng(26.0384823, -97.1532032). // Mid point
global landingPad is latlng(26.0385053, -97.1530816). // Aim point

global padEntDir is 270.
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
lock angAttack to vAng(srfPrograde:vector, SHIP:facing:vector).

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
set logline to logline + "Angle of attack,".
set logline to logline + "Target VSpd,".
set logline to logline + "Throttle,".
set logline to logline + "Engines,".
set logline to logline + "Rem prop,".
log logline to sh_bb_log.csv.

write_console().

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

global secEngSpl is 3.
set apoDist to 35000.

if remProp > 18 {

    until throttle = 1 { write_screen("Pre-launch"). }

    local timEngSpl is time:seconds + secEngSpl.
    until time:seconds > timEngSpl { write_screen("Engine spool"). }

    stage.

    // ASCENT
    until remProp < 18 { write_screen("Ascent"). }

    // STAGE - shutdown engines
    for RB in colRB { RB:Shutdown. }
    for RG in colRG { RG:Shutdown. }
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
    lock steering to lookdirup(heading(headBB, 0):vector, heading(0, -90):vector). // Aim at horizon in direction of retrograde
    until vAng(SHIP:facing:vector, heading(headBB, 0):vector) < 30 { write_screen("Flip"). }

    // BOOSTBACK - Activate gimbal engines
    for RG in colRG { RG:Activate. }
    set engines to 9.
    set throttle to 1.

    until abs(padBear) < 70 { write_screen("Boostback"). }

    // TARGET PAD
    set pidTarPad TO pidLoop(10, 0.5, 2, -30, 30).
    set pidTarPad:setpoint to 0.
    // Aim at horizon, reduce bearing to pad to zero
    lock steering to lookdirup(heading(landingPad:heading - pidTarPad:update(time:seconds, padBear), 0):vector, heading(0, -90):vector).

    // Shutdown 4 gimbal engines
    for RG in colRGOdd { RG:Shutdown. }
    set engines to 5.

    local overshoot is 700.
    local timeFall is sqrt((2 * SHIP:apoapsis) / 9.8).
    lock tarSrfVel to (surfDist + overshoot) / (eta:apoapsis + timeFall).

    until SHIP:groundspeed > tarSrfVel {
        write_screen("Target Pad").
        print "tarSrfVel:    " + round(tarSrfVel, 0) + "    " at(0, 19).
    }
    print "                                  " at(0, 19).
    set apoDist to timeFall * tarSrfVel.
    unlock tarSrfVel.
    
    // COAST
    rcs off.

}

// Post BoostBack
set throttle to 0.

// Shutdown boost engines
for RB in colRB { RB:Shutdown. }

// Activate gimbal engines
for RG in colRGOdd { RG:Activate. }
set engines to 9.

// Enable grid fin control
for GF in colGF{ GF:setfield("pitch", false). }
for GF in colGF{ GF:setfield("yaw", false). }
for GF in colGF{ GF:setfield("roll", false). }

// Variables for entry burn
global altEntBrn is 33000.
global secEntBrn is 8.

// Aim at retrograde
lock angAttack to vAng(srfRetrograde:vector, SHIP:facing:vector).
lock steering to lookdirup(srfRetrograde:vector, heading(0, 90):vector).
until SHIP:altitude < altEntBrn { write_screen("Coast"). }

// ******** ENTRY BURN ********
rcs on.
set throttle to 1.

// Calculate desired angle for falling trajectory - not using yet
set arcShape to 10.
lock tarVAngle to arcTan(arcShape - ((surfDist / apoDist) * arcShape)).
lock axsPadRet to vcrs(landingPad:position, srfRetrograde:vector).
lock dirDesire to angleAxis(tarVAngle, axsPadRet).
lock vecDesire to dirDesire * landingPad:position.

// Calculate attack vector to drag prograde vector towards the landing point vector - perhaps want to replace landingPad:position with desired vector to avoid direct line

// angVector (scalar) is the angle between the prograde vector and the vector to the landing point - want to minimise this
// lock angVector to vAng(srfPrograde:vector, landingPad:position).
lock angVector to vAng(srfPrograde:vector, landingPad:position).

// tarDirect (direction) is a rotation of degrees (1st parameter) around an axis (2nd parameter) here defined as the cross product of the two relevant vectors
lock tarDirect to angleAxis(angVector * (0 - 4) - 1, axsPadRet).

// Here we lock steering (direction) to the product of tardirect and the retrograde vector
lock steering to lookdirup(tarDirect * srfRetrograde:vector, heading(padEntDir, 0):vector).

local timEngSpl is time:seconds + secEngSpl.
until time:seconds > timEngSpl { write_screen("Engine spool"). }

local timEntBrn is time:seconds + secEntBrn.
until time:seconds > timEntBrn { write_screen("Entry burn"). }

// ******** RE-ENTRY ********
set throttle to 0.
set maxDeflect to 12.

// We swap tarDirect to the opposite direction now so as to use aero instead of thrust to try and minimise angVector
lock tarDirect to angleAxis(min(maxDeflect + angVector, angVector * 12), axsPadRet).

until SHIP:altitude < 16000 { write_screen("Re-entry"). }

// ******** FINAL APPROACH ********
global tarAlt is 170.
global engAcl is 40.
lock altLndBrn to (0 - SHIP:verticalspeed * secEngSpl) + ((SHIP:verticalspeed * SHIP:verticalspeed) / (2 * engAcl)) + tarAlt.

until SHIP:altitude < altLndBrn {
    write_screen("Final approach").
    print "Suicide burn at:" + round(altLndBrn, 0) + "    " at(0, 19).
}
print "                        " at(0, 19).

// ******** ENGINE SPOOL ********
lock throttle to 1.
set timEngSpl to time:seconds + secEngSpl.

// Landing burn at retrograde for stability
//lock steering to lookdirup(srfRetrograde:vector, heading(padEntDir, 0):vector).

until time:seconds > timEngSpl { write_screen("Engine spool"). }

// Swap tardirect back now we are flying under thrust
lock tarDirect to angleAxis(max(0 - maxDeflect, angVector * (0 - 8) - 1), axsPadRet).

// ******** LANDING BURN ********
set shHeight to 20.
lock altAdj to alt:radar - shHeight.

lock tarVSpeed to 0 - (sqrt(altAdj / 1000) * 150).

until SHIP:verticalspeed > tarVSpeed { write_screen("Landing burn"). }

// This should bring the vehicle towards the target altitude and have it hover at that alt
set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.
lock tarVSpeed to (tarAlt - altAdj) / 5.
lock throttle to max(0.0001, pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed)).

until altAdj < 500 { write_screen("Balance throttle"). }

// Shutdown gimbal engines
for RG in colRGOdd { RG:Shutdown. }
set engines to 5.

// ******** TARGET PAD ********
until SHIP:verticalspeed > -25 { write_screen("Target pad"). }


// Time to resolve in seconds, maximum of 5
set timeToRes to 0.01 + min(5, surfDist / 20).
// vecThrust is the direction the vehicle should push towards to move the surface velocity vector towards the vector to the landing pad
lock vecThrust to ((vecLndPad / timeToRes) - vecSrfVel).
// What heading should the vehicle thrust towards
lock thrHead to heading_of_vector(vecThrust).

lock steering to lookdirup(vecThrust + (150 * up:vector), heading(padEntDir, 0):vector).

// lock steering to lookdirup(vecLndPad + (max(150, padDist * 5) * up:vector) - (9 * vecSrfVel), heading(padEntDir, 0):vector).

// ******** PAD HOVER ********
until surfDist < 5 and SHIP:groundspeed < 5 and altAdj < 300 {
    write_screen("Pad approach").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 19).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 20).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 21).
}

set landingPad to latlng(26.0384593, -97.1533248).
set tarAlt to 130.

until surfDist < 5 and SHIP:groundspeed < 3 and SHIP:altitude < 300 {
    write_screen("Pad descent").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 19).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 20).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 21).
}

// ******** DESCENT ********

lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).
set tarAlt to 100.

set tarVSpeed to -5.

until SHIP:altitude < 220 and abs(SHIP:verticalspeed) < 1 { write_screen("Descent"). }

// Tower Catch
set throttle to 0.
set SHIP:control:top to 0.
set SHIP:control:starboard to 0.
unlock steering.
rcs off.
write_screen("Tower Catch").

