
// Set control point to nose
if MODCM:hasevent("control point: docking") {
    MODCM:doevent("control point: docking").
}

// Kill control axes
set SS:control:pitch to 0.
set SS:control:yaw to 0.
set SS:control:roll to 0.

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

// Disable header tanks
set LOXHD:enabled to false.
set CH4HD:enabled to false.

// Turn off rcs and sas
rcs off.
sas off.
