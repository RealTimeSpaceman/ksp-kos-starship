runOncePath("MD_SS_Bind").
runPath("MD_Ini_SS_Launch").

// Landing pad - tower crane
global landingPad is latlng(26.035898, -97.149736).

// Activate engines
SLRA:activate.
SLRB:activate.
SLRC:activate.

set ssHeight to 40.
lock altAdj to alt:radar - ssHeight.

lock vecLndPad to vxcl(up:vector, landingPad:position).
lock vecSrfVel to vxcl(up:vector, SS:velocity:surface).
lock surfDist to (vecLndPad - vxcl(up:vector, SS:geoposition:position)):mag.
lock steering to up.

set curPhase to 0.
set throttle to 1.
set tarVSpeed to 0.
set altFinal to 3.

set pidThrottle TO pidLoop(0.7, 0.2, 0, 0.01, 1).
set pidThrottle:setpoint to 0.

until surfDist < 30 and SS:bounds:bottomaltradar < 1 {

    clearScreen.
    print "Phase     " + curPhase.
    print "throttle  " + throttle.
    print "altitude  " + altAdj.
    print "Vrt speed " + SS:verticalspeed.
    print "Hrz speed " + SS:velocity:surface:mag.
    print "surf Dist " + surfDist.

    if curPhase = 0 {

        if altAdj > 3 {
            set curPhase to 1.
            lock steering to lookdirup(vecLndPad + (max(250, surfDist * 5) * up:vector) - (9 * vecSrfVel), SS:facing:topvector).
        }

    }

    if curPhase = 1 {

        if altAdj > 130 {
            set curPhase to 2.
            lock tarVSpeed to 0 - ((altAdj - altFinal) * (SS:velocity:surface:mag / surfDist)).
            lock throttle to pidThrottle:update(time:seconds, SS:verticalspeed - tarVSpeed).
        }
    }

    if curPhase = 2 {

        if surfDist < 15 and SS:velocity:surface:mag < 1 {
            set curPhase to 3.
            lock tarVSpeed to 0 - (altAdj / 5) - 2.
            gear on.
        }

    }

}
