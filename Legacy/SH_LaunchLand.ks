
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
    print "Target vAng:  " at (0, 15).
    print "----------------------------" at (0, 16).
    print "Throttle:     " at (0, 17).
    print "Engines:      " at (0, 18).
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
    print round(angAttack, 2) + "    " at (14, 13).
    print round(tarVSpeed, 0) + "    " at (14, 14).
    print round(tarVAngle, 2) + "    " at (14, 15).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 17).
    print round(engines, 0) + "    " at (14, 18).
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
    set logline to logline + round(angAttack, 2) + ",".
    set logline to logline + round(tarVSpeed, 0) + ",".
    set logline to logline + round(tarVAngle, 0) + ",".
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
global landingPad is latlng(26.0385053, -97.1530816). // Aim point - BC

// Bch altitude at base is 71m
global geoBChAim is latlng(26.0385053, -97.1530816). // Aim point - BC
global geoBChCat is latlng(26.0384593, -97.1533248). // Catch point - BC
global dirBChEnt is 262.
global pctBChPrp is 18.
global altBChBse is 71.

// GoM altitude at base is 6m
global geoGoMAim is latlng(25.322628, -93.820360). // Aim point - GoM
global geoGoMCat is latlng(25.322994, -93.820184). // Catch point - GoM
global dirGoMEnt is 82.
global pctGoMPrp is 10.
global altGoMBse is 6.

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
set logline to logline + "Target VAng,".
set logline to logline + "Throttle,".
set logline to logline + "Engines,".
set logline to logline + "Rem prop,".
log logline to sh_bb_log.csv.

write_console().

// Camera settings
global cam is addons:camera:flightcamera.
// set cam:mode to "locked".
// set cam:pitch to 0.
// set cam:heading to -90.

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

global secEngSpl is 3.
// set cam:pitch to 0.
// set cam:heading to -90.

