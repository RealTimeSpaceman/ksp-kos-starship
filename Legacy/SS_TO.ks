
runOncePath("MD_SS_Bind").
runOncePath("MD_PYR_Funcs").

until SHIP:mass < 1000 {
    wait 0.001.
}

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.
VCRA:activate.
VCRB:activate.
VCRC:activate.

set throttle to 1.
lock steering to lookdirup(prograde:vector, heading(0, -90):vector).

