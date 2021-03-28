
function get_pit {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlPit is vxcl(fcgShip:starvector, rTarget:forevector):normalized.
    local dirPit is vDot(fcgShip:topvector, svlPit).
    local angPit is vAng(fcgShip:forevector, svlPit).

    if dirPit < 0 { return angPit. } else { return (0 - angPit). }
}


// Bind to SHIP
set SS to SHIP.

// Set landing target of SpaceX Boca Chica landing pad
global landingPad is latlng(26.0384, -97.1537).

until false {

    clearScreen.
    print "Pitch " + round(get_pit(SS:up), 4).

}