
//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------

function set_RCSPit {
    // RCS for pitch
    parameter strength.
    set SS:control:pitch to 0.
    if trkPitAng[4] > tarPitAng + 0.5 and trkPitVel[4] > 0 {
        set SS:control:pitch to 0 - strength.
        print "PIT -".
        trkPitRCS:remove(0).
        trkPitRCS:add(-1).
    }
    if trkPitAng[4] < tarPitAng - 0.5 and trkPitVel[4] < 0 {
        set SS:control:pitch to strength.
        print "PIT +".
        trkPitRCS:remove(0).
        trkPitRCS:add(1).
    }
    if SS:control:pitch = 0 {
        trkPitRCS:remove(0).
        trkPitRCS:add(0).
    }
}

function set_RCSYaw {
    // RCS for yaw
    set SS:control:yaw to 0.
    if trkYawAng[4] > 0.5 and trkYawVel[4] > 0 {
        set SS:control:yaw to 0.06.
        print "YAW +".
    }
    if trkYawAng[4] < -0.5 and trkYawVel[4] < 0 {
        set SS:control:yaw to -0.06.
        print "YAW -".
    }
}

function set_RCSRol {
    // RCS for roll
    parameter strength.
    set SS:control:roll to 0.
    if trkRolAng[4] > 0.5 and trkRolVel[4] > 0 {
        set SS:control:roll to strength.
        print "ROL +".
    }
    if trkRolAng[4] < -0.5 and trkRolVel[4] < 0 {
        set SS:control:roll to 0 - strength.
        print "ROL -".
    }
}

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
    print round(SHIP:verticalspeed, 2) + "    " at (14, 5).
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

runOncePath("MD_SS_Bind").
runOncePath("MD_PYR_Funcs").
runPath("MD_Ini_EDL").

//---------------------------------------------------------------------------------------------------------------------
// INITIALISE
//---------------------------------------------------------------------------------------------------------------------

// Set landing target of SpaceX Boca Chica catch tower
global landingPad is latlng(26.0385053, -97.1530816). // Aim point - BC
global padEntDir is 262.

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
lock remProp to 0.

// Set initial global values for the loop
global curPitAng is get_pit(srfprograde).
global curYawAng is get_yawdock(srfretrograde).
global curRolAng is get_rolldock(SS:up).
global curTime is time:seconds.
global csfPitch is 0.
global csfYaw is 0.
global csfRoll is 0.

// Set global lists
global trkStpSec is list(0.01, 0.01, 0.01, 0.01, 0.01).
global trkPitAng is list(curPitAng, curPitAng, curPitAng, curPitAng, curPitAng).
global trkPitVel is list(0, 0, 0, 0, 0).
global trkPitRCS is list(0, 0, 0, 0, 0, 0).
global trkYawAng is list(curYawAng, curYawAng, curYawAng, curYawAng, curYawAng).
global trkYawVel is list(0, 0, 0, 0, 0).
global trkRolAng is list(curRolAng, curRolAng, curRolAng, curRolAng, curRolAng).
global trkRolVel is list(0, 0, 0, 0, 0).
global trkPadAng is list(0, 0, 0, 0, 0).
global trkPadVel is list(0, 0, 0, 0, 0).

global zenRetAng is 90.

// Set starting angle for flaps
global trmIni is 45.

global aeroOn to false.

// PID loop heading
set pidHeading to pidLoop(10, 0.001, 0.001).
set pidHeading:setpoint to 0.

// PID loops phase 2
set pidPit2 to pidLoop(1.5, 0.1, 3).
set pidPit2:setpoint to 0.

set pidYaw2 to pidLoop(3, 0.001, 5).
set pidYaw2:setpoint to 0.

set pidRol2 to pidLoop(2, 0.001, 4).
set pidRol2:setpoint to 0.

// PID loops phase 3
set pidPit3 to pidLoop(0.5, 0.1, 3).
set pidPit3:setpoint to 0.

set pidYaw3 to pidLoop(0.3, 0.001, 0.5, -15, 15).
set pidYaw3:setpoint to 0.

set pidRol3 to pidLoop(0.1, 0.001, 0.3, -15, 15).
set pidRol3:setpoint to 0.

// PID loops phase 4
set pidPit4 to pidLoop(0.35, 0.5, 2).
set pidPit4:setpoint to 0.

set pidYaw4 to pidLoop(0.1, 0.001, 0.3, -15, 15).
set pidYaw4:setpoint to 0.

