
//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------

FUNCTION current_mach_number {
    // from nuggreat
    LOCAL currentPresure IS BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE).
    RETURN CHOOSE SQRT(2 / BODY:ATM:ADIABATICINDEX * SHIP:Q / currentPresure) IF currentPresure > 0 ELSE 0.
}

function get_pit {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlPit is vxcl(fcgShip:starvector, rTarget:forevector):normalized.
    local dirPit is vDot(fcgShip:topvector, svlPit).
    local angPit is vAng(fcgShip:forevector, svlPit).

    if dirPit < 0 { return angPit. } else { return (0 - angPit). }
}

function get_yawdock {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlYaw is vxcl(fcgShip:topvector, rTarget:forevector):normalized.
    local dirYaw is vDot(fcgShip:starvector, svlYaw).
    local angYaw is vAng(fcgShip:forevector, svlYaw).

    if dirYaw < 0 { return angYaw. } else { return (0 - angYaw). }
}

function get_rolldock {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}

function get_yawnose {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlRol is vxcl(fcgShip:topvector, rTarget:forevector):normalized.
    local dirRol is vDot(fcgShip:starvector, svlRol).
    local angRol is vAng(fcgShip:forevector, svlRol).

    if dirRol > 0 { return angRol. } else { return (0 - angRol). }
}

function get_rollnose {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return 0 - arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}

function get_angle {
    parameter dir1, dir2.
    return arcTan2(-vDot(dir1:starvector, dir2:forevector), vDot(dir1:topvector, dir2:forevector)).
}

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
        set SS:control:yaw to -0.06.
        print "YAW -".
    }
    if trkYawAng[4] < -0.5 and trkYawVel[4] < 0 {
        set SS:control:yaw to 0.06.
        print "YAW +".
    }
}

function set_RCSRol {
    // RCS for roll
    parameter strength.
    set SS:control:roll to 0.
    if trkRolAng[4] > 0.5 and trkRolVel[4] > 0 {
        set SS:control:roll to 0 - strength.
        print "ROL -".
    }
    if trkRolAng[4] < -0.5 and trkRolVel[4] < 0 {
        set SS:control:roll to strength.
        print "ROL +".
    }
}

//---------------------------------------------------------------------------------------------------------------------
// SHIP CONTROLS
//---------------------------------------------------------------------------------------------------------------------

// Bind to SHIP
set SS to SHIP.

// Kill rcs
set SS:control:pitch to 0.
set SS:control:yaw to 0.
set SS:control:roll to 0.

// Bind to main sections
set CM to SS:partstagged("SS_CM")[0].
set SM to SS:partstagged("SS_SM")[0].

// Bind to Module Command
set MODCM to CM:getmodule("ModuleCommand").
if MODCM:hasevent("control point: forward") {
    // Control from docking port
    MODCM:doevent("control point: forward").
}

// Bind to engines
set VCRA to SS:partstagged("VacRap_A")[0].
set VCRB to SS:partstagged("VacRap_B")[0].
set VCRC to SS:partstagged("VacRap_C")[0].
set SLRA to SS:partstagged("SLRap_A")[0].
set SLRB to SS:partstagged("SLRap_B")[0].
set SLRC to SS:partstagged("SLRap_C")[0].

// Shutdown engines
VCRA:shutdown.
VCRB:shutdown.
VCRC:shutdown.
SLRA:shutdown.
SLRB:shutdown.
SLRC:shutdown.

// Bind to flaps
set FL to SS:partstagged("Fin_FL")[0].
set FR to SS:partstagged("Fin_FR")[0].
set RL to SS:partstagged("Fin_RL")[0].
set RR to SS:partstagged("Fin_RR")[0].

// Bind to control surfaces
set FLCS to FL:getmodule("ModuleControlSurface").
set FRCS to FR:getmodule("ModuleControlSurface").
set RLCS to RL:getmodule("ModuleControlSurface").
set RRCS to RR:getmodule("ModuleControlSurface").

