
// Bind to SHIP
set SS to SHIP.

// Bind to engines
set VCRA to SS:partstagged("VacRap_A")[0].
set VCRB to SS:partstagged("VacRap_B")[0].
set VCRC to SS:partstagged("VacRap_C")[0].
set SLRA to SS:partstagged("SLRap_A")[0].
set SLRB to SS:partstagged("SLRap_B")[0].
set SLRC to SS:partstagged("SLRap_C")[0].

// Shutdown engines
VCRA:shutdown.
VCRB:shutdown.
VCRC:shutdown.
SLRA:shutdown.
SLRB:shutdown.
SLRC:shutdown.

// Activate sea level raptors
SLRA:activate.
SLRB:activate.
SLRC:activate.