if remProp > 18 {

    until throttle = 1 { write_screen("Pre-launch"). }

    local timEngSpl is time:seconds + secEngSpl.
    until time:seconds > timEngSpl { write_screen("Engine spool"). }

    stage.

    // ASCENT
    until remProp < 18 {
        write_screen("Ascent").
        print "Dyn press:    " + round(SHIP:q, 3) + "    " at(0, 20).
    }
    print "                                  " at(0, 20).

    // STAGE - shutdown engines
    for RB in colRB { RB:Shutdown. }
    for RG in colRG { RG:Shutdown. }
    set engines to 0.
    stage.

    set cam:target to FT.
    set cam:pitch to 0.
    set cam:heading to -90.

    local timeStage is time:seconds + 2.
    until time:seconds > timeStage {
        write_screen("Stage").
        set cam:target to FT.
        set cam:pitch to 0.
        set cam:heading to -90.
    }

    // FLIP - Enable grid fin control
    for GF in colGF{ GF:setfield("pitch", false). }
    for GF in colGF{ GF:setfield("yaw", false). }
    for GF in colGF{ GF:setfield("roll", false). }

    rcs on.
    set SHIP:control:pitch to 1. // Begin pitch over
    local timeRCS is time:seconds + 1.
    until time:seconds > timeRCS {
        write_screen("Flip").
        set cam:target to FT.
        set cam:pitch to 0.
        set cam:heading to -90.
    }
    set SHIP:control:pitch to 0. // Slow spin
    set timeRCS to time:seconds + 4.
    until time:seconds > timeRCS {
        write_screen("Flip").
        set cam:target to FT.
        set cam:pitch to 0.
        set cam:heading to -90.
    }
    local headBB is heading_of_vector(srfRetrograde:vector).
    lock steering to lookdirup(heading(headBB, 0):vector, heading(0, -90):vector). // Aim at horizon in direction of retrograde
    until vAng(SHIP:facing:vector, heading(headBB, 0):vector) < 30 { write_screen("Flip"). }

    // BOOSTBACK - Activate gimbal engines
    for RG in colRG { RG:Activate. }
    set engines to 9.
    set throttle to 1.
    local timEngSpl is time:seconds + secEngSpl.
    until time:seconds > timEngSpl {
        write_screen("Engine spool").
        set cam:target to FT.
        set cam:pitch to 0.
        set cam:heading to -90.
    }

    until abs(padBear) < 70 { write_screen("Boostback"). }

    // TARGET PAD
    set pidTarPad TO pidLoop(10, 0.5, 2, -30, 30).
    set pidTarPad:setpoint to 0.
    // Aim at horizon, reduce bearing to pad to zero
    lock steering to lookdirup(heading(landingPad:heading - pidTarPad:update(time:seconds, padBear), 0):vector, heading(0, -90):vector).

    // Shutdown 4 gimbal engines
    for RG in colRGOdd { RG:Shutdown. }
    set engines to 5.

    local overshoot is 600.
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

// Set camera
// set cam:pitch to 0.
// set cam:heading to -90.

// Aim at retrograde
lock angAttack to vAng(srfRetrograde:vector, SHIP:facing:vector).
lock steering to lookdirup(srfRetrograde:vector, heading(0, 90):vector).
until SHIP:altitude < altEntBrn { write_screen("Coast"). }

// ******** ENTRY BURN ********
rcs on.
set throttle to 1.

// Calculate desired angle for falling trajectory
lock tarVAngle to (alt:radar - 1000) / 5000.
lock axsPadZen to vcrs(landingPad:position, SHIP:up:vector).
lock rotPadDes to angleAxis(tarVAngle, axsPadZen).
lock vecDesire to rotPadDes * landingPad:position.
lock axsProDes to vcrs(srfPrograde:vector, vecDesire).

// Calculate attack vector to drag prograde vector towards the landing point vector - perhaps want to replace landingPad:position with desired vector to avoid direct line

// angVector (scalar) is the angle between the prograde vector and the desired vector - want to minimise this
lock angVector to vAng(srfPrograde:vector, vecDesire).

// rotProDes (direction) is a rotation of degrees (1st parameter) around an axis (2nd parameter) here defined as the cross product of the two relevant vectors
lock rotProDes to angleAxis(angVector * (0 - 4) - 1, axsProDes). // Look to use a pid controller here

// Here we lock steering (direction) to the product of rotProDes and the retrograde vector - retrograde because steering points the 'head' of the vehicle and we are travelling 'feet' first
lock steering to lookdirup(rotProDes * srfRetrograde:vector, heading(padEntDir, 0):vector).

local timEngSpl is time:seconds + secEngSpl.
until time:seconds > timEngSpl {
    write_screen("Engine spool").
    // Draw vectors
    // set vdPad to vecDraw(v(0,0,0), landingPad:position, rgb(0, 0, 1), "Pad", 0.1, true, 0.2, true, true).
    // set vdDes to vecDraw(v(0,0,0), vecDesire, rgb(0, 1, 0), "Desired", 50, true, 0.001, true, true).
    // set vdPro to vecDraw(v(0,0,0), srfPrograde:vector, rgb(1, 0, 0), "Motion", 50, true, 0.001, true, true).
    // set vdAxs to vecDraw(v(0,0,0), axsPadZen, rgb(1, 0.5, 0), "Axis", 0.05, true, 0.2, true, true).
}

local timEntBrn is time:seconds + secEntBrn.
until time:seconds > timEntBrn {
    write_screen("Entry burn").
    // Draw vectors
    // set vdPad to vecDraw(v(0,0,0), landingPad:position, rgb(0, 0, 1), "Pad", 0.1, true, 0.2, true, true).
    // set vdDes to vecDraw(v(0,0,0), vecDesire, rgb(0, 1, 0), "Desired", 50, true, 0.001, true, true).
    // set vdPro to vecDraw(v(0,0,0), srfPrograde:vector, rgb(1, 0, 0), "Motion", 50, true, 0.001, true, true).
    // set vdAxs to vecDraw(v(0,0,0), axsPadZen, rgb(1, 0.5, 0), "Axis", 0.05, true, 0.2, true, true).
}

// ******** RE-ENTRY ********
set throttle to 0.
set maxDflAer to 6.
set maxDflThr to 7.

set pidAeroLn to pidLoop(6, 0.01, 0.01, 0, maxDflAer).
set pidAeroLn:setpoint to 0.

// We swap rotProDes to the opposite direction now so as to use aero instead of thrust to try and minimise angVector
lock axsProDes to vcrs(vecDesire, srfPrograde:vector).
lock rotProDes to angleAxis(pidAeroLn:update(time:seconds, angVector), axsProDes).

// Here we lock steering (direction) to the product of rotProDes and the negative of the desired vector - negative because steering points the 'head' of the vehicle and we are travelling 'feet' first
lock steering to lookdirup(rotProDes * -vecDesire, heading(padEntDir, 0):vector).

until SHIP:altitude < 16000 {
    write_screen("Re-entry").
    // Draw vectors
    // set vdPad to vecDraw(v(0,0,0), landingPad:position, rgb(0, 0, 1), "Pad", 0.1, true, 0.2, true, true).
    // set vdDes to vecDraw(v(0,0,0), vecDesire, rgb(0, 1, 0), "Desired", 50, true, 0.001, true, true).
    // set vdPro to vecDraw(v(0,0,0), srfPrograde:vector, rgb(1, 0, 0), "Motion", 50, true, 0.001, true, true).
    // set vdAxs to vecDraw(v(0,0,0), axsPadZen, rgb(1, 0.5, 0), "Axis", 0.05, true, 0.2, true, true).
}

// ******** FINAL APPROACH ********
global tarAlt is 150.
global engAcl is 40.
lock altLndBrn to (0 - SHIP:verticalspeed * secEngSpl) + ((SHIP:verticalspeed * SHIP:verticalspeed) / (2 * engAcl)) + tarAlt.

until SHIP:altitude < altLndBrn or SHIP:altitude < 4000 {
    write_screen("Final approach").
    print "Suicide burn at:" + round(altLndBrn, 0) + "    " at(0, 20).
    // Draw vectors
    // set vdPad to vecDraw(v(0,0,0), landingPad:position, rgb(0, 0, 1), "Pad", 0.1, true, 0.2, true, true).
    // set vdDes to vecDraw(v(0,0,0), vecDesire, rgb(0, 1, 0), "Desired", 50, true, 0.001, true, true).
    // set vdPro to vecDraw(v(0,0,0), srfPrograde:vector, rgb(1, 0, 0), "Motion", 50, true, 0.001, true, true).
    // set vdAxs to vecDraw(v(0,0,0), axsPadZen, rgb(1, 0.5, 0), "Axis", 0.05, true, 0.2, true, true).
}
print "                        " at(0, 20).

// set vdPad to vecDraw(v(0,0,0), landingPad:position, rgb(0, 0, 1), "Pad", 0.1, false, 0.2, true, true).
// set vdDes to vecDraw(v(0,0,0), vecDesire, rgb(0, 1, 0), "Desired", 50, false, 0.001, true, true).
// set vdPro to vecDraw(v(0,0,0), srfPrograde:vector, rgb(1, 0, 0), "Motion", 50, false, 0.001, true, true).
// set vdAxs to vecDraw(v(0,0,0), axsPadZen, rgb(1, 0.5, 0), "Axis", 0.05, false, 0.2, true, true).

// ******** ENGINE SPOOL ********
lock throttle to 1.
set timEngSpl to time:seconds + secEngSpl.

until time:seconds > timEngSpl { write_screen("Engine spool"). }

// Swap angVector to landingPad vector and reverse rotProDes now we are flying under thrust
lock angVector to vAng(srfPrograde:vector, landingPad:position).
lock axsProDes to vcrs(srfPrograde:vector, landingPad:position).
lock rotProDes to angleAxis(max(0 - maxDflThr, angVector * (0 - 8) - 1), axsProDes). // Look to use a pid controller here
lock steering to lookdirup(rotProDes * srfRetrograde:vector, heading(padEntDir, 0):vector).

// ******** LANDING BURN ********
lock tarVSpeed to 0 - (sqrt((alt:radar - tarAlt) / 1000) * 100).

until SHIP:verticalspeed > tarVSpeed { write_screen("Landing burn"). }

// Shutdown gimbal engines
for RG in colRGOdd { RG:Shutdown. }
set engines to 5.

// This should bring the vehicle towards the target altitude and have it hover at that alt
set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.
lock throttle to max(0.0001, pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed)).

