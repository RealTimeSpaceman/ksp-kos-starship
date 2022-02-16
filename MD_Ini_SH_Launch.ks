
// Kill rcs
set SH:control:pitch to 0.
set SH:control:yaw to 0.
set SH:control:roll to 0.

// // Active SuperHeavy engine cluster
// SHEC:Activate.

// Activate engines
// RB01:Activate.
// RB02:Activate.
// RB03:Activate.
// RB04:Activate.
// RB05:Activate.
// RB06:Activate.
// RB07:Activate.
// RB08:Activate.
// RB09:Activate.
// RB10:Activate.
// RB11:Activate.
// RB12:Activate.
// RB13:Activate.
// RB14:Activate.
// RB15:Activate.
// RB16:Activate.
// RB17:Activate.
// RB18:Activate.
// RB19:Activate.
// RB20:Activate.
// RG01:Activate.
// RG02:Activate.
// RG03:Activate.
// RG04:Activate.
// RG05:Activate.
// RG06:Activate.
// RG07:Activate.
// RG08:Activate.
// RG09:Activate.

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

// Disable RCS and SAS
rcs off.
sas off.

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
