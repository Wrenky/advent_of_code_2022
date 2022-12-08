namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

package require struct::matrix
proc printMatrix {m} {
    for {set i 0} {$i < [$m rows]} {incr i} {
        puts [$m get row $i]
    }
}

#####################################################################
# Process Data into the matrix
#####################################################################
set data [readFile [lindex $argv 0]]
set size [llength [split [lindex [split $data "\n"] 0] ""]]
set m [::struct::matrix]
$m add columns $size
foreach line [split $data "\n"] {$m add row [split $line ""]}
#####################################################################



#####################################################################
# Part1, visibility. Check each element against its row and column.
#####################################################################

proc greaterThanX {x e} {return [expr {($e >= $x)? True : False}]}
proc visible {ele i l} {
    return [expr {([llength [filter [list greaterThanX $ele] [lrange $l 0    $i-1]]] == 0) ||
                  ([llength [filter [list greaterThanX $ele] [lrange $l $i+1 end ]]] == 0) ?
                  True : False}]
}
proc isVisible {matrix ele x y} {
    return [expr {[visible $ele $y [$matrix get column $x]] || 
                  [visible $ele $x [$matrix get row $y]] ?
                   True : False}]
}
#####################################################################



#####################################################################
# Part2, scenicScore.
#####################################################################
proc dist {acc ele l} {
    if {([llength [lrange $l 1 end]] == 0) || ([lindex $l 0] >= $ele)} {return $acc}
    return [dist [+ $acc 1] $ele [lrange $l 1 end]]
}
proc distance {ele i l} {
    # Note the reverse- Thats so we calcuate dist in the correct direction.
    return [list [dist 1 $ele [lreverse [lrange $l    0 $i-1]]]\
                 [dist 1 $ele           [lrange $l $i+1  end]]]
}
proc scenicScore {m ele x y} {
    return [fold 1 * [list {*}[distance $ele $y [$m get column $x]]\
                           {*}[distance $ele $x [$m get    row $y]]]]
}
#####################################################################



#kill me now
set count [* 2 2 [- [$m rows] 1]]
set max 0
for {set x 1} {$x < [$m rows]-1} {incr x} {
    for {set y 1} {$y < [$m columns]-1} {incr y} {
        if {[isVisible $m [$m get cell $x $y] $x $y]} {
            incr count
        }
        set vd [scenicScore $m [$m get cell $x $y] $x $y]
        if {$vd > $max} {
            set max $vd
        }
    }
}
printMatrix $m

puts "Part1: $count"
puts "Part2: $max"

