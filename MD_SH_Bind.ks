
// Bind to SHIP
set SH to SHIP.

// Bind to main sections
if SH:partstagged("SH_CM"):length = 1 {
    set CM to SH:partstagged("SH_CM")[0].
    // Bind to Module Command
    set CMCMD to CM:getmodule("ModuleCommand").
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

// Bind to Raptor Boost engines
if SH:partstagged("RB01"):length = 1 { set RB01 to SH:partstagged("RB01")[0]. }
if SH:partstagged("RB02"):length = 1 { set RB02 to SH:partstagged("RB02")[0]. }
if SH:partstagged("RB03"):length = 1 { set RB03 to SH:partstagged("RB03")[0]. }
if SH:partstagged("RB04"):length = 1 { set RB04 to SH:partstagged("RB04")[0]. }
if SH:partstagged("RB05"):length = 1 { set RB05 to SH:partstagged("RB05")[0]. }
if SH:partstagged("RB06"):length = 1 { set RB06 to SH:partstagged("RB06")[0]. }
if SH:partstagged("RB07"):length = 1 { set RB07 to SH:partstagged("RB07")[0]. }
if SH:partstagged("RB08"):length = 1 { set RB08 to SH:partstagged("RB08")[0]. }
if SH:partstagged("RB09"):length = 1 { set RB09 to SH:partstagged("RB09")[0]. }
if SH:partstagged("RB10"):length = 1 { set RB10 to SH:partstagged("RB10")[0]. }
if SH:partstagged("RB11"):length = 1 { set RB11 to SH:partstagged("RB11")[0]. }
if SH:partstagged("RB12"):length = 1 { set RB12 to SH:partstagged("RB12")[0]. }
if SH:partstagged("RB13"):length = 1 { set RB13 to SH:partstagged("RB13")[0]. }
if SH:partstagged("RB14"):length = 1 { set RB14 to SH:partstagged("RB14")[0]. }
if SH:partstagged("RB15"):length = 1 { set RB15 to SH:partstagged("RB15")[0]. }
if SH:partstagged("RB16"):length = 1 { set RB16 to SH:partstagged("RB16")[0]. }
if SH:partstagged("RB17"):length = 1 { set RB17 to SH:partstagged("RB17")[0]. }
if SH:partstagged("RB18"):length = 1 { set RB18 to SH:partstagged("RB18")[0]. }
if SH:partstagged("RB19"):length = 1 { set RB19 to SH:partstagged("RB19")[0]. }
if SH:partstagged("RB20"):length = 1 { set RB20 to SH:partstagged("RB20")[0]. }

// Bind to Raptor Gimbal engines
if SH:partstagged("RG01"):length = 1 { set RG01 to SH:partstagged("RG01")[0]. }
if SH:partstagged("RG02"):length = 1 { set RG02 to SH:partstagged("RG02")[0]. }
if SH:partstagged("RG03"):length = 1 { set RG03 to SH:partstagged("RG03")[0]. }
if SH:partstagged("RG04"):length = 1 { set RG04 to SH:partstagged("RG04")[0]. }
if SH:partstagged("RG05"):length = 1 { set RG05 to SH:partstagged("RG05")[0]. }
if SH:partstagged("RG06"):length = 1 { set RG06 to SH:partstagged("RG06")[0]. }
if SH:partstagged("RG07"):length = 1 { set RG07 to SH:partstagged("RG07")[0]. }
if SH:partstagged("RG08"):length = 1 { set RG08 to SH:partstagged("RG08")[0]. }
if SH:partstagged("RG09"):length = 1 { set RG09 to SH:partstagged("RG09")[0]. }

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

