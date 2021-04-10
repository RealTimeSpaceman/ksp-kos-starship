
// Bind to SHIP
set SS to SHIP.

// Bind to main sections
if SS:partstagged("SS_CM"):length = 1 {
    set CM to SS:partstagged("SS_CM")[0].
    // Bind to Module Command
    set MODCM to CM:getmodule("ModuleCommand").
    // Bind to header tanks
    set i to 0.
    until i = CM:resources:length {
        if CM:resources[i]:name = "LqdOxygen" {
            set LOXHD to CM:resources[i].
        }
        if CM:resources[i]:name = "LqdMethane" {
            set CH4HD to CM:resources[i].
        }
        set i to i + 1.
    }
}
if SS:partstagged("SS_SM"):length = 1 { set SM to SS:partstagged("SS_SM")[0]. }

// Bind to engines
if SS:partstagged("VacRap_A"):length = 1 { set VCRA to SS:partstagged("VacRap_A")[0]. }
if SS:partstagged("VacRap_B"):length = 1 { set VCRB to SS:partstagged("VacRap_B")[0]. }
if SS:partstagged("VacRap_C"):length = 1 { set VCRC to SS:partstagged("VacRap_C")[0]. }
if SS:partstagged("SLRap_A"):length = 1 { set SLRA to SS:partstagged("SLRap_A")[0]. }
if SS:partstagged("SLRap_B"):length = 1 { set SLRB to SS:partstagged("SLRap_B")[0]. }
if SS:partstagged("SLRap_C"):length = 1 { set SLRC to SS:partstagged("SLRap_C")[0]. }

// Bind to flaps and control surfaces
if SS:partstagged("Fin_FL"):length = 1 {
    set FL to SS:partstagged("Fin_FL")[0].
    set FLCS to FL:getmodule("ModuleControlSurface").
}
if SS:partstagged("Fin_FR"):length = 1 {
    set FR to SS:partstagged("Fin_FR")[0].
    set FRCS to FR:getmodule("ModuleControlSurface").
}
if SS:partstagged("Fin_RL"):length = 1 {
    set RL to SS:partstagged("Fin_RL")[0].
    set RLCS to RL:getmodule("ModuleControlSurface").
}
if SS:partstagged("Fin_RR"):length = 1 {
    set RR to SS:partstagged("Fin_RR")[0].
    set RRCS to RR:getmodule("ModuleControlSurface").
}