set pidRol4 to pidLoop(0.1, 0.001, 0.3, -15, 15).
set pidRol4:setpoint to 0.

// PID loops phase 5
set pidPit5 to pidLoop(1.5, 0.1, 3.5).
set pidPit5:setpoint to 0.

set pidYaw5 to pidLoop(1.2, 0.001, 2, -15, 15).
set pidYaw5:setpoint to 0.

set pidRol5 to pidLoop(0.6, 0.1, 1, -15, 15).
set pidRol5:setpoint to 0.

// PID loops phase 6
set pidPit6 to pidLoop(1, 0.1, 3.5).
set pidPit6:setpoint to 0.

set pidYaw6 to pidLoop(1.5, 0.001, 1, -15, 15).
set pidYaw6:setpoint to 0.

set pidRol6 to pidLoop(1, 0.001, 1, -15, 15).
set pidRol6:setpoint to 0.

// Set target values
global tarPitAng to 0.
global tarYawAng to 0.
global tarRolAng to 0.

// Set min/max ranges
global maxPitAng is 80.
global minPitAng is 40.
//global maxYawAng is 15.

// Set phase thresholds
global dpPhase2 is 0.005.
global dpPhase3 is 0.015.
global dpPhase4 is 0.08.

// Set angle thresholds
global angTrnMax is 80.
global angTrnMin is 74.
global angTrnEnd is 30.

// Variables for long range pitch tracking
global lrpTargKM is 12.
// 105 worked for 264 starting mass - 95 worked for 144 starting mass
// Solution is to make lrpConst = (Mass / 12) + 83
global lrpConst is (SS:mass / 12) + 83.
global lrpRatio is 0.000011.
global lrpQRcode is 0. // Temporary value used in the calculation

// Variables for short range pitch tracking - 0.017 works for 211 starting mass - thinking 0.014 for lower mass
//global srpConst is 0.014. // surface KM gained per KM lost in altitude for every degree of pitch forward - original value 0.019
global srpConst is 0.017. // surface KM gained per KM lost in altitude for every degree of pitch forward
global srpTargKM is 0.
//global srpFlrAlt is 1.
global srpFinAlt is 1.2.
global srfDist is 0.

// Variables for propulsive landing
global minThrust is 1500.

rcs on.
sas off.

// Track distance and heading to pad
lock SSHeading to vang(north:vector, SS:srfPrograde:vector).
lock padDist to landingPad:distance / 1000.
lock maxYawAng to min(20, sqrt(padDist)).

// Set initial pitch value
set adjAlt to (SS:altitude / 1000).
set adjKM to (padDist - lrpTargKM).
set adjGS to (SS:velocity:surface:mag / 1000).
set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
set tarPitAng to lrpConst - lrpQRcode.


// Determine aero on or off
if SS:dynamicpressure > dpPhase2 {
    set curPhase to 2.
    set aeroOn to true.
} else {
    set curPhase to 0.
    lock steering to lookdirup(heading(landingPad:heading, tarPitAng):vector, SS:srfRetrograde:vector).
}

// Write first line of log
deletePath(Earth_edl_log).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Dynamic pressure,".
set logline to logline + "Altitude,".
set logline to logline + "Surface speed,".
set logline to logline + "km to target,".
set logline to logline + "Retro Zenith,".
set logline to logline + "Target pitch,".
set logline to logline + "Pitch ang,".
set logline to logline + "Pitch srf,".
set logline to logline + "Target yaw,".
set logline to logline + "Yaw ang,".
set logline to logline + "Yaw srf,".
set logline to logline + "Roll ang,".
set logline to logline + "Roll srf,".
log logline to Earth_edl_log.

//---------------------------------------------------------------------------------------------------------------------
// LOOP
//---------------------------------------------------------------------------------------------------------------------

