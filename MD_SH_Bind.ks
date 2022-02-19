
// Bind to SHIP
set SH to SHIP.

// Bind to main sections
if SH:partstagged("SH_CM"):length = 1 {
    set CM to SH:partstagged("SH_CM")[0].
    // Bind to Module Command
    set CMCMD to CM:getmodule("ModuleCommand").
    set CMDEC to CM:getmodule("ModuleDecouple").
}
if SH:partstagged("SH_FT"):length = 1 {
    set FT to SH:partstagged("SH_FT")[0].
}

// Bind to SuperHeavy Engine cluster
if SH:partstagged("SH_EC"):length = 1 {
    set SHEC to SH:partstagged("SH_EC")[0].
    set ECSW to SHEC:GetModule("ModuleTundraEngineSwitch").
    set ECAE to SHEC:GetModuleByIndex(1).
    set ECMI to SHEC:GetModuleByIndex(2).
    set ECCT to SHEC:GetModuleByIndex(3).
}

// Bind to Orbital Launch Platfom
if SH:partstagged("OLP"):length = 1 {
    set OLP to SH:partstagged("OLP")[0].
    set OPLC to OLP:GetModule("LaunchClamp").
}

// Bind to quick disconnect fuel connections
if SH:partstagged("QDA"):length = 1 {
    set QDA to SH:partstagged("QDA")[0].
    set QDAA to QDA:GetModule("ModuleAnimateGeneric").
}
if SH:partstagged("QDB"):length = 1 {
    set QDB to SH:partstagged("QDB")[0].
    set QDBA to QDB:GetModule("ModuleAnimateGeneric").
}

// Bind to grid fins
if SH:partstagged("Grid_FL"):length = 1 {
    set FL to SH:partstagged("Grid_FL")[0].
    set FLCS to FL:getmodule("ModuleControlSurface").
}
if SH:partstagged("Grid_FR"):length = 1 {
    set FR to SH:partstagged("Grid_FR")[0].
    set FRCS to FR:getmodule("ModuleControlSurface").
}
if SH:partstagged("Grid_RL"):length = 1 {
    set RL to SH:partstagged("Grid_RL")[0].
    set RLCS to RL:getmodule("ModuleControlSurface").
}
if SH:partstagged("Grid_RR"):length = 1 {
    set RR to SH:partstagged("Grid_RR")[0].
    set RRCS to RR:getmodule("ModuleControlSurface").
}

