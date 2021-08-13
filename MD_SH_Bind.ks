
// Bind to SHIP
set SS to SHIP.

// Bind to main sections
if SS:partstagged("SH_CM"):length = 1 {
    set CM to SS:partstagged("SH_CM")[0].
    // Bind to Module Command
    set CMCMD to CM:getmodule("ModuleCommand").
}
if SS:partstagged("SH_FT"):length = 1 {
    set FT to SS:partstagged("SH_FT")[0].
}

// Bind to Raptor Boost engines
if SS:partstagged("RB01"):length = 1 { set RB01 to SS:partstagged("RB01")[0]. }
if SS:partstagged("RB02"):length = 1 { set RB02 to SS:partstagged("RB02")[0]. }
if SS:partstagged("RB03"):length = 1 { set RB03 to SS:partstagged("RB03")[0]. }
if SS:partstagged("RB04"):length = 1 { set RB04 to SS:partstagged("RB04")[0]. }
if SS:partstagged("RB05"):length = 1 { set RB05 to SS:partstagged("RB05")[0]. }
if SS:partstagged("RB06"):length = 1 { set RB06 to SS:partstagged("RB06")[0]. }
if SS:partstagged("RB07"):length = 1 { set RB07 to SS:partstagged("RB07")[0]. }
if SS:partstagged("RB08"):length = 1 { set RB08 to SS:partstagged("RB08")[0]. }
if SS:partstagged("RB09"):length = 1 { set RB09 to SS:partstagged("RB09")[0]. }
if SS:partstagged("RB10"):length = 1 { set RB10 to SS:partstagged("RB10")[0]. }
if SS:partstagged("RB11"):length = 1 { set RB11 to SS:partstagged("RB11")[0]. }
if SS:partstagged("RB12"):length = 1 { set RB12 to SS:partstagged("RB12")[0]. }
if SS:partstagged("RB13"):length = 1 { set RB13 to SS:partstagged("RB13")[0]. }
if SS:partstagged("RB14"):length = 1 { set RB14 to SS:partstagged("RB14")[0]. }
if SS:partstagged("RB15"):length = 1 { set RB15 to SS:partstagged("RB15")[0]. }
if SS:partstagged("RB16"):length = 1 { set RB16 to SS:partstagged("RB16")[0]. }
if SS:partstagged("RB17"):length = 1 { set RB17 to SS:partstagged("RB17")[0]. }
if SS:partstagged("RB18"):length = 1 { set RB18 to SS:partstagged("RB18")[0]. }
if SS:partstagged("RB19"):length = 1 { set RB19 to SS:partstagged("RB19")[0]. }
if SS:partstagged("RB20"):length = 1 { set RB20 to SS:partstagged("RB20")[0]. }

// Bind to Raptor Gimbal engines
if SS:partstagged("RG01"):length = 1 { set RG01 to SS:partstagged("RG01")[0]. }
if SS:partstagged("RG02"):length = 1 { set RG02 to SS:partstagged("RG02")[0]. }
if SS:partstagged("RG03"):length = 1 { set RG03 to SS:partstagged("RG03")[0]. }
if SS:partstagged("RG04"):length = 1 { set RG04 to SS:partstagged("RG04")[0]. }
if SS:partstagged("RG05"):length = 1 { set RG05 to SS:partstagged("RG05")[0]. }
if SS:partstagged("RG06"):length = 1 { set RG06 to SS:partstagged("RG06")[0]. }
if SS:partstagged("RG07"):length = 1 { set RG07 to SS:partstagged("RG07")[0]. }
if SS:partstagged("RG08"):length = 1 { set RG08 to SS:partstagged("RG08")[0]. }
if SS:partstagged("RG09"):length = 1 { set RG09 to SS:partstagged("RG09")[0]. }

// Bind to grid fins
if SS:partstagged("Grid_FL"):length = 1 {
    set FL to SS:partstagged("Grid_FL")[0].
    set FLCS to FL:getmodule("ModuleControlSurface").
}
if SS:partstagged("Grid_FR"):length = 1 {
    set FR to SS:partstagged("Grid_FR")[0].
    set FRCS to FR:getmodule("ModuleControlSurface").
}
if SS:partstagged("Grid_RL"):length = 1 {
    set RL to SS:partstagged("Grid_RL")[0].
    set RLCS to RL:getmodule("ModuleControlSurface").
}
if SS:partstagged("Grid_RR"):length = 1 {
    set RR to SS:partstagged("Grid_RR")[0].
    set RRCS to RR:getmodule("ModuleControlSurface").
}

