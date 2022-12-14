namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

# OH GOD
proc parseLine {l} {
    regsub -all "," $l " " l
    regsub -all {\[} $l {[list } l
    set l "set res $l"
    eval $l
    return $res
}

# Both integers: lower should come first. If same, continue.
# Both lists: Compare inner elements. Left runs out first, good.
# integer vs list: Make the int a list.

proc compareLists {one two {tc 0}} {
    foreach a $one b $two {
        if {($a == "") && ($b == "")} {continue}
        if {$a == ""} {
            return True
        }
        if {$b == ""} {
            return False
        }
        # Both integer case
        if {[string is integer $a] && [string is integer $b]} {
            if {$a == $b} {continue}
            if {$a < $b} {
                return True
            }
            return False
        }
        return [compareLists $a $b [+ $tc 1]]
    }
    return False
}

# Just to map it to lsort syntax
proc lsortCmd {a b} {
    set res [compareLists $a $b]
    switch $res {
        True  {return -1}
        False {return 1}
    }
    return 0
}



set index 1
set sum 0
set packetList [list]
set data [readFile [lindex $argv 0]]
foreach {one two _} [split $data "\n"] {
    set one [parseLine $one]
    set two [parseLine $two]
    if {[compareLists $one $two]} {
        set sum [+ $sum $index]
    } 
    incr index
    lappend packetList $one $two
}

puts "Part 1: $sum"
set d1 [list [list 2]]
set d2 [list [list 6]]
lappend packetList $d1 $d2
set sorted [lsort -command lsortCmd $packetList]

set r1 [+ 1 [lsearch -exact $sorted $d1]]
set r2 [+ 1 [lsearch -exact $sorted $d2]]

puts "Part 2: [* $r1 $r2]"