// Loop for non-thrust controlled section of the descent
until SLRA:thrust > minThrust {

    local oldTime is curTime.
    set curTime to time:seconds.
    trkStpSec:remove(0).
    trkStpSec:add(curTime - oldTime).

    // Calculate angle to zenith
    set zenRetAng to vAng(SS:up:vector, srfRetrograde:vector).

    // Track current pitch/yaw/roll deviation
    trkPitAng:remove(0).
    trkYawAng:remove(0).
    trkRolAng:remove(0).

    trkPitAng:add(get_pit(srfprograde)).
    trkRolAng:add(get_rollnose(srfretrograde)).
    if curPhase < 5 {
        trkYawAng:add(get_yawnose(SS:up)).
    // } else if curPhase = 5 {
    //     trkYawAng:add(landingPad:bearing).
    } else {
        //trkYawAng:add(get_yawnose(SS:north)).
        trkYawAng:add(heading_of_vector(SHIP:facing:vector)).
    }

    // Calculate velocities
    local stpMultip is (1 / (trkStpSec[4] + trkStpSec[3])).
    trkPitVel:remove(0).
    trkPitVel:add((trkPitAng[4] - trkPitAng[2]) * stpMultip).
    trkYawVel:remove(0).
    trkYawVel:add((trkYawAng[4] - trkYawAng[2]) * stpMultip).
    trkRolVel:remove(0).
    trkRolVel:add((trkRolAng[4] - trkRolAng[2]) * stpMultip).

    // Track heading to pad
    trkPadAng:remove(0).
    trkPadAng:add(landingPad:heading - SSHeading).
    trkPadVel:remove(0).
    trkPadVel:add((trkPadAng[4] - trkPadAng[2]) * stpMultip).

    if curPhase < 5 {

        // Set long range pitch tracking
        set adjAlt to (SS:altitude / 1000).
        set adjKM to (padDist - lrpTargKM).
        set adjGS to (SS:velocity:surface:mag / 1000).
        set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
        set tarPitAng to lrpConst - lrpQRcode.
        if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
        if tarPitAng > maxPitAng { set tarPitAng to maxPitAng. }

        if padDist < 60 {
            local tstPitAng is 90 - (((srfDist - srpTargKM) / ((alt:radar / 1000) - srpFinAlt)) / srpConst).
            // if abs(tarPitAng - tstPitAng) < 1 {
            if tstPitAng < tarPitAng {
                set curphase to 5.
                //sas on.
                set tarYawAng to 0.
                set csfPitch to 0.
                set csfYaw to 0.
                set csfRoll to 0.
            }
        }
        
    } else {

        // Set short range pitch tracking
        set srfDist to sqrt(abs(padDist ^ 2 - (alt:radar / 1000) ^ 2)).
        set adjAlt to (alt:radar / 1000) - srpFinAlt.
        set adjKM to (srfDist - srpTargKM).
        //set minPitAng to 90 - zenRetAng.
        //set tarPitAng to max(minPitAng, 90 - ((adjKM / adjAlt) / srpConst)).
        set tarPitAng to 90 - ((adjKM / adjAlt) / srpConst).
        set minPitAng to max(40, 90 - zenRetAng).
        if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
        if tarPitAng > maxPitAng { set tarPitAng to maxPitAng. }
        //if (alt:radar / 1000) < srpFlrAlt { set tarPitAng to 180. }

    }

    // Switch phase

    if curPhase = 0 { // Initial orientation of vehicle
    
        // Calculate stability
        local instability is abs(trkPitAng[4] - tarPitAng) + abs(trkYawAng[4]) + abs(trkRolAng[4]).
        local rotVel is trkPitVel[4] + trkYawVel[4] + trkRolVel[4].

        if instability < 3 and rotVel < 1 {
            unlock steering.
            set curPhase to 1.
        }
    }

    if curPhase = 1 { // low pressure - RCS control - balance fuel

        set_RCSPit(0.1).
        set_RCSYaw().
        set_RCSRol(0.1).
        
        local sumPitRCS is trkPitRCS[3] + trkPitRCS[2] + trkPitRCS[1] + trkPitRCS[0].
        
        if sumPitRCS > 0 {
            set TFOU to transfer("LqdOxygen", CM, SM, 164.948).
            set TFMU to transfer("LqdMethane", CM, SM, 121.650).
            set TFOU:active to true.
            set TFMU:active to true.
        }
        
        if sumPitRCS < 0 {
            set TFOD to transfer("LqdOxygen", SM, CM, 164.948).
            set TFMD to transfer("LqdMethane", SM, CM, 121.650).
            set TFOD:active to true.
            set TFMD:active to true.
        }

        if SS:dynamicpressure > dpPhase2 {
            set curPhase to 2.
            set aeroOn to true.
            set SS:control:pitch to 0.
            set SS:control:yaw to 0.
            set SS:control:roll to 0.
        }
    }

    if curPhase = 2 { // Very high altitude atmospheric re-entry - flaps control
    
        set csfPitch to pidPit2:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw2:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol2:update(time:seconds, trkRolAng[4]).

        if SS:dynamicpressure > dpPhase3 {
            set curPhase to 3.
            rcs off.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
        }
    }

    if curPhase = 3 { // Atmospheric re-entry - flaps control
    
        set csfPitch to pidPit3:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw3:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol3:update(time:seconds, trkRolAng[4]).

        set tarYawAng to pidHeading:update(time:seconds, trkPadAng[4]).
        if tarYawAng > maxYawAng { set tarYawAng to maxYawAng. }
        if abs(tarYawAng) > maxYawAng { set tarYawAng to 0 - maxYawAng. }

        if SS:dynamicpressure > dpPhase4 {
            set curPhase to 4.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
        }

        if zenRetAng < angTrnMin or (zenRetAng < angTrnMax and abs(tarYawAng) = maxYawAng) {
            set curphase to 5.
            //sas on.
            //set tarYawAng to 0.
            set tarPitAng to maxPitAng.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
            lock axsPadZen to vcrs(landingPad:position, SHIP:up:vector).
            lock rotPadDes to angleAxis(180 - tarPitAng - zenRetAng, axsPadZen).
            lock steering to lookdirup(-rotPadDes * up:vector, up:vector).
        }
    }

    if curPhase = 4 { // Max Q - flaps control
    
        set csfPitch to pidPit4:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw4:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol4:update(time:seconds, trkRolAng[4]).

        set tarYawAng to pidHeading:update(time:seconds, trkPadAng[4]).
        if tarYawAng > maxYawAng { set tarYawAng to maxYawAng. }
        if abs(tarYawAng) > maxYawAng { set tarYawAng to 0 - maxYawAng. }

        if zenRetAng < angTrnMin or (zenRetAng < angTrnMax and abs(tarYawAng) = maxYawAng) {
            set curphase to 5.
            //sas on.
            //set tarYawAng to 0.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
            lock axsPadZen to vcrs(landingPad:position, SHIP:up:vector).
            lock rotPadDes to angleAxis(180 - tarPitAng - zenRetAng, axsPadZen).
            lock steering to lookdirup(-rotPadDes * up:vector, up:vector).
        }
    }

    if curPhase = 5 { // Transition from horizontal to vertical - flaps control
    
        set tarYawAng to landingPad:heading.
        
        set csfPitch to pidPit5:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw5:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol5:update(time:seconds, trkRolAng[4]).

        if zenRetAng < angTrnEnd {
            set curphase to 6.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
            //set tarYawAng to get_yawnose(SS:north).
            // lock axsPadZen to vcrs(landingPad:position, SHIP:up:vector).
            // lock rotPadDes to angleAxis(180 - tarPitAng - zenRetAng, axsPadZen).
            // lock steering to lookdirup(-rotPadDes * up:vector, up:vector).
        }
    }

    if curPhase = 6 { // Fall vertical - flaps control

        set tarYawAng to landingPad:heading.
        
        set csfPitch to pidPit6:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw6:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol6:update(time:seconds, trkRolAng[4]).

        // if abs(trkYawAng[4] - tarYawAng) > 10 and zenRetAng < (angTrnEnd - 1) {
        //     // Rescue mode
        //     clearScreen.
        //     print "Rescue mode".
        //     //sas off.
            

        //     rcs on.
        //     local timRescue is time:seconds + 5.
        //     until time:seconds > timRescue {}
        //     unlock axsProZen.
        //     unlock rotProDes.
        //     unlock steering.
        //     rcs off.
        //     //sas on.
        // }

        if (alt:radar / 1000) < srpFinAlt {
            set curphase to 7.
            sas off.
            set csfPitch to 90.
            set csfYaw to 0.
            set csfRoll to 0.
            // Activate engines
            SLRA:activate.
            SLRB:activate.
            SLRC:activate.
            // set throttle and pilot control for flip manoeuvre
            lock throttle to 1.
            rcs on.
            lock steering to SS:up.
        }

    }

    if curPhase = 7 { // Flip - waiting for engine spool up

        set csfPitch to 90.
        // set csfYaw to pidYaw6:update(time:seconds, trkYawAng[4] - tarYawAng).
        // set csfRoll to pidRol5:update(time:seconds, trkRolAng[4]).

    }

    clearScreen.
    print "Phase     " + curPhase.
    print "Aero on   " + aeroOn.
    print "Step secs " + round(trkStpSec[4], 4).
    print "---------".
    print "Dyn press " + round(SS:dynamicpressure, 8).
    print "Srf speed " + round(SS:velocity:surface:mag, 4).
    print "Ret to up " + round(zenRetAng, 4).
    print "---------".
    print "Dist. pad " + round(padDist, 3).
    print "Dist. srf " + round(srfDist, 3).
    print "tarPitAng " + round(tarPitAng, 2).
    print "curPitAng " + round(trkPitAng[4], 4).
    print "csf Pitch " + round(csfPitch, 4).
    print "---------".
    print "Head. pad " + round(trkPadAng[4], 4).
    print "tarYawAng " + round(tarYawAng, 2).
    print "curYawAng " + round(trkYawAng[4], 4).
    print "csf Yaw   " + round(csfYaw, 4).
    print "---------".
    print "tarRolAng " + round(tarRolAng, 2).
    print "curRolAng " + round(trkRolAng[4], 4).
    print "csf Roll  " + round(csfRoll, 4).
    print "---------".

    local logline is time:seconds + ",".
    set logline to logline + curPhase + ",".
    set logline to logline + round(SS:dynamicpressure, 8) + ",".
    set logline to logline + round(SS:altitude, 2) + ",".
    set logline to logline + round(SS:velocity:surface:mag, 4) + ",".
    set logline to logline + round(padDist, 3) + ",".
    set logline to logline + round(zenRetAng, 4) + ",".
    set logline to logline + round(tarPitAng, 4) + ",".
    set logline to logline + round(trkPitAng[4], 4) + ",".
    set logline to logline + round(csfPitch, 4) + ",".
    set logline to logline + round(tarYawAng, 4) + ",".
    set logline to logline + round(trkYawAng[4], 4) + ",".
    set logline to logline + round(csfYaw, 4) + ",".
    set logline to logline + round(trkRolAng[4], 4) + ",".
    set logline to logline + round(csfRoll, 4) + ",".
    log logline to Earth_edl_log.

    // Control surfaces
    // Set flap trims
    local trmFL is trmIni.
    local trmFR is trmIni.
    local trmRL is trmIni.
    local trmRR is trmIni.

    // Combine angles for each flap
    // Set pitch angle
    set trmFL to trmFL - csfPitch.
    set trmFR to trmFR - csfPitch.
    set trmRL to trmRL + csfPitch.
    set trmRR to trmRR + csfPitch.

    // Add yaw angle
    set trmFL to trmFL - csfYaw.
    set trmFR to trmFR + csfYaw.
    set trmRL to trmRL + csfYaw.
    set trmRR to trmRR - csfYaw.

    // Add roll angle
    set trmFL to trmFL + csfRoll.
    set trmFR to trmFR - csfRoll.
    set trmRL to trmRL + csfRoll.
    set trmRR to trmRR - csfRoll.

    if curPhase = 6 {
        // Set control surfaces
        FLCS:setfield("deploy angle", max(trmFL, 20)).
        FRCS:setfield("deploy angle", max(trmFR, 20)).
        RLCS:setfield("deploy angle", max(trmRL, 20)).
        RRCS:setfield("deploy angle", max(trmRR, 20)).
    } else {
        // Set control surfaces
        FLCS:setfield("deploy angle", max(trmFL, 0)).
        FRCS:setfield("deploy angle", max(trmFR, 0)).
        RLCS:setfield("deploy angle", max(trmRL, 0)).
        RRCS:setfield("deploy angle", max(trmRR, 0)).
    }

}

