
// Bind to SHIP
set SS to SHIP.

// Bind to chopsticks
if SS:partstagged("CS_L"):length = 1 {
    set CSL to SHIP:partstagged("CS_L")[0].
    set CSLA to CSL:GetModuleByIndex(4).
}
if SS:partstagged("CS_L"):length = 1 {
    set CSR to SHIP:partstagged("CS_L")[0].
    set CSLB to CSL:GetModuleByIndex(4).
}
