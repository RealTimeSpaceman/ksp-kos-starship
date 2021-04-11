
function get_pit {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlPit is vxcl(fcgShip:starvector, rTarget:forevector):normalized.
    local dirPit is vDot(fcgShip:topvector, svlPit).
    local angPit is vAng(fcgShip:forevector, svlPit).

    if dirPit < 0 { return angPit. } else { return (0 - angPit). }
}

function get_yawdock {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlYaw is vxcl(fcgShip:topvector, rTarget:forevector):normalized.
    local dirYaw is vDot(fcgShip:starvector, svlYaw).
    local angYaw is vAng(fcgShip:forevector, svlYaw).

    if dirYaw < 0 { return angYaw. } else { return (0 - angYaw). }
}

function get_rolldock {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}

function get_yawnose {
    parameter rTarget.
    local fcgShip is SHIP:facing.

    local svlRol is vxcl(fcgShip:topvector, rTarget:forevector):normalized.
    local dirRol is vDot(fcgShip:starvector, svlRol).
    local angRol is vAng(fcgShip:forevector, svlRol).

    if dirRol > 0 { return angRol. } else { return (0 - angRol). }
}

function get_rollnose {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return 0 - arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}
