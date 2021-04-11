runOncePath("MD_Bind").
runPath("MD_Ini_SS_Launch").

global landingPad is latlng(26.0384, -97.1537).

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

set ssHeight to 40.
lock altAdj to alt:radar - ssHeight.

lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SS:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SS:geoposition:position)):mag.
lock steering to lookdirup((vecLndPad + max(250, surfDist * 10) * up:vector - 10 * (vecSrfVel)), SS:facing:topvector).

set throttle to 1.
until alt:radar > 150 {
    clearScreen.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "surf Dist " + surfDist.
}

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.4, 1).
set pidThrottle:setpoint to 0.
lock throttle to pidThrottle:update(time:seconds, SS:verticalspeed).

until surfDist < 10 {
    clearScreen.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "surf Dist " + surfDist.
}

lock throttle to pidThrottle:update(time:seconds, altAdj / 5 + SS:verticalspeed).

until surfDist < 10 and altAdj < 1 {
    clearScreen.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "surf Dist " + surfDist.
}
