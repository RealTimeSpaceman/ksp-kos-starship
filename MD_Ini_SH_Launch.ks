
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


// 30 km for in-flight
// Note the order is important.  set UNLOAD BEFORE LOAD,
// and PACK before UNPACK.  Otherwise the protections in
// place to prevent invalid values will deny your attempt
// to change some of the values:
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO 30000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO 29500.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO 29999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO 29000.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"

// 30 km for parked on the ground:
// Note the order is important.  set UNLOAD BEFORE LOAD,
// and PACK before UNPACK.  Otherwise the protections in
// place to prevent invalid values will deny your attempt
// to change some of the values:
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNLOAD TO 30000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:LOAD TO 29500.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:PACK TO 39999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNPACK TO 29000.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"

// 30 km for parked in the sea:
// Note the order is important.  set UNLOAD BEFORE LOAD,
// and PACK before UNPACK.  Otherwise the protections in
// place to prevent invalid values will deny your attempt
// to change some of the values:
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNLOAD TO 30000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:LOAD TO 29500.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:PACK TO 29999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNPACK TO 29000.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"

// 30 km for being on the launchpad or runway
// Note the order is important.  set UNLOAD BEFORE LOAD,
// and PACK before UNPACK.  Otherwise the protections in
// place to prevent invalid values will deny your attempt
// to change some of the values:
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNLOAD TO 30000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:LOAD TO 29500.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:PACK TO 29999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNPACK TO 29000.
WAIT 0.001. // See paragraph above: "wait between load and pack changes"
