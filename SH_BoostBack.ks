
//---------------------------------------------------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------

function write_screen {

    global curPitAng is get_pit(srfRetrograde).
    global curYawAng is get_yawnose(srfRetrograde).
    global curRolAng is get_rollnose(up).
    global zenRetAng is vAng(up:vector, srfRetrograde:vector).

    parameter phase.
    clearScreen.
    print "Phase:        " + phase.
    print "----------------------------".
    print "Altitude:     " + round(SHIP:altitude / 1000, 0).
    print "----------------------------".
    print "Hrz speed:    " + round(SHIP:velocity:surface:mag, 0).
    print "Vrt speed:    " + round(SHIP:verticalspeed, 0).
    print "Zenith-Retro: " + round(zenRetAng, 2).
    print "----------------------------".
    print "Srf distance: " + round(surfDist / 1000, 2).
    print "Pad distance: " + round(padDist, 2).
    print "Pad heading:  " + round(padHead, 2).
    print "----------------------------".
    print "Pitch (ret):  " + round(curPitAng, 2).
    print "Yaw   (ret):  " + round(curYawAng, 2).
    print "Roll   (up):  " + round(curRolAng, 2).
    print "----------------------------".
    print "Throttle:     " + round(throttle, 2).

    local logline is time:seconds + ",".
    set logline to logline + phase + ",".
    set logline to logline + round(SHIP:altitude / 1000, 0) + ",".
    set logline to logline + round(SHIP:velocity:surface:mag, 0) + ",".
    set logline to logline + round(SHIP:verticalspeed, 0) + ",".
    set logline to logline + round(zenRetAng, 2) + ",".
    set logline to logline + round(surfDist / 1000, 2) + ",".
    set logline to logline + round(padDist, 2) + ",".
    set logline to logline + round(padHead, 2) + ",".
    set logline to logline + round(curPitAng, 2) + ",".
    set logline to logline + round(curYawAng, 2) + ",".
    set logline to logline + round(curRolAng, 2) + ",".
    set logline to logline + round(throttle, 2) + ",".
    log logline to SH_BB_log.

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

// Landing pad - tower crane
global landingPad is latlng(26.035898, -97.149736).

// Track distance and heading to pad
lock SHHeading to vang(north:vector, SHIP:srfPrograde:vector).
lock padDist to landingPad:distance / 1000.
lock padHead to landingPad:heading - SHHeading.
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
set logline to logline + "Pad heading,".
set logline to logline + "Pitch ang,".
set logline to logline + "Yaw ang,".
set logline to logline + "Roll ang,".
log logline to SH_BB_log.

global curPitAng is 0.
global curYawAng is 0.
global curRolAng is 0.

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

if FT:Resources[0]:amount > 400000 {

    until FT:Resources[0]:amount < 400000 {

        write_screen("Ascent").
        print "LqdOxygen:  " + round(FT:Resources[0]:amount, 0).

        wait 0.1.

    }

    // Shutdown engines
    RB01:Shutdown.
    RB02:Shutdown.
    RB03:Shutdown.
    RB04:Shutdown.
    RB05:Shutdown.
    RB06:Shutdown.
    RB07:Shutdown.
    RB08:Shutdown.
    RB09:Shutdown.
    RB10:Shutdown.
    RB11:Shutdown.
    RB12:Shutdown.
    RB13:Shutdown.
    RB14:Shutdown.
    RB15:Shutdown.
    RB16:Shutdown.
    RB17:Shutdown.
    RB18:Shutdown.
    RB19:Shutdown.
    RB20:Shutdown.
    RG01:Shutdown.
    RG02:Shutdown.
    RG03:Shutdown.
    RG04:Shutdown.
    RG05:Shutdown.
    RG06:Shutdown.
    RG07:Shutdown.
    RG08:Shutdown.
    RG09:Shutdown.

    clearScreen.
    print "Stage".

    stage.

    wait 2.

    // Enable manual control
    FLCS:setfield("pitch", false).
    FRCS:setfield("pitch", false).
    RLCS:setfield("pitch", false).
    RRCS:setfield("pitch", false).
    FLCS:setfield("yaw", false).
    FRCS:setfield("yaw", false).
    RLCS:setfield("yaw", false).
    RRCS:setfield("yaw", false).
    FLCS:setfield("roll", false).
    FRCS:setfield("roll", false).
    RLCS:setfield("roll", false).
    RRCS:setfield("roll", false).

    wait 0.1.

    rcs on.
    lock steering to retrograde.

    until get_pit(srfRetrograde) > -10 and get_pit(srfRetrograde) < 10 {

        write_screen("Flip").
        print "LqdOxygen:    " + round(FT:Resources[0]:amount, 0).

        wait 0.1.
    }

    // Activate gimbal engines
    RG01:Activate.
    RG02:Activate.
    RG03:Activate.
    RG04:Activate.
    RG05:Activate.
    RG06:Activate.
    RG07:Activate.
    RG08:Activate.
    RG09:Activate.

    set throttle to 1.

    until SHIP:velocity:surface:mag < 100 {

        write_screen("Boostback").
        print "LqdOxygen:    " + round(FT:Resources[0]:amount, 0).

        wait 0.1.
    }

}

// Post BoostBack
set throttle to 0.

// Shutdown boost engines
RB01:Shutdown.
RB02:Shutdown.
RB03:Shutdown.
RB04:Shutdown.
RB05:Shutdown.
RB06:Shutdown.
RB07:Shutdown.
RB08:Shutdown.
RB09:Shutdown.
RB10:Shutdown.
RB11:Shutdown.
RB12:Shutdown.
RB13:Shutdown.
RB14:Shutdown.
RB15:Shutdown.
RB16:Shutdown.
RB17:Shutdown.
RB18:Shutdown.
RB19:Shutdown.
RB20:Shutdown.

// Activate gimbal engines
RG01:Activate.
RG02:Activate.
RG03:Activate.
RG04:Activate.
RG05:Activate.
RG06:Activate.
RG07:Activate.
RG08:Activate.
RG09:Activate.

// Enable manual control
FLCS:setfield("pitch", false).
FRCS:setfield("pitch", false).
RLCS:setfield("pitch", false).
RRCS:setfield("pitch", false).
FLCS:setfield("yaw", false).
FRCS:setfield("yaw", false).
RLCS:setfield("yaw", false).
RRCS:setfield("yaw", false).
FLCS:setfield("roll", false).
FRCS:setfield("roll", false).
RLCS:setfield("roll", false).
RRCS:setfield("roll", false).

// Variables for long range pitch tracking
global lrpTarDst is 5.
global lrpTarAlt is 16.
global lrpConst is 1.2.
global lrpRatio is 0.0024.

// Triggers for phase change
global altEntBrn is 33000.
global altLndBrn is 2750.
// global altEntBrn is 3.
// global altLndBrn is 2.

rcs off.
sas on.
wait 0.1.
set sasmode to "RETROGRADE".
rcs on.

global secFlip is time:seconds + 9.

until time:seconds > secFlip {

    write_screen("Flip back").

    wait 0.1.

}

local adjDst is ((surfDist / 1000) - lrpTarDst).
local adjAlt is ((SHIP:altitude / 1000) - lrpTarAlt).
local tarPitAng is ((adjAlt / adjDst) - lrpConst) / lrpRatio.

sas off.
rcs on.
lock steering to lookdirup(heading(landingPad:heading + 180, tarPitAng - vAng(up:vector, srfRetrograde:vector)):vector, up:vector).

until SHIP:altitude < altEntBrn {

    set adjDst to ((surfDist / 1000) - lrpTarDst).
    set adjAlt to ((SHIP:altitude / 1000) - lrpTarAlt).
    set tarPitAng to max(60, min(120, ((adjAlt / adjDst) - lrpConst) / lrpRatio)).
    write_screen("Aero guidance").
    print "Target pitch: " + round(tarPitAng, 2).

    wait 0.1.

}

rcs on.
set throttle to 1.

lock steering to lookdirup(heading(landingPad:heading + 180, 90 - vAng(up:vector, srfRetrograde:vector)):vector, up:vector).

global secEntBrn is time:seconds + 10.

until time:seconds > secEntBrn {

    write_screen("Entry burn").

    wait 0.1.

}

set throttle to 0.

until SHIP:altitude < (lrpTarAlt * 1000) {

    write_screen("Re-entry").

    wait 0.1.

}

until SHIP:altitude < altLndBrn {

    write_screen("Final approach").

    wait 0.1.

}

// Propulsive landing
set shHeight to 70.
lock altAdj to alt:radar - shHeight.

set altFinal to 85.

set curPhase to 8.
//lock steering to srfRetrograde.
lock steering to lookdirup(vecLndPad + (max(500, surfDist * 5) * up:vector) - (9 * vecSrfVel), SHIP:facing:topvector).
lock throttle to 1.
set tarVSpeed to -10.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.0000001, 1).
set pidThrottle:setpoint to 0.

until surfDist < 30 and SHIP:bounds:bottomaltradar < 1 {

    clearScreen.
    print "Phase     " + curPhase.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "Vrt speed " + SHIP:verticalspeed.
    print "Hrz speed " + SHIP:velocity:surface:mag.
    print "surf Dist " + surfDist.

    if curPhase = 8 {

        if SHIP:verticalspeed > tarVSpeed {
            set curPhase to 9.
            rcs off.
            lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), SHIP:facing:topvector).
            lock tarVSpeed to 0 - ((altAdj - altFinal) * (SHIP:velocity:surface:mag / surfDist)).
            lock throttle to pidThrottle:update(time:seconds, SHIP:verticalspeed - tarVSpeed).
            RG01:Shutdown.
            RG03:Shutdown.
            RG05:Shutdown.
            RG07:Shutdown.
            RG09:Shutdown.
        }
    }

    if curPhase = 9 {

        if surfDist < 25 and SHIP:velocity:surface:mag < 4 {
            set curPhase to 10.
            lock steering to up.
            lock tarVSpeed to 0.
            gear on.
        }

    }

}


