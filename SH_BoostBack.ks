
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
    print round(SHIP:altitude / 1000, 0) + "    " at (14, 2).
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

    // Ascent
    until FT:Resources[0]:amount < 400000 {
        write_screen("Ascent").
        print "LqdOxygen:    " + round(FT:Resources[0]:amount, 0) + "    " at(0, 17).
    }

    // Shutdown engines
    for RB in colRB { RB:Shutdown. }
    for RG in colRG { RG:Shutdown. }

    clearScreen.
    print "Stage".

    stage.

    wait 2.

    clearScreen.
    print "Flip".

    // Enable grid fin control
    for GF in colGF{ GF:setfield("pitch", false). }
    for GF in colGF{ GF:setfield("yaw", false). }
    for GF in colGF{ GF:setfield("roll", false). }

    rcs on.
    set SHIP:control:pitch to 1.
    wait 1.
    set SHIP:control:pitch to 0.
    wait 4.

    write_console().

    local headBB is heading_of_vector(srfRetrograde:vector).
    lock steering to lookdirup(heading(headBB, 0):vector, SHIP:up:inverse:vector).

    until vAng(SHIP:facing:vector, heading(headBB, 0):vector) < 10 { write_screen("Flip"). }

    // Activate gimbal engines
    for RG in colRG { RG:Activate. }

    set throttle to 1.

    until abs(padBear) < 50 { write_screen("Boostback"). }

    // Shutdown 5 gimbal engines
    for RG in colRGOdd { RG:Shutdown. }

    set pidAngle TO pidLoop(10, 0.1, 2, -30, 30).
    set pidAngle:setpoint to 0.

    //lock steering to lookdirup(heading(landingPad:heading + (padBear * 2.5), 0):vector, SHIP:up:inverse:vector).
    lock steering to lookdirup(heading(landingPad:heading - pidAngle:update(time:seconds, padBear), 0):vector, SHIP:up:inverse:vector).
    local overshoot is 1000.
    local timeFall is sqrt((2 * SHIP:apoapsis) / 9.8).
    lock tarSrfVel to (surfDist + overshoot) / (eta:apoapsis + timeFall).

    until SHIP:groundspeed > tarSrfVel {
        write_screen("Target Pad").
        print "tarSrfVel:    " + tarSrfVel + "    " at(0, 17).
    }
    print "                                  " at(0, 17).
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

rcs off.
lock steering to lookdirup(heading(landingPad:heading + 180, 90 - vAng(up:vector, srfRetrograde:vector)):vector, SHIP:up:vector).

until SHIP:altitude < altEntBrn { write_screen("Coast"). }

rcs on.
set throttle to 1.

lock steering to lookdirup(heading(landingPad:heading + 180 - (padBear * 20), 90 - vAng(up:vector, srfRetrograde:vector)):vector, SHIP:up:vector).

global timEntBrn is time:seconds + secEngSpl + secEntBrn.

until time:seconds > timEntBrn { write_screen("Entry burn"). }

set throttle to 0.

lock steering to lookdirup(heading(landingPad:heading + 180, 90 - vAng(up:vector, srfRetrograde:vector)):vector, SHIP:up:vector).

until SHIP:altitude < 16000 { write_screen("Re-entry"). }

global altFinal is 85.
global engAcl is 50.
lock altLndBrn to (0 - SHIP:verticalspeed * secEngSpl) + ((SHIP:verticalspeed * SHIP:verticalspeed) / (2 * engAcl)) + altFinal.

until SHIP:altitude < altLndBrn {

    write_screen("Final approach").
    print "Suicide burn at:" + round(altLndBrn, 2) + "    " at(0, 17).

}
print "                        " at(0, 17).

// Propulsive landing
set shHeight to 70.
lock altAdj to alt:radar - shHeight.

set curPhase to 8.
lock steering to srfRetrograde.
//lock steering to lookdirup(vecLndPad + (max(500, surfDist * 5) * up:vector) - (9 * vecSrfVel), SHIP:facing:topvector).
lock throttle to 1.
set tarVSpeed to -100.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.

until surfDist < 30 and SHIP:bounds:bottomaltradar < 1 {

    write_screen("Landing").

    if curPhase = 8 {

        if SHIP:verticalspeed > tarVSpeed {
            set curPhase to 9.
            //rcs off.
            lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), SHIP:facing:topvector).
            lock tarVSpeed to 0 - ((altAdj - altFinal) * (SHIP:groundspeed / surfDist)).
            lock throttle to pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed).
            for RG in colRGOdd { RG:Shutdown. }
        }
    }

    if curPhase = 9 {

        if surfDist < 25 and SHIP:groundspeed < 4 {
            set curPhase to 10.
            lock steering to up.
            lock tarVSpeed to 0.
            gear on.
        }

    }

}


