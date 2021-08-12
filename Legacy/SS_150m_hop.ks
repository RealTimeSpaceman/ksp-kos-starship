// Initialise
runOncePath("lib_navball").
runOncePath("MD_PYR_Funcs").
runOncePath("MD_SS_Bind").
runPath("MD_Ini_SS_Launch").

// Set landing target of SpaceX Boca Chica landing pad
global landingPad is latlng(26.0384, -97.1537).

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

// set throttle
lock throttle to 1.

lock curRolAng to compass_for(SS, SS:facing:topvector:direction).
lock srfDist to sqrt(landingPad:distance ^ 2 - alt:radar ^ 2).
lock ssToPad to landingPad:heading - curRolAng.
lock pitDist to srfDist * cos(ssToPad).
lock yawDist to srfDist * sin(ssToPad).

lock curPitAng to get_pit(SS:up).
lock curYawAng to get_yawnose(SS:up).

lock angCourse to compass_for(SS, srfprograde).
lock ssToCrs to angCourse - curRolAng.
lock curPitVel to groundSpeed * cos(ssToCrs).
lock curYawVel to groundSpeed * sin(ssToCrs).

// PID loop throttle
set pidThrt to pidLoop(0.1, 0, 0.001).
set pidThrt:setpoint to 0.

// PID loop pitch velocity
set pidPitVel to pidLoop(0.1, 0.0001, 0.001).
set pidPitVel:setpoint to 0.

// PID loop pitch angle
set pidPitAng to pidLoop(0.01, 0, 0.001).
set pidPitAng:setpoint to 0.

// PID loop yaw velocity
set pidYawVel to pidLoop(0.1, 0.0001, 0.001).
set pidYawVel:setpoint to 0.

// PID loop yaw
set pidYawAng to pidLoop(0.01, 0, 0.001).
set pidYawAng:setpoint to 0.

// PID loop roll
set pidRoll to pidLoop(0.1, 0.0001, 0.001).
set pidRoll:setpoint to curRolAng.

set curPhase to 1.
set curTime to time:seconds.

// Write first line of 150m hop log
deletePath(SS_150m_hop_log.csv).
local logline is "Time,".
set logline to logline + "Phase,".
set logline to logline + "Throttle,".
set logline to logline + "Altitude,".
set logline to logline + "Vertical speed,".
set logline to logline + "Surface speed,".
set logline to logline + "Pitch distance,".
set logline to logline + "Target pitch vel,".
set logline to logline + "Pitch vel,".
set logline to logline + "Target pitch ang,".
set logline to logline + "Pitch ang,".
set logline to logline + "Yaw distance,".
set logline to logline + "Target yaw vel,".
set logline to logline + "Yaw vel,".
set logline to logline + "Target yaw ang,".
set logline to logline + "Yaw ang,".
set logline to logline + "Roll ang,".
log logline to SS_150m_hop_log.csv.

local tarPitAng is 0.
local tarYawVel is 0.
local tarYawAng is 0.


global thr is 0.4.
until curPhase = 3 {

    local oldTime is curTime.
    set curTime to time:seconds.

    clearScreen.
    print "Step seconds " + round((curTime - oldTime), 4).
    print "Pad heading  " + round(landingPad:heading, 4).
    print "Ship course  " + round(angCourse, 4).
    print "surf speed   " + round(groundSpeed, 4).
    print "pitch speed  " + round(curPitVel, 4).
    print "yaw speed    " + round(curYawVel, 4).
    print "Pit distance " + round(pitDist, 4).
    print "Yaw distance " + round(yawDist, 4).
    print "Ship-pad hdg " + round(ssToPad, 4).
    print "Target roll  " + round(pidRoll:setpoint, 4).
    print "Roll angle   " + round(curRolAng, 4).

    if curPhase = 1 {

        set secRemain to 60 - missionTime.
        set tarPitVel to pitDist / secRemain.

        if alt:radar > 150 {
            set curPhase to 2.
            lock throttle to thr.
        }

    }

    if curPhase = 2 {

        set thr to max(0.4, pidThrt:update(time:seconds, SS:verticalspeed)).

    }

    set SS:control:pitch to pidPitAng:update(time:seconds, curPitAng).
    set SS:control:yaw to 0 - pidYawAng:update(time:seconds, curYawAng).
    set SS:control:roll to 0 - pidRoll:update(time:seconds, curRolAng).

    local logline is time:seconds + ",".
    set logline to logline + curPhase + ",".
    set logline to logline + round(thr, 4) + ",".
    set logline to logline + round(alt:radar, 4) + ",".
    set logline to logline + round(SS:verticalspeed, 4) + ",".
    set logline to logline + round(SS:velocity:surface:mag, 4) + ",".
    set logline to logline + round(pitDist, 4) + ",".
    set logline to logline + round(tarPitVel, 4) + ",".
    set logline to logline + round(curPitVel, 4) + ",".
    set logline to logline + round(tarPitAng, 4) + ",".
    set logline to logline + round(curPitAng, 4) + ",".
    set logline to logline + round(yawDist, 4) + ",".
    set logline to logline + round(tarYawVel, 4) + ",".
    set logline to logline + round(curYawVel, 4) + ",".
    set logline to logline + round(tarYawAng, 4) + ",".
    set logline to logline + round(curYawAng, 4) + ",".
    set logline to logline + round(curRolAng, 4) + ",".
    log logline to SS_150m_hop_log.csv.

}
