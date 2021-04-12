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

set curPhase to 1.
set throttle to 1.
set tarVSpeed to 0.
set altFinal to 100.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.4, 1).
set pidThrottle:setpoint to 0.

until surfDist < 10 and altAdj < 1 {

    clearScreen.
    print "Phase     " + curPhase.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "Vrt speed " + SS:verticalspeed.
    print "Hrz speed " + SS:velocity:surface:mag.
    print "surf Dist " + surfDist.

    if curPhase = 1 {

        if alt:radar > 150 {
            set curPhase to 2.
            // SLRA:shutdown.
            lock steering to lookdirup((vecLndPad + max(250, surfDist * 5) * up:vector - 10 * (vecSrfVel)), SS:facing:topvector).
            lock tarVSpeed to 0 - ((altAdj - altFinal) / 5).
            lock throttle to pidThrottle:update(time:seconds, SS:verticalspeed - tarVSpeed).
        }
    }

    if curPhase = 2 {

        if surfDist < 10 and SS:velocity:surface:mag < 1 {
            set curPhase to 3.
            lock tarVSpeed to 0 - (altAdj / 5).
            gear on.
        }

    }

}
