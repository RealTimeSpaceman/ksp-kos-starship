
//----------------------------------------------------------------------------------------------------
// FUNCTIONS
//----------------------------------------------------------------------------------------------------

function get_pit {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlPit is vxcl(fcgShip:starvector, rTarget:forevector):normalized.
    local dirPit is vDot(fcgShip:topvector, svlPit).
    local angPit is vAng(fcgShip:forevector, svlPit).

    if dirPit < 0 { return angPit. } else { return (0 - angPit). }
}

function get_yaw {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlRol is vxcl(fcgShip:topvector, rTarget:forevector):normalized.
    local dirRol is vDot(fcgShip:starvector, svlRol).
    local angRol is vAng(fcgShip:forevector, svlRol).

    if dirRol > 0 { return angRol. } else { return (0 - angRol). }
}

function get_roll {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return 0 - arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}

//----------------------------------------------------------------------------------------------------
// BINDINGS
//----------------------------------------------------------------------------------------------------

// Bind to SHIP
set SS to SHIP.

// Bind to main sections
if SS:partstagged("SS_CM"):length = 1 {
    set CM to SS:partstagged("SS_CM")[0].
    // Bind to Module Command
    set CMCMD to CM:getmodule("ModuleCommand").
    set CMRCS to CM:getmodule("ModuleRCSFX").
    // Bind to header tanks
    for rsc in CM:resources {
        if rsc:name = "LqdOxygen" { set LOXHD to rsc. }
        if rsc:name = "LqdMethane" { set CH4HD to rsc. }
    }
}
if SS:partstagged("SS_SM"):length = 1 {
    set SM to SS:partstagged("SS_SM")[0].
    set SMRCS to SM:getmodule("ModuleRCSFX").
}

// Bind to engines
if SS:partstagged("VacRap_A"):length = 1 { set VCRA to SS:partstagged("VacRap_A")[0]. }
if SS:partstagged("VacRap_B"):length = 1 { set VCRB to SS:partstagged("VacRap_B")[0]. }
if SS:partstagged("VacRap_C"):length = 1 { set VCRC to SS:partstagged("VacRap_C")[0]. }
if SS:partstagged("SLRap_A"):length = 1 { set SLRA to SS:partstagged("SLRap_A")[0]. }
if SS:partstagged("SLRap_B"):length = 1 { set SLRB to SS:partstagged("SLRap_B")[0]. }
if SS:partstagged("SLRap_C"):length = 1 { set SLRC to SS:partstagged("SLRap_C")[0]. }

// Bind to flaps and control surfaces
if SS:partstagged("Fin_FL"):length = 1 {
    set FL to SS:partstagged("Fin_FL")[0].
    set FLCS to FL:getmodule("ModuleTundraControlSurface").
}
if SS:partstagged("Fin_FR"):length = 1 {
    set FR to SS:partstagged("Fin_FR")[0].
    set FRCS to FR:getmodule("ModuleTundraControlSurface").
}
if SS:partstagged("Fin_RL"):length = 1 {
    set RL to SS:partstagged("Fin_RL")[0].
    set RLCS to RL:getmodule("ModuleTundraControlSurface").
}
if SS:partstagged("Fin_RR"):length = 1 {
    set RR to SS:partstagged("Fin_RR")[0].
    set RRCS to RR:getmodule("ModuleTundraControlSurface").
}

//----------------------------------------------------------------------------------------------------
// INITIALISE PARTS
//----------------------------------------------------------------------------------------------------

// Set control point to forward and control from here
if CMCMD:hasevent("control point: docking") {
    CMCMD:doevent("control point: docking").
}
CMCMD:doevent("control from here").

// Kill rcs/sas
set SS:control:pitch to 0.
set SS:control:yaw to 0.
set SS:control:roll to 0.
rcs off.
sas off.

// Shutdown engines
VCRA:shutdown.
VCRB:shutdown.
VCRC:shutdown.
SLRA:shutdown.
SLRB:shutdown.
SLRC:shutdown.

// Retract legs
gear off.

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

//----------------------------------------------------------------------------------------------------
// DECLARATIONS
//----------------------------------------------------------------------------------------------------

