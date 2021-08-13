
//---------------------------------------------------------------------------------------------------------------------
// SHIP CONTROLS
//---------------------------------------------------------------------------------------------------------------------

runOncePath("MD_SH_Bind").
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

//---------------------------------------------------------------------------------------------------------------------
// LOOP
//---------------------------------------------------------------------------------------------------------------------

until FT:Resources[0]:amount < 400000 {

    clearScreen.
    print "LqdOxygen:  " + round(FT:Resources[0]:amount, 0).
    print "Pad distance: " + round(padDist, 2).
    print "Pad heading: " + round(padHead, 2).

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

clearScreen.
print "Flip".

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

rcs on.

lock steering to retrograde.

until padHead < 10 {
    wait 0.1.
}

clearScreen.
print "Boostback".

// Activate engines
RB01:Activate.
RB02:Activate.
RB03:Activate.
RB04:Activate.
RB05:Activate.
RB06:Activate.
RB07:Activate.
RB08:Activate.
RB09:Activate.
RB10:Activate.
RB11:Activate.
RB12:Activate.
RB13:Activate.
RB14:Activate.
RB15:Activate.
RB16:Activate.
RB17:Activate.
RB18:Activate.
RB19:Activate.
RB20:Activate.
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