// Disable manual control
FLCS:setfield("pitch", true).
FRCS:setfield("pitch", true).
RLCS:setfield("pitch", true).
RRCS:setfield("pitch", true).
FLCS:setfield("yaw", true).
FRCS:setfield("yaw", true).
RLCS:setfield("yaw", true).
RRCS:setfield("yaw", true).
FLCS:setfield("roll", true).
FRCS:setfield("roll", true).
RLCS:setfield("roll", true).
RRCS:setfield("roll", true).

// Set starting angles
FLCS:setfield("deploy angle", 0).
FRCS:setfield("deploy angle", 0).
RLCS:setfield("deploy angle", 0).
RRCS:setfield("deploy angle", 0).

// deploy control surfaces
FLCS:setfield("deploy", true).
FRCS:setfield("deploy", true).
RLCS:setfield("deploy", true).
RRCS:setfield("deploy", true).

//---------------------------------------------------------------------------------------------------------------------
// INITIALISE
//---------------------------------------------------------------------------------------------------------------------

// Set landing target of SpaceX Boca Chica landing pad
global landingPad is latlng(26.0384, -97.1537).
global padHeight is 7.

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

global zenRetAng is list(90, 90, 90, 90, 90).

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

set pidYaw3 to pidLoop(0.3, 0.001, 0.5).
set pidYaw3:setpoint to 0.

set pidRol3 to pidLoop(0.1, 0.001, 0.3).
set pidRol3:setpoint to 0.

// PID loops phase 4
set pidPit4 to pidLoop(0.35, 0.5, 2).
set pidPit4:setpoint to 0.

set pidYaw4 to pidLoop(0.1, 0.001, 0.3).
set pidYaw4:setpoint to 0.

set pidRol4 to pidLoop(0.1, 0.001, 0.3).
set pidRol4:setpoint to 0.

// PID loops phase 5
set pidPit5 to pidLoop(0.5, 0.1, 3).
set pidPit5:setpoint to 0.

set pidYaw5 to pidLoop(1.2, 0.001, 2).
set pidYaw5:setpoint to 0.

set pidRol5 to pidLoop(0.6, 0.1, 1).
set pidRol5:setpoint to 0.

// PID loops phase 6
set pidYaw6 to pidLoop(0.1, 0, 0.1).
set pidYaw6:setpoint to 0.

set pidThrt to pidLoop(1, 0.001, 0.001).
set pidThrt:setpoint to 0.

// Set target values
global tarPitAng to 0.
global tarYawAng to 0.
global tarRolAng to 0.

// Set min/max ranges
global maxPitAng is 80.
global minPitAng is 30.
global maxYawAng is 35.

// Set phase thresholds
global dpPhase2 is 0.005.
global dpPhase3 is 0.015.
global dpPhase4 is 0.08.

// Set angle thresholds
global angTrnBeg is 70.
global angTrnEnd is 30.

// Variables for long range pitch tracking
global lrpTargKM is 15.
global lrpConst is 105.
global lrpRatio is 0.000011.
global lrpQRcode is 0. // Temporary value used in the calculation

// Variables for short range pitch tracking
global srpConst is 0.019. // surface KM gained per KM lost in altitude for every degree of pitch forward - starting value 0.019
global srpTargKM is 0.5.
global srpFlrAlt is 1.2.
global srpFinAlt is 1.
global srfDist is 0.

// Variables for propulsive landing
global minThrust is 1500.
global gimPitch is 0.
global gimYaw is 0.

rcs on.
sas off.

// Track distance and heading to pad
lock SSHeading to vang(north:vector, SS:srfPrograde:vector).
lock padDist to landingPad:distance / 1000.

lock axisTarget to SS:up.

// Set initial pitch value
set adjAlt to (SS:altitude / 1000).
set adjKM to (padDist - lrpTargKM).
set adjGS to (SS:velocity:surface:mag / 1000).
set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
set tarPitAng to lrpConst - lrpQRcode.


