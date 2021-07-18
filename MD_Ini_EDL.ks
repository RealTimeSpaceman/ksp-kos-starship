
// Kill rcs
set SS:control:pitch to 0.
set SS:control:yaw to 0.
set SS:control:roll to 0.

if CMCMD:hasevent("control point: forward") {
    // Control from docking port
    CMCMD:doevent("control point: forward").
}

// Shutdown engines
VCRA:shutdown.
VCRB:shutdown.
VCRC:shutdown.
SLRA:shutdown.
SLRB:shutdown.
SLRC:shutdown.

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