// Set landing target of SpaceX Boca Chica landing pad
global landingPad is latlng(26.0384, -97.1537).

// Set starting angle for flaps
global trmIni is 45.

// Set target PYR values
global tarPitAng to 0.
global tarYawAng to 0.
global tarRolAng to 0.

// Set min/max ranges
global maxPitAng is 80.
global minPitAng is 30.
global maxYawAng is 35.

// Variables for long range pitch tracking
global lrpTargKM is 15.
global lrpConst is 105.
global lrpRatio is 0.000011.
global lrpQRcode is 0. // Temporary value used in the calculation

// Variables for short range pitch tracking
global srpConst is 0.019. // surface KM gained per KM lost in altitude for every degree of pitch forward - starting value 0.019
global srpTargKM is 0.
global srpFlrAlt is 1.2.
global srpFinAlt is 1.1.
global srfDist is 0.

// Variables for propulsive landing
global minThrust is 1500.

// Track distance and heading to pad, kpa
lock SSHeading to vang(north:vector, SS:srfPrograde:vector).
lock padDist to landingPad:distance / 1000.
lock padHead to (landingPad:heading - SSHeading).
lock kpa to SS:dynamicpressure * Constant:AtmToKPa.

// PID loop heading
set pidHeading to pidLoop(10, 0.001, 0.001).
set pidHeading:setpoint to 0.

// PID loops phase 2
set pidPitA to pidLoop(1.5, 0.1, 3, -30, 30).
set pidPitA:setpoint to 0.

set pidYawA to pidLoop(1.5, 0.01, 5, -40, 40).
set pidYawA:setpoint to 0.

set pidRolA to pidLoop(2, 0.001, 4, -10, 10).
set pidRolA:setpoint to 0.

// Set pressure thresholds
global kpaAeroOn is 1.5.

//---------------------------------------------------------------------------------------------------------------------
// LOOP
//---------------------------------------------------------------------------------------------------------------------

// Set initial global values for the loop
global curPitAng is 0.
global curYawAng is 0.
global curRolAng is 0.
global curTime is 0.
global curStep is 0.
global csfPitch is 0.
global csfYaw is 0.
global csfRoll is 0.

// Loop for controlled section of the descent
rcs on.
until kpa > kpaAeroOn {

    local oldTime is curTime.
    set curTime to time:seconds.
    set curStep to (curTime - oldTime).

    // Get current attitude values
    set curPitAng to get_pit(SS:srfPrograde).
    set curYawAng to get_yaw(SS:up).
    set curRolAng to get_roll(SS:srfRetrograde).

    // Set long range pitch tracking
    set adjAlt to (SS:altitude / 1000).
    set adjKM to (padDist - lrpTargKM).
    set adjGS to (SS:velocity:surface:mag / 1000).
    set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
    set tarPitAng to lrpConst - lrpQRcode.
    if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
    if tarPitAng > maxPitAng { set tarPitAng to maxPitAng. }

    set tarYawAng to pidHeading:update(time:seconds, padHead).
    if tarYawAng > maxYawAng { set tarYawAng to maxYawAng. }
    if tarYawAng < 0 - maxYawAng { set tarYawAng to 0 - maxYawAng. }

    clearScreen.
    print "Dist. pad " + round(padDist, 0).
    print "Head. pad " + round(padHead, 2).
    print "---------".
    print "Prs.(kpa) " + round(kpa, 3).
    print "---------".
    print "tarPitAng " + round(tarPitAng, 2).
    print "curPitAng " + round(curPitAng, 4).
    print "csf Pitch " + round(csfPitch, 4).
    print "---------".
    print "tarYawAng " + round(tarYawAng, 2).
    print "curYawAng " + round(curYawAng, 4).
    print "csf Yaw   " + round(csfYaw, 4).
    print "---------".
    print "tarRolAng " + round(tarRolAng, 2).
    print "curRolAng " + round(curRolAng, 4).
    print "csf Roll  " + round(csfRoll, 4).

    lock steering to lookdirup(heading(landingPad:heading, tarPitAng):vector, SS:srfRetrograde:vector).
}

