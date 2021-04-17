runOncePath("MD_Bind").
runOncePath("MD_PYR_Funcs").

until false {
    wait 0.5.
    clearScreen.
    print get_yawnose(SS:north).
}
