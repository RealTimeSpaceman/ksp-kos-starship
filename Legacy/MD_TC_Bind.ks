
function get_direction {
    parameter rDirection.
    local fcgShip is SHIP:facing.
    return 0 - arcTan2(-vDot(fcgShip:starvector, rDirection:forevector), vDot(fcgShip:topvector, rDirection:forevector)).
}

// Bind to Tower Crane
set TC to SHIP.

// Bind to rotor
if TC:partstagged("Bearing"):length = 1 { set ROTOR to TC:partstagged("Bearing")[0]. }
set RM to ROTOR:getmodule("ModuleIRServo_v3").

set pidRotorVel to pidLoop(100, 0, 20, -200, 200).
set pidRotorVel:setpoint to 0.
global baseSpeed is 0.

global targAng is -140.
global targVel is 0.

// set correct mode and unlock rotor
RM:SetField("mode", 1).
RM:SetField("lock", false).

global curTime is time:seconds.
global trkStpSec is list(0.01, 0.01, 0.01, 0.01, 0.01).
global trkTCAng is list(0, 0, 0, 0, 0).
global trkTCVel is list(0, 0, 0, 0, 0).
trkTCAng:remove(0).
trkTCAng:add(get_direction(north)).

until false {

    local oldTime is curTime.
    set curTime to time:seconds.
    trkStpSec:remove(0).
    trkStpSec:add(curTime - oldTime).

    // Calculate velocity
    local stpMultip is (1 / (trkStpSec[4] + trkStpSec[3] + trkStpSec[2] + trkStpSec[1])).
    trkTCAng:remove(0).
    trkTCAng:add(get_direction(north)).
    trkTCVel:remove(0).
    trkTCVel:add((trkTCAng[4] - trkTCAng[0]) * stpMultip).

    set targVel to 0 - ((trkTCAng[4] - targAng) / 40).

    set baseSpeed to pidRotorVel:update(time:seconds, trkTCVel[4] - targVel).
    if RM:GetField("invert direction") = False and baseSpeed < 0 { RM:SetField("invert direction", True). }
    if RM:GetField("invert direction") = True and baseSpeed > 0 { RM:SetField("invert direction", False). }
    RM:SetField("base speed", abs(baseSpeed)).

    clearScreen.
    print "Step:  " + round(trkStpSec[4], 2).
    print "Angle: " + round(trkTCAng[4], 3).
    print "Veloc: " + round(trkTCVel[4], 3).
    print "Base:  " + round(RM:GetField("base speed"), 2).
    print "Invert:" + RM:GetField("invert direction").
    wait 0.01.

}