until alt:radar < 500 { write_screen("Balance throttle"). }
lock tarVSpeed to (tarAlt - alt:radar) / 5.

// Time to resolve in seconds, maximum of 5
set timeToRes to 0.01 + min(5, surfDist / 20).
// vecThrust is the direction the vehicle should push towards to move the surface velocity vector towards the vector to the landing pad
lock vecThrust to ((vecLndPad / timeToRes) - vecSrfVel).
// What heading should the vehicle thrust towards
lock thrHead to heading_of_vector(vecThrust).

lock steering to lookdirup(vecThrust + (150 * up:vector), heading(padEntDir, 0):vector).

// ******** PAD APPROACH ********
until surfDist < 5 and SHIP:groundspeed < 5 and alt:radar < 200 {
    write_screen("Pad approach").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

set landingPad to latlng(26.038489, -97.153189).
set tarAlt to 110.

// ******** PAD DESCENT ********
lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).
until surfDist < 5 and SHIP:groundspeed < 3 and SHIP:altitude < 300 {
    write_screen("Pad descent").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

// ******** DESCENT ********
set tarAlt to 80.

set tarVSpeed to -5.
for RG in colRG26 { RG:Shutdown. }
set engines to 3.

// until SHIP:altitude < 220 and SHIP:verticalspeed < 0 {
until SHIP:verticalspeed < 0 or SHIP:altitude < 209 {
    write_screen("Descent").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

// Tower Catch
set throttle to 0.
set SHIP:control:top to 0.
set SHIP:control:starboard to 0.
rcs off.

// Disable grid fin control
for GF in colGF{ GF:setfield("pitch", true). }
for GF in colGF{ GF:setfield("yaw", true). }
for GF in colGF{ GF:setfield("roll", true). }

global secStable is 10.
local timStable is time:seconds + secStable.
until time:seconds > timStable { write_screen("stabilising"). }

unlock steering.

sas on.
