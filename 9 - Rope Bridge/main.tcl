namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

# this only sometimes updates the point, while when diag we should always do it.
proc updatePoint {x d} {return [expr {(($d == 2) || ($d == -2)) ? [+ $x [/ $d 2]] : $x}]}
proc moveTail {hx hy tx ty} {
    set dx [- $hx $tx]
    set dy [- $hy $ty]
    if {($hx != $tx) && ($hy != $ty)} {
        if {($dx == 2) || ($dx == -2) ||
            ($dy == 2) || ($dy == -2)} {
                return [list [+ $tx [expr {($dx == 2) || ($dx == -2) ? [/ $dx 2] : $dx}]]\
                             [+ $ty [expr {($dy == 2) || ($dy == -2) ? [/ $dy 2] : $dy}]]]
        }
    }
    return [list [updatePoint $tx $dx] [updatePoint $ty $dy]]
}

proc moveTails {x y acc chain} {
    if {$chain == [list]} {return $acc}
    set updated [moveTail $x $y {*}[lindex $chain 0]]
    return [moveTails {*}$updated [list {*}$acc $updated] [lrange $chain 1 end]]
}

# Make list of knots
set tails [lrepeat 9 [list 0 0]]

# Assign some vars
lassign [list {0 0} {0 0}] hpos tpos
lassign $hpos hx hy


# Start both lists with the start node
set p1_visited [list {0 0}]
set p2_visited [list {0 0}]

set data [readFile [lindex $argv 0]]
foreach line [split $data "\n"] {
    lassign [regexp -inline {(\w)\s(\d+)} $line] -> direction amount
    for {set i 0} {$i != $amount} {incr i} {
        switch -- $direction {
            "R" {set hx [+ $hx 1]}
            "L" {set hx [- $hx 1]}
            "U" {set hy [+ $hy 1]}
            "D" {set hy [- $hy 1]}
        }

        set tails [moveTails $hx $hy [list] $tails]
        lappend p1_visited [lindex $tails 0]
        lappend p2_visited [lindex $tails end]
    }
}
puts "Part1 --[llength [lsort -unique $p1_visited]]--"
puts "Part1 --[llength [lsort -unique $p2_visited]]--"