// Determine aero on or off
if SS:dynamicpressure > dpPhase2 {
    set curPhase to 2.
    MODCM:doevent("control point: docking").
    set aeroOn to true.
} else {
    set curPhase to 0.
    lock steering to srfRetrograde.
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

// Loop for controlled section of the descent
until SLRA:thrust > minThrust {

    local oldTime is curTime.
    set curTime to time:seconds.
    trkStpSec:remove(0).
    trkStpSec:add(curTime - oldTime).

    // Calculate angle to zenith
    zenRetAng:remove(0).
    zenRetAng:add(vAng(SS:up:vector, srfRetrograde:vector)).

    // Track current pitch/yaw/roll deviation
    trkPitAng:remove(0).
    trkYawAng:remove(0).
    trkRolAng:remove(0).
    if MODCM:hasevent("control point: docking") {

        trkPitAng:add(get_pit(srfretrograde)).
        trkYawAng:add(get_yawdock(srfretrograde)).
        trkRolAng:add(get_rolldock(axisTarget)).

    } else {

        trkPitAng:add(get_pit(srfprograde)).
        trkRolAng:add(get_rollnose(srfretrograde)).
        if curPhase >= 5 {
            trkYawAng:add(landingPad:bearing).
        } else {
            trkYawAng:add(get_yawnose(axisTarget)).
        }

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

        // Set pitch for range to pad

        set adjAlt to (SS:altitude / 1000).
        set adjKM to (padDist - lrpTargKM).
        set adjGS to (SS:velocity:surface:mag / 1000).
        set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
        set tarPitAng to lrpConst - lrpQRcode.
        if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
        if tarPitAng > maxPitAng { set tarPitAng to maxPitAng. }
        if MODCM:hasevent("control point: docking") {
            set tarPitAng to 90 - tarPitAng.
        }

    } else {

        // Set pitch for range to pad
        set srfDist to sqrt(padDist ^ 2 - (alt:radar / 1000) ^ 2).
        set adjAlt to (alt:radar / 1000) - srpFinAlt.
        set adjKM to (srfDist - srpTargKM).
        set tarPitAng to 90 - ((adjKM / adjAlt) / srpConst).
        if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
        if (alt:radar / 1000) < srpFlrAlt { set tarPitAng to 180. }

    }

    // Switch phase

    if curPhase = 0 { // Initial orientation of vehicle
    
        // Calculate stability
        local instability is abs(trkPitAng[4]) + abs(trkYawAng[4]) + abs(trkRolAng[4]).
        local rotVel is trkPitVel[4] + trkYawVel[4] + trkRolVel[4].

        if instability < 1 and rotVel < 1 {
            unlock steering.
            set curPhase to 1.
        }
    }

    if curPhase = 1 { // low pressure - RCS control - balance fuel

        set_RCSPit(0.1).
        set_RCSYaw().
        set_RCSRol(0.1).
        
        local sumPitRCS is trkPitRCS[3] + trkPitRCS[2] + trkPitRCS[1] + trkPitRCS[0].
        
        if sumPitRCS < 0 {
            set TFOU to transfer("LqdOxygen", CM, SM, 164.948).
            set TFMU to transfer("LqdMethane", CM, SM, 121.650).
            set TFOU:active to true.
            set TFMU:active to true.
        }
        
        if sumPitRCS > 0 {
            set TFOD to transfer("LqdOxygen", SM, CM, 164.948).
            set TFMD to transfer("LqdMethane", SM, CM, 121.650).
            set TFOD:active to true.
            set TFMD:active to true.
        }

        if SS:dynamicpressure > dpPhase2 {
            set curPhase to 2.
            // Set control point to nose
            MODCM:doevent("control point: docking").
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

        if zenRetAng[4] < angTrnBeg {
            set curphase to 5.
            set tarYawAng to 0.
            set tarPitAng to maxPitAng.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
        }
    }

    if curPhase = 4 { // Max Q - flaps control
    
        set csfPitch to pidPit4:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw4:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol4:update(time:seconds, trkRolAng[4]).

        set tarYawAng to pidHeading:update(time:seconds, trkPadAng[4]).
        if tarYawAng > maxYawAng { set tarYawAng to maxYawAng. }
        if abs(tarYawAng) > maxYawAng { set tarYawAng to 0 - maxYawAng. }

        if zenRetAng[4] < angTrnBeg {
            set curphase to 5.
            set tarYawAng to 0.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
        }
    }

    if curPhase = 5 { // Transition from horizontal to vertical - flaps control
    
        set csfPitch to pidPit5:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw5:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol5:update(time:seconds, trkRolAng[4]).

        if zenRetAng[4] < angTrnEnd {
            set curphase to 6.
            set csfPitch to 0.
            set csfYaw to 0.
            set csfRoll to 0.
        }
    }

    if curPhase = 6 { // Fall vertical - flaps control

        set csfPitch to pidPit5:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw6:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol5:update(time:seconds, trkRolAng[4]).

        if (alt:radar / 1000) < srpFinAlt {
            set curphase to 7.
            set csfPitch to 45.
            set csfYaw to 0.
            set csfRoll to 0.
            // Activate engines
            SLRA:activate.
            SLRB:activate.
            SLRC:activate.
            // set throttle and pilot control for flip manoeuvre
            lock throttle to 1.
            lock steering to SS:up.
        }

    }

    if curPhase = 7 { // Flip - waiting for engine spool up

        set csfPitch to pidPit5:update(time:seconds, trkPitAng[4] - tarPitAng).
        set csfYaw to pidYaw6:update(time:seconds, trkYawAng[4] - tarYawAng).
        set csfRoll to pidRol5:update(time:seconds, trkRolAng[4]).

    }

    clearScreen.
    print "Phase     " + curPhase.
    print "Aero on   " + aeroOn.
    print "Step secs " + round(trkStpSec[4], 4).
    print "---------".
    print "Dyn press " + round(SS:dynamicpressure, 8).
    print "Srf speed " + round(SS:velocity:surface:mag, 4).
    print "Ret to up " + round(zenRetAng[4], 4).
    print "---------".
    print "Dist. pad " + round(padDist, 4).
    print "Dist. srf " + round(srfDist, 4).
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
    set logline to logline + round(padDist, 4) + ",".
    set logline to logline + round(zenRetAng[4], 4) + ",".
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

    // Set control surfaces
    FLCS:setfield("deploy angle", max(trmFL, 0)).
    FRCS:setfield("deploy angle", max(trmFR, 0)).
    RLCS:setfield("deploy angle", max(trmRL, 0)).
    RRCS:setfield("deploy angle", max(trmRR, 0)).

}

set curphase to 8.
// set tarPitAng to zenRetAng[4].
set tarPitAng to 0.
set tarYawAng to 0.

FLCS:setfield("deploy angle", 0).
FRCS:setfield("deploy angle", 0).
RLCS:setfield("deploy angle", 0).
RRCS:setfield("deploy angle", 0).

set tarRolAng to 0 - get_rollnose(north).

// PID loops phase 8
set pidPit8 to pidLoop(0.05, 0, 0.1).
set pidPit8:setpoint to 0.

set pidYaw8 to pidLoop(0.01, 0, 0.1).
set pidYaw8:setpoint to 0.

// PID loops phase 9
set pidPit9 to pidLoop(0.1, 0, 0.1).
set pidPit9:setpoint to 0.

set pidYaw9 to pidLoop(0.1, 0, 0.1).
set pidYaw9:setpoint to 0.

set pidRol9 to pidLoop(0.1, 0, 0.1).
set pidRol9:setpoint to 0.

// PID loops pad bullseye
set pidPitPB to pidLoop(1, 0, 0.1).
set pidPitPB:setpoint to 0.

set pidYawPB to pidLoop(1, 0, 0.1).
set pidYawPB:setpoint to 0.

// Inclination pad bullseye
global altPerSec is 0.66.
global pbConstant is 0.15.
global ssHeight is 38.
global pbImpDist is 0.
global pbTargAlt is 0.
global targDelta is 0.

global curPitDst is 0.
global curYawDst is 0.
global angShpPad is 0.
global trkPitDst is list(curPitDst, curPitDst, curPitDst, curPitDst, curPitDst).
global trkYawDst is list(curYawDst, curYawDst, curYawDst, curYawDst, curYawDst).

// Write first line of burn log
deletePath(Earth_edl_burn_log).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Altitude,".
set logline to logline + "Vertical speed,".
set logline to logline + "Surface speed,".
set logline to logline + "Pitch distance,".
set logline to logline + "Yaw distance,".
set logline to logline + "Target pitch,".
set logline to logline + "Pitch ang,".
set logline to logline + "Pitch gimbal,".
set logline to logline + "Target yaw,".
set logline to logline + "Yaw ang,".
set logline to logline + "Yaw gimbal,".
set logline to logline + "Roll ang,".
log logline to Earth_edl_burn_log.

// Temp fly by wire system
global targAlt is 50.

until padDist < 0.038 {

    local oldTime is curTime.
    set curTime to time:seconds.
    trkStpSec:remove(0).
    trkStpSec:add(curTime - oldTime).

    // Track current pitch/yaw/roll deviation
    trkPitAng:remove(0).
    trkYawAng:remove(0).
    trkRolAng:remove(0).
    trkPitAng:add(get_pit(SS:up)).
    trkYawAng:add(get_yawnose(SS:up)).
    trkRolAng:add(0 - get_rollnose(north)).

    // Track pitch and yaw distances
    set srfDist to 1000 * sqrt((landingPad:lng - SS:geoPosition:lng) ^ 2 + (landingPad:lat - SS:geoposition:lat) ^ 2).
    set angShpPad to landingPad:heading - trkRolAng[4].
    trkPitDst:remove(0).
    trkPitDst:add(srfDist * (cos(angShpPad))).
    trkYawDst:remove(0).
    trkYawDst:add(srfDist * (sin(angShpPad))).

    // Calculate velocities
    local stpMultip is (1 / (trkStpSec[4] + trkStpSec[3])).
    trkPitVel:remove(0).
    trkPitVel:add((trkPitDst[4] - trkPitDst[2]) * stpMultip).
    trkYawVel:remove(0).
    trkYawVel:add((trkYawDst[4] - trkYawDst[2]) * stpMultip).

    // Allow pilot to change target pitch, yaw and roll
    if SS:control:pilottop <> 0 {
        set tarPitAng to tarPitAng + (SS:control:pilotfore * 0.25).
    }
    if SS:control:pilotstarboard <> 0 {
        set tarYawAng to tarYawAng + (SS:control:pilotstarboard * 0.25).
    }
    if SS:control:pilotfore <> 0 {
        set targAlt to targAlt + (SS:control:pilottop * 0.25).
    }

    if curPhase = 8 { // Flip & burn - engine gimbal control

        // set pitch and yaw gimbal
        set gimPitch to pidPit8:update(time:seconds, trkPitAng[4] - tarPitAng).
        set gimYaw to pidYaw8:update(time:seconds, trkYawAng[4] - tarYawAng).

        // Set pilot control according to input
        set SS:control:pitch to gimPitch.
        set SS:control:yaw to 0 - gimYaw.

        if SS:verticalspeed > -6 {
            set curphase to 9.
            set tarRolAng to 0 - get_rollnose(north).
            set thr to max(0.01, pidThrt:update(time:seconds, ((alt:radar - targAlt) / 10) + SS:verticalspeed)).
            lock throttle to thr.
            SLRA:shutdown.
            rcs on.
        }

    }

    if curPhase = 9 { // Soft landing - engine gimbal control

        // Set target angles to reach pad
        // set pbTargAlt to alt:radar - padHeight - ssHeight.
        // set pbSecsRem to pbTargAlt / altPerSec.
        // set pbImpDist to trkPitVel[4] * pbSecsRem - trkPitDst[4].
        // set targDelta to pbImpDist / pbSecsRem.
        // set tarPitAng to targDelta / pbConstant.
        // set pbImpDist to trkYawVel[4] * pbSecsRem - trkYawDst[4].
        // set targDelta to pbImpDist / pbSecsRem.
        // set tarYawAng to targDelta / pbConstant.

        // set pitch and yaw gimbal
        set gimPitch to pidPit9:update(time:seconds, trkPitAng[4] - tarPitAng).
        set gimYaw to pidYaw9:update(time:seconds, trkYawAng[4] - tarYawAng).
        set gimRoll to pidRol9:update(time:seconds, trkRolAng[4] - tarRolAng).

        // Set pilot control according to input
        set SS:control:pitch to gimPitch.
        set SS:control:yaw to 0 - gimYaw.
        set SS:control:roll to gimRoll.

        // Set throttle
        set thr to max(0.01, pidThrt:update(time:seconds, ((alt:radar - 30) / 10) + SS:verticalspeed)).

        if alt:radar < (padHeight + ssHeight) {
            set curPhase to 10.
        }

    }

    if curPhase = 10 {

        // Do stuff?

    }

    clearScreen.
    print "Phase     " + curPhase.
    print "Step secs " + round(trkStpSec[4], 4).
    print "---------".
    print "SS lat    " + round(SS:geoposition:lat, 4).
    print "SS lng    " + round(SS:geoPosition:lng, 4).
    print "LP head   " + round(landingPad:heading, 4).
    print "SS bear   " + round(trkRolAng[4], 4).
    print "---------".
    print "Altitude  " + round(alt:radar, 4).
    print "Targ alt  " + round(targAlt, 2).
    print "Vrt speed " + round(SS:verticalspeed, 4).
    print "srf dist  " + round(srfDist, 4).
    print "---------".
    print "Pit dist  " + round(trkPitDst[4], 4).
    print "Pit vel   " + round(trkPitVel[4], 4).
    print "tarPitAng " + round(tarPitAng, 2).
    print "curPitAng " + round(trkPitAng[4], 4).
    print "gim Pitch " + round(gimPitch, 4).
    print "---------".
    print "Yaw dist  " + round(trkYawDst[4], 4).
    print "Yaw vel   " + round(trkYawVel[4], 4).
    print "tarYawAng " + round(tarYawAng, 2).
    print "curYawAng " + round(trkYawAng[4], 4).
    print "gim Yaw   " + round(gimYaw, 4).
    print "---------".
    print "pad Head  " + round(landingPad:heading, 4).
    print "tarRolAng " + round(tarRolAng, 4).
    print "curRolAng " + round(trkRolAng[4], 4).
    print "---------".

    local logline is time:seconds + ",".
    set logline to logline + curPhase + ",".
    set logline to logline + round(alt:radar, 4) + ",".
    set logline to logline + round(SS:verticalspeed, 4) + ",".
    set logline to logline + round(SS:velocity:surface:mag, 4) + ",".
    set logline to logline + round(trkPitDst[4], 4) + ",".
    set logline to logline + round(trkYawDst[4], 4) + ",".
    set logline to logline + round(tarPitAng, 4) + ",".
    set logline to logline + round(trkPitAng[4], 4) + ",".
    set logline to logline + round(gimPitch, 4) + ",".
    set logline to logline + round(tarYawAng, 4) + ",".
    set logline to logline + round(trkYawAng[4], 4) + ",".
    set logline to logline + round(gimYaw, 4) + ",".
    set logline to logline + round(trkRolAng[4], 4) + ",".
    log logline to Earth_edl_burn_log.

}