write_console().
set engines to 3.

FLCS:setfield("deploy angle", 0).
FRCS:setfield("deploy angle", 0).
RLCS:setfield("deploy angle", 90).
RRCS:setfield("deploy angle", 90).

// set ssHeight to 40.
// lock altAdj to alt:radar - ssHeight.
lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SS:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SS:geoposition:position)):mag.

global tarAlt is 220.
global maxDflThr is 5.

lock angVector to vAng(srfPrograde:vector, landingPad:position).
lock axsProDes to vcrs(srfPrograde:vector, landingPad:position).
lock rotProDes to angleAxis(max(0 - maxDflThr, angVector * (0 - 8) - 1), axsProDes). // Look to use a pid controller here
lock steering to lookdirup(rotProDes * srfRetrograde:vector, heading(padEntDir, 0):vector).

// ******** LANDING BURN ********
lock tarVSpeed to 0 - (sqrt((alt:radar - tarAlt) / 1000) * 100).

until SHIP:verticalspeed > tarVSpeed { write_screen("Landing burn"). }

// This should bring the vehicle towards the target altitude and have it hover at that alt
set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.
lock throttle to max(0.0001, pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed)).

if SS:mass > 180 {
    // Shutdown 1 engines if mass over 180t
    SLRA:shutdown.
    set engines to 2.
} else {
    // Shutdown 2 engines if mass under 180t
    SLRB:shutdown.
    SLRC:shutdown.
    set engines to 1.
}

