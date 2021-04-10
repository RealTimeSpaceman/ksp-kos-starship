// Initialise
runOncePath("lib_navball").
runOncePath("MD_Bind").
runPath("MD_Ini_SS_Launch").

// Set landing target of SpaceX Boca Chica landing pad
global landingPad is latlng(26.0384, -97.1537).

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

// set throttle and steering
lock throttle to 1.
lock steering to SS:up.

lock angHead to compass_for(SS, SS:facing:topvector:direction).
lock srfDist to sqrt(landingPad:distance ^ 2 - alt:radar ^ 2).
lock ssToPad to landingPad:heading - angHead.
lock pitDist to srfDist * cos(ssToPad).
lock yawDist to srfDist * sin(ssToPad).

// PID loop throttle
set pidThrt to pidLoop(1, 0.001, 0.001).
set pidThrt:setpoint to 0.

// PID loop roll
set pidRoll to pidLoop(0.1, 0.0001, 0.001).
set pidRoll:setpoint to angHead.

set curPhase to 1.

global thr is 0.4.
until curPhase = 3 {

    clearScreen.
    print "Pad heading  " + landingPad:heading.
    print "Pad distance " + srfDist.
    print "Ship-pad hdg " + ssToPad.
    print "Target roll  " + pidRoll:setpoint.
    print "Roll angle   " + angHead.

    set SS:control:roll to 0 - pidRoll:update(time:seconds, angHead).

    if curPhase = 1 and alt:radar > 150 {

        set curPhase to 2.
        lock throttle to thr.

    }

    if curPhase = 2 {

        set thr to max(0.4, pidThrt:update(time:seconds, SS:verticalspeed)).

    }

}
