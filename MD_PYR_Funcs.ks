
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

function heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
    parameter vecT.
    local east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).
    local trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
    local trig_y IS VDOT(east, vecT).
    local result IS ARCTAN2(trig_y, trig_x).
    if result < 0 { return 360 + result. } else { return result. }
}

function relative_bearing {
    parameter headA.
    parameter headB.
    local delta is headB - headA.
    if delta > 180 { return delta - 360. }
    if delta < -180 { return delta + 360. }
    return delta.
}