until alt:radar < 600 {
    write_screen("Balance throttle").
}
lock tarVSpeed to (tarAlt - alt:radar) / 5.

// Time to resolve in seconds, maximum of 5
set timeToRes to 0.01 + min(5, surfDist / 20).
// vecThrust is the direction the vehicle should push towards to move the surface velocity vector towards the vector to the landing pad
lock vecThrust to ((vecLndPad / timeToRes) - vecSrfVel).
// What heading should the vehicle thrust towards
lock thrHead to heading_of_vector(vecThrust).

lock steering to lookdirup(vecThrust + (150 * up:vector), heading(padEntDir, 0):vector).

// ******** PAD APPROACH ********
until surfDist < 5 and SHIP:groundspeed < 5 and SHIP:altitude < 320 {
    write_screen("Pad approach").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

// global landingPad is latlng(26.0385053, -97.1530816). // Aim point - BC
set landingPad to latlng(26.0384795, -97.1532178).
set tarAlt to 110.

// ******** PAD DESCENT ********
until surfDist < 5 and SHIP:groundspeed < 3 and SHIP:altitude < 300 {
    write_screen("Pad descent").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

// ******** DESCENT ********
lock steering to lookDirUp(up:vector, heading(padEntDir, 0):vector).
set tarAlt to 80.

set tarVSpeed to -5.
set engines to 3.

// until SHIP:altitude < 205 and abs(SHIP:verticalspeed) < 0.1 {
until SHIP:altitude < 205 {
    write_screen("Descent").
    set SHIP:control:top to min(1, vecThrust:mag) * cos(thrHead - padEntDir).
    set SHIP:control:starboard to 0 - min(1, vecThrust:mag) * sin(thrHead - padEntDir).
    print "rcs Mag:      " + round(vecThrust:mag, 3) + "    " at(0, 20).
    print "Fore:         " + round(SHIP:control:top, 3) + "    " at(0, 21).
    print "Star:         " + round(SHIP:control:starboard, 3) + "    " at(0, 22).
}

// ******** TOWER CATCH ********
set throttle to 0.
set SHIP:control:top to 0.
set SHIP:control:starboard to 0.
unlock steering.
rcs off.
SLRA:shutdown.
SLRB:shutdown.
SLRC:shutdown.
write_screen("Tower Catch").





// Old code below

// set altFinal to 15.

// set curPhase to 8.
// //lock steering to srfRetrograde.
// lock steering to lookdirup(vecLndPad + (max(500, surfDist * 5) * up:vector) - (9 * vecSrfVel), SS:facing:topvector).
// lock throttle to 1.
// set tarVSpeed to -10.

// set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
// set pidThrottle:setpoint to 0.

// until surfDist < 30 and SS:bounds:bottomaltradar < 1 {

//     clearScreen.
//     print "Phase     " + curPhase.
//     print "throttle  " + throttle.
//     print "altitude  " + altAdj.
//     print "Vrt speed " + SS:verticalspeed.
//     print "Hrz speed " + SS:velocity:surface:mag.
//     print "surf Dist " + surfDist.

//     if curPhase = 8 {

//         if SS:verticalspeed > tarVSpeed {
//             set curPhase to 9.
//             rcs off.
//             lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), SS:facing:topvector).
//             lock tarVSpeed to 0 - ((altAdj - altFinal) * (SS:velocity:surface:mag / surfDist)).
//             lock throttle to pidThrottle:update(time:seconds, SS:verticalspeed - tarVSpeed).
//             if SS:mass > 180 {
//                 // Shutdown 1 engines if mass over 180t
//                 SLRA:shutdown.
//             } else {
//                 // Shutdown 2 engines if mass under 180t
//                 SLRB:shutdown.
//                 SLRC:shutdown.
//             }
//         }
//     }

//     if curPhase = 9 {

//         if surfDist < 25 and SS:velocity:surface:mag < 4 {
//             set curPhase to 10.
//             lock tarVSpeed to 0 - (altAdj / 5) - 2.
//             gear on.
//         }

//     }

// }

// // Stabilise SS on pad
// SLRA:shutdown.
// SLRB:shutdown.
// SLRC:shutdown.
// rcs on.
// lock steering to up.
// wait 10.
// sas on.
