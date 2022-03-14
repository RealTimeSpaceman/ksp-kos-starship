
// Kill rcs
set SH:control:pitch to 0.
set SH:control:yaw to 0.
set SH:control:roll to 0.

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

local dstBase is 10000.
// Note the order is important.  set UNLOAD BEFORE LOAD,
// and PACK before UNPACK.  Otherwise the protections in
// place to prevent invalid values will deny your attempt
// to change some of the values:
// In-flight
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO dstBase.
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO dstBase - 500.
WAIT 0.001.
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO dstBase - 1.
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO dstBase - 1000.
WAIT 0.001.

// Parked on the ground:
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNLOAD TO dstBase.
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:LOAD TO dstBase - 500.
WAIT 0.001.
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:PACK TO dstBase - 1.
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNPACK TO dstBase - 1000.
WAIT 0.001.

// Parked in the sea:
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNLOAD TO dstBase.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:LOAD TO dstBase - 500.
WAIT 0.001.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:PACK TO dstBase - 1.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNPACK TO dstBase - 1000.
WAIT 0.001.

// On the launchpad or runway
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNLOAD TO dstBase.
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:LOAD TO dstBase - 500.
WAIT 0.001.
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:PACK TO dstBase - 1.
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNPACK TO dstBase - 1000.
WAIT 0.001.
