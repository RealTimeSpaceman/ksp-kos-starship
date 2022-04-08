
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
    print "Throttle:     " at (0, 8).

}

function write_screen {

    parameter phase.
    // clearScreen.
    print phase + "        " at (14, 0).
    // print "----------------------------".
    print round(SHIP:altitude, 0) + "    " at (14, 2).
    // print "----------------------------".
    print round(SHIP:groundspeed, 0) + "    " at (14, 4).
    print round(SHIP:verticalspeed, 0) + "    " at (14, 5).
    print round(SHIP:airspeed, 0) + "    " at (14, 6).
    // print "----------------------------".
    print round(throttle, 2) + "    " at (14, 8).

}

function heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
    parameter vecT.
    local east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).
    local trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
    local trig_y IS VDOT(east, vecT).
    local result IS ARCTAN2(trig_y, trig_x).
    if result < 0 { return 360 + result. } else { return result. }
}

//---------------------------------------------------------------------------------------------------------------------
// SHIP INITIALISE
//---------------------------------------------------------------------------------------------------------------------

runOncePath("MD_SS_Bind").
runOncePath("MD_PYR_Funcs").
runPath("MD_Ini_SS_Launch").

//---------------------------------------------------------------------------------------------------------------------
// SCRIPT INITIALISE
//---------------------------------------------------------------------------------------------------------------------

write_console().

global secEngSpl is 3.

//---------------------------------------------------------------------------------------------------------------------
// MAIN BODY
//---------------------------------------------------------------------------------------------------------------------

until SHIP:partstagged("SH_CM"):length = 0 { write_screen("On booster"). }

set timePause to time:seconds + 4.
until time:seconds > timePause { write_screen("Stage"). }

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.
VCRA:activate.
VCRB:activate.
VCRC:activate.
if SS:partstagged("VacRap_D"):length = 1 { VCRD:activate. }
if SS:partstagged("VacRap_E"):length = 1 { VCRE:activate. }
if SS:partstagged("VacRap_F"):length = 1 { VCRF:activate. }

// set throttle
set throttle to 1.

// Gravity turn
set altPE to 200000.
set altAP to 500000.
lock tarPitAng to max(-2, (1 - (SHIP:apoapsis / (altPE * 0.99)))) * 90.
lock steering to lookDirUp(heading(heading_of_vector(srfPrograde:vector), tarPitAng):vector, up:vector).

until SHIP:altitude > (altPE * 0.98) {
    write_screen("Ascent").
    set navMode to "Surface".
}

lock steering to lookDirUp(heading(heading_of_vector(srfPrograde:vector), 0):vector, up:vector).

until SHIP:apoapsis > (altAP * 0.99) { write_screen("Raise apogee"). }

unlock steering.
set throttle to 0.
sas on.
set navMode to "Surface".
wait 1.
set sasMode to "Prograde".

until eta:apoapsis < secEngSpl { write_screen("Coast to AP"). }

rcs on.
sas off.
lock steering to srfPrograde.
set throttle to 1.

until (SHIP:periapsis + SHIP:apoapsis) > (altAP * 1.99) { write_screen("Circularise"). }
rcs off.
