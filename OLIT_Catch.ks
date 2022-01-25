
// Bind to chopsticks
if SHIP:partstagged("CS_L"):length = 1 {
    set CSL to SHIP:partstagged("CS_L")[0].
    set CSLA to CSL:GetModuleByIndex(4).
}
if SHIP:partstagged("CS_R"):length = 1 {
    set CSR to SHIP:partstagged("CS_R")[0].
    set CSLB to CSR:GetModuleByIndex(4).
}

// list targets in targs.
// for targ in targs {
//     if targ:distance < 2500 and targ:altitude > 200 {
//         set catch to targ.
//     }
// }

// until catch:altitude < 225 {
//     clearScreen.
//     print "Target altitude: " + round(catch:altitude, 3).
// }

// clearScreen.
// print "Closing chopsticks".

// CSLA:doevent("toggle").
// CSLB:doevent("toggle").

// local timEngSpl is time:seconds + 8.
// until time:seconds > timEngSpl {}

// clearScreen.
// print "Chopsticks closed".