// unlock steering
unlock steering.

until kpa > 50 {

    local oldTime is curTime.
    set curTime to time:seconds.
    set curStep to (curTime - oldTime).

    // Get current attitude values
    set curPitAng to get_pit(SS:srfPrograde).
    set curYawAng to get_yaw(SS:up).
    set curRolAng to get_roll(SS:srfRetrograde).

    // Set long range pitch tracking
    set adjAlt to (SS:altitude / 1000).
    set adjKM to (padDist - lrpTargKM).
    set adjGS to (SS:velocity:surface:mag / 1000).
    set lrpQRcode to 1000 * ((adjKM / (adjGS * adjAlt * adjAlt)) - (adjKM * lrpRatio)).
    set tarPitAng to lrpConst - lrpQRcode.
    if tarPitAng < minPitAng { set tarPitAng to minPitAng. }
    if tarPitAng > maxPitAng { set tarPitAng to maxPitAng. }

    set tarYawAng to pidHeading:update(time:seconds, padHead).
    if tarYawAng > maxYawAng { set tarYawAng to maxYawAng. }
    if tarYawAng < 0 - maxYawAng { set tarYawAng to 0 - maxYawAng. }

    set csfPitch to pidPitA:update(time:seconds, curPitAng - tarPitAng).
    set csfYaw to pidYawA:update(time:seconds, curYawAng - tarYawAng).
    set csfRoll to pidRolA:update(time:seconds, curRolAng).

    clearScreen.
    print "Dist. pad " + round(padDist, 0).
    print "Head. pad " + round(padHead, 2).
    print "---------".
    print "Prs.(kpa) " + round(kpa, 3).
    print "---------".
    print "tarPitAng " + round(tarPitAng, 2).
    print "curPitAng " + round(curPitAng, 4).
    print "csf Pitch " + round(csfPitch, 4).
    print "---------".
    print "tarYawAng " + round(tarYawAng, 2).
    print "curYawAng " + round(curYawAng, 4).
    print "csf Yaw   " + round(csfYaw, 4).
    print "---------".
    print "tarRolAng " + round(tarRolAng, 2).
    print "curRolAng " + round(curRolAng, 4).
    print "csf Roll  " + round(csfRoll, 4).

    // Control surfaces
    // Set flap trims
    local trmFL is 0.
    local trmFR is 0.
    local trmRL is 0.
    local trmRR is 0.

    // Combine angles for each flap
    // Set pitch angle
    set trmFL to trmFL - csfPitch.
    set trmFR to trmFR - csfPitch.
    set trmRL to trmRL + csfPitch.
    set trmRR to trmRR + csfPitch.

    // Add yaw angle
    set trmFL to trmFL + csfYaw.
    set trmFR to trmFR - csfYaw.
    set trmRL to trmRL - csfYaw.
    set trmRR to trmRR + csfYaw.

    // Add roll angle
    set trmFL to trmFL + csfRoll.
    set trmFR to trmFR - csfRoll.
    set trmRL to trmRL + csfRoll.
    set trmRR to trmRR - csfRoll.

    // set maxDeflect to abs(trmFL).
    // if abs(trmFR) > maxDeflect { set maxDeflect to abs(trmFR). }
    // if abs(trmRL) > maxDeflect { set maxDeflect to abs(trmRL). }
    // if abs(trmRR) > maxDeflect { set maxDeflect to abs(trmRR). }
    // if maxDeflect > trmIni {
    //     set mult to trmIni / maxDeflect.
    //     set trmFL to trmFL * mult.
    //     set trmFR to trmFR * mult.
    //     set trmRL to trmRL * mult.
    //     set trmRR to trmRR * mult.
    // }

    // Set control surfaces
    FLCS:setfield("deploy angle", max(trmFL + trmIni, 0)).
    FRCS:setfield("deploy angle", max(trmFR + trmIni, 0)).
    RLCS:setfield("deploy angle", max(trmRL + trmIni, 0)).
    RRCS:setfield("deploy angle", max(trmRR + trmIni, 0)).

}