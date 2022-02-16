
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
    print "Engines:      " at (0, 17).
    print "Propellant %: " at (0, 18).

}

function write_screen {

    parameter phase.
    // clearScreen.
    print phase + "                      " at (14, 0).
    // print "----------------------------".
    print round(SHIP:altitude, 0) + "    " at (14, 2).
    // print "----------------------------".
    print round(SHIP:groundspeed, 0) + "    " at (14, 4).
    print round(SHIP:verticalspeed, 0) + "    " at (14, 5).
    print round(SHIP:airspeed, 0) + "    " at (14, 6).
    // print "----------------------------".
    print round(surfDist, 0) + "    " at (14, 8).
    print round(padDist, 3) + "    " at (14, 9).
    // print "----------------------------".
    print round(padBear, 2) + "    " at (14, 11).
    print round(angVector, 2) + "    " at (14, 12).
    print round(tarVAngle, 2) + "    " at (14, 13).
    print round(tarVSpeed, 0) + "    " at (14, 14).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 16).
    print round(engines, 0) + "    " at (14, 17).
    print round(remProp, 2) + "    " at (14, 18).

    local logline is time:seconds + ",".
    set logline to logline + phase + ",".
    set logline to logline + round(SHIP:altitude, 0) + ",".
    set logline to logline + round(SHIP:groundspeed, 0) + ",".
    set logline to logline + round(SHIP:verticalspeed, 2) + ",".
    set logline to logline + round(SHIP:airspeed, 2) + ",".
    set logline to logline + round(surfDist, 0) + ",".
    set logline to logline + round(padDist, 3) + ",".
    set logline to logline + round(padBear, 2) + ",".
    set logline to logline + round(angVector, 2) + ",".
    set logline to logline + round(tarVAngle, 2) + ",".
    set logline to logline + round(tarVSpeed, 2) + ",".
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

// Grid fin group
global colGF is list(FLCS, FRCS, RLCS, RRCS).

// Landing pad
global landingPad is latlng(26.0389495, -97.1522145).
global padEntDir is 256.

// Enable all engine groups
global engines is 29.
ECCT:DoAction("activate engine", true).
wait 0.1.
ECMI:DoAction("activate engine", true).
wait 0.1.
ECAE:DoAction("activate engine", true).

// Track remaining propellant
lock remProp to (FT:Resources[0]:amount / 2268046) * 100.

// Track distance and heading to pad
lock SHHeading to heading_of_vector(SHIP:srfprograde:vector).
lock padDist to landingPad:distance / 1000.
lock padBear to relative_bearing(SHHeading, landingPad:heading).
lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SHIP:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SHIP:geoposition:position)):mag.
lock angVector to 0.
lock tarVAngle to 0.
lock tarVSpeed to 0.

// Write first line of log
deletePath(SH_BB_log.csv).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Altitude,".
set logline to logline + "Horizontal speed,".
set logline to logline + "Vertical speed,".
set logline to logline + "Air speed,".
set logline to logline + "Surface distance,".
set logline to logline + "Pad distance,".
set logline to logline + "Pad bearing,".
set logline to logline + "Vector angle,".
set logline to logline + "Target Vec angle,".
set logline to logline + "Target Vrt speed,".
set logline to logline + "Throttle,".
set logline to logline + "Engines,".
set logline to logline + "Remaining prop".
log logline to SH_BB_log.csv.

write_console().

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

// Enable grid fin control
for GF in colGF{ GF:setfield("pitch", false). }
for GF in colGF{ GF:setfield("yaw", false). }
for GF in colGF{ GF:setfield("roll", false). }

// Ascent
global tarAlt is 190.
set shHeight to 20.
lock altAdj to alt:radar - shHeight.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0001, 1).
set pidThrottle:setpoint to 0.

// Shutdown boost engines
set engines to 9.
ECAE:DoAction("shutdown engine", true).

// Release quick disconnect fuel connections
if QDAA:hasevent("open") { QDAA:doevent("open"). }
if QDBA:hasevent("open") { QDBA:doevent("open"). }

lock steering to up.
lock throttle to 1.
rcs off.

global secEngSpl is 3.
local timEngSpl is time:seconds + secEngSpl.
until time:seconds > timEngSpl { write_screen("Engine spool"). }

stage.

until SHIP:altitude > 185 { write_screen("Ascent"). }

rcs on.

// angVector (scalar) is the angle between the prograde vector and the vector to the landing point - want to minimise this
lock angVector to vAng(srfPrograde:vector, landingPad:position).

// This should bring the vehicle towards the target altitude and have it hover at that alt
lock tarVSpeed to (tarAlt - altAdj) / 5.
lock throttle to max(0.0001, pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed)).

// Shutdown all but 3 gimbal engines
set engines to 3.
ECAE:DoAction("shutdown engine", true).
wait 0.1.
ECMI:DoAction("shutdown engine", true).

// Time to resolve in seconds, maximum of 5
set timeToRes to 0.01 + min(5, surfDist / 20).
// vecThrust is the direction the vehicle should push towards to move the surface velocity vector towards the vector to the landing pad
lock vecThrust to ((vecLndPad / timeToRes) - vecSrfVel).
// What heading should the vehicle thrust towards
lock thrHead to heading_of_vector(vecThrust).

// ******** Hover ********
lock steering to lookdirup(vecThrust + (150 * up:vector), heading(padEntDir, 0):vector).

until surfDist < 25 {
    write_screen("Target CP 1").
    // Assume the ship is facing heading padEntDir as previously commanded, calculate the relative RCS strengths and directions for top (fore) and starboard
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 19).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 20).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 21).
}

set landingPad to latlng(26.0385053, -97.1530816).

// ******** TARGET check point 2 ********
until surfDist < 5 and SHIP:groundspeed < 5 and altAdj < 300 {
    write_screen("Target CP 2").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 19).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 20).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 21).
}

set landingPad to latlng(26.038475, -97.153117).
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

until SHIP:altitude < 240 and abs(SHIP:verticalspeed) < 1 { write_screen("Descent"). }

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

// Geoposition on final catch 1: 26.038489, -97.153189
// Looks like 5-6 decimal places is the most number of useful places

// Geoposition after moving tower closer for the QD connection 26.038478, -97.153140
// Geoposition after moving tower closer for the QD connection 26.038475, -97.153117

// Read up on Boot files to automatically launch the tower script