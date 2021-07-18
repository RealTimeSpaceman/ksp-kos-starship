
// Bind to SHIP
set SS to SHIP.

runOncePath("MD_SS_Bind").
runOncePath("MD_PYR_Funcs").
runPath("MD_Ini_SS_Launch").

// Landing pad - central
global landingPad is latlng(26.038420, -97.153676).
lock padDist to landingPad:distance / 1000.

// Mass ratio
global CM2SMRat to 0.55.

// Set target values
global tarPitAng to 0.
global tarYawAng to 0.

// Set target values
global curPitAng to 0.
global curYawAng to 0.
global curRolAng to 0.

// Variables for propulsive landing
global minThrust is 1500.

// Variables for short range pitch tracking
global srpConst is 0.019. // surface KM gained per KM lost in altitude for every degree of pitch forward - starting value 0.019
global srpTargKM is 0.
global srpFlrAlt is 0.9.
global srpFinAlt is 0.8.
global srfDist is 0.
global srfPhase is 0.5.

// PID loops phase 5
set pidPit5 to pidLoop(0.5, 0.1, 3, -30, 30).
set pidPit5:setpoint to 0.

set pidYaw5 to pidLoop(0.1, 0, 0.1, -10, 10).
set pidYaw5:setpoint to 0.

set pidRol5 to pidLoop(0.6, 0.1, 1, -5, 5).
set pidRol5:setpoint to 0.

// PID loops phase 6
set pidYaw6 to pidLoop(0.1, 0, 0.1, -10, 10).
set pidYaw6:setpoint to 0.

// Control surface values
global csfPitch is 0.
global csfYaw is 0.
global csfRoll is 0.

// Set starting angle for flaps
global trmIni is 45.

// loack variables
lock zenRetAng to vAng(SS:up:vector, srfRetrograde:vector).
lock SSHeading to vang(north:vector, SS:srfPrograde:vector).

set ssHeight to 40.
lock altAdj to alt:radar - ssHeight.
lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SS:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SS:geoposition:position)):mag.

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

// Go up!
lock steering to lookdirup(SS:up:vector, (0 - 1) * vecLndPad).
lock throttle to 0.51.

until alt:radar > 6000 {
    wait 0.5.
}

SLRC:shutdown.
lock throttle to 0.4.
rcs on.

until alt:radar > 10000 {
    wait 0.5.
}

SLRB:shutdown.
lock throttle to 0.2.

until alt:radar > 12000 {
    wait 0.5.
}

SLRA:shutdown.
lock steering to lookDirUp(vecLndPad, SS:up:vector).

// Enable header tanks
set LOXHD:enabled to true.
set CH4HD:enabled to true.

until CM:Mass / SM:Mass < CM2SMRat or CH4HD:amount = 0 {
    set TFOU to transfer("LqdOxygen", CM, SM, 164.948).
    set TFMU to transfer("LqdMethane", CM, SM, 121.650).
    set TFOU:active to true.
    set TFMU:active to true.
}

until zenRetAng < 20 {
    wait 0.5.
}

rcs off.
wait 0.5.

set SS:control:pitch to 0.
set curPhase to 4.

until SLRA:thrust > minThrust {

    if curPhase = 4 {
        set curPitAng to 0 - get_pit(SS:up).
    } else {
        set curPitAng to get_pit(srfprograde).
        // set curPitAng to get_pit(SS:up).
    }
    
    set curRolAng to get_rollnose(srfretrograde).

    if srfDist > srfPhase {
        set curYawAng to landingPad:bearing.
        // set curYawAng to get_yawnose(SS:north).
    } else {
        set curYawAng to get_yawnose(SS:north).
    }

    // Set short range pitch tracking
    set srfDist to sqrt(abs(padDist ^ 2 - (alt:radar / 1000) ^ 2)).
    set adjAlt to (alt:radar / 1000) - srpFinAlt.
    set adjKM to (srfDist - srpTargKM).
    set minPitAng to 90 - zenRetAng.
    set tarPitAng to max(minPitAng, 90 - ((adjKM / adjAlt) / srpConst)).
    if (alt:radar / 1000) < srpFlrAlt { set tarPitAng to 180. }

    if curPhase = 4 { // stable horizontal attitude

        set csfPitch to pidPit5:update(time:seconds, curPitAng - 90).
        // set csfYaw to pidYaw5:update(time:seconds, curYawAng).
        set csfRoll to pidRol5:update(time:seconds, curRolAng).

        if zenRetAng < 20 {
            set curPhase to 5.
            set tarYawAng to get_yawnose(SS:north).
        }

    }

    if curPhase = 5 { // Transition from horizontal to vertical - flaps control
    
        set csfPitch to pidPit5:update(time:seconds, curPitAng - tarPitAng).
        // set csfYaw to pidYaw5:update(time:seconds, curYawAng - tarYawAng).
        // set csfRoll to pidRol5:update(time:seconds, curRolAng).

        if srfDist <= srfPhase {
            set curphase to 6.
            set tarYawAng to get_yawnose(SS:north).
        }
    }

    if curPhase = 6 { // Fall vertical - flaps control

        set csfPitch to pidPit5:update(time:seconds, curPitAng - 90).
        set csfYaw to pidYaw6:update(time:seconds, curYawAng - tarYawAng).
        set csfRoll to pidRol5:update(time:seconds, curRolAng).

        if (alt:radar / 1000) < srpFinAlt {
            set curphase to 7.
            set csfPitch to 45.
            set csfYaw to 0.
            set csfRoll to 0.
            // Activate engines
            SLRA:activate.
            SLRB:activate.
            SLRC:activate.
            // lock throttle and pilot control for flip manoeuvre
            lock throttle to 1.
            rcs on.
            lock steering to SS:up.
        }

    }

    if curPhase = 7 { // Flip - waiting for engine spool up

        set csfPitch to pidPit5:update(time:seconds, curPitAng - tarPitAng).
        set csfYaw to pidYaw6:update(time:seconds, curYawAng - tarYawAng).

    }

    clearScreen.
    print "Phase     " + curPhase.
    print "---------".
    print "Srf speed " + round(SS:velocity:surface:mag, 4).
    print "Ret to up " + round(zenRetAng, 4).
    print "---------".
    print "Dist. pad " + round(padDist, 4).
    print "Dist. srf " + round(srfDist, 4).
    print "tarPitAng " + round(tarPitAng, 2).
    print "curPitAng " + round(curPitAng, 4).
    print "csf Pitch " + round(csfPitch, 4).
    print "---------".
    print "Head. pad " + round(landingPad:heading - SSHeading, 4).
    print "tarYawAng " + round(tarYawAng, 2).
    print "curYawAng " + round(curYawAng, 4).
    print "csf Yaw   " + round(csfYaw, 4).
    print "---------".
    print "curRolAng " + round(curRolAng, 4).
    print "csf Roll  " + round(csfRoll, 4).
    print "---------".

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
    FLCS:setfield("deploy angle", min(0 - trmFL, 0)).
    FRCS:setfield("deploy angle", min(0 - trmFR, 0)).
    RLCS:setfield("deploy angle", min(0 - trmRL, 0)).
    RRCS:setfield("deploy angle", min(0 - trmRR, 0)).

}

FLCS:setfield("deploy angle", 0).
FRCS:setfield("deploy angle", 0).
RLCS:setfield("deploy angle", 0).
RRCS:setfield("deploy angle", 0).

set altFinal to 15.

// Enable header tanks
set LOXHD:enabled to true.
set CH4HD:enabled to true.

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

set curPhase to 8.
lock steering to srfRetrograde.
lock throttle to 1.
set tarVSpeed to -40.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.01, 1).
set pidThrottle:setpoint to 0.

until surfDist < 30 and SS:bounds:bottomaltradar < 1 {

    clearScreen.
    print "Phase     " + curPhase.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "Vrt speed " + SS:verticalspeed.
    print "Hrz speed " + SS:velocity:surface:mag.
    print "surf Dist " + surfDist.

    if curPhase = 8 {

        if SS:verticalspeed > tarVSpeed {
            set curPhase to 9.
            rcs off.
            lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), SS:facing:topvector).
            lock tarVSpeed to 0 - ((altAdj - altFinal) * (SS:velocity:surface:mag / surfDist)).
            lock throttle to pidThrottle:update(time:seconds, SS:verticalspeed - tarVSpeed).
        }
    }

    if curPhase = 9 {

        if surfDist < 15 and SS:velocity:surface:mag < 1 {
            set curPhase to 10.
            lock tarVSpeed to 0 - (altAdj / 5) - 2.
            gear on.
        }

    }

}
