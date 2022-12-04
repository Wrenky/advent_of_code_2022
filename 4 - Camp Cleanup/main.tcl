namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

#################################################
# Read data from file that looks like this:
#   1-2,3-4
#   4-5,6-7
# into a list in the form:
#   { {1 2 3 4} {4 5 6 7}.. {groupN}}
#################################################
set cleanupGroups [lmap line [split [readFile [lindex $argv 0]] "\n"] {
    concat {*}[split [split $line ,] -]
}]
#################################################

#################################################
# Wrapper procs so we can operate as a predicate.
# checkIfContained (group)
#   Compares edges of each group to see if something is "contained" or not.
#
proc checkIfContained {group} {
    proc isContained {a1 a2 b1 b2} {
        # If the starts are the same, its contained.
        if {$a1 == $b1} {return True} 
        # Now we just check the edges that could conflict!
        return [expr {(($a1 < $b1) && ($b2 <= $a2)) ||\
                      (($a1 >= $b1) && ($a2 <= $b2))? True : False}]
    }
    return [isContained {*}$group]
}
# checkIfOverlapped (group)
#   Compares the bottom of A to the top of B, and bottom of B to the top of A.
proc checkIfOverlaped {group} {
    proc isOverlaped {a1 a2 b1 b2} {
        return [expr ($a1 > $b2) || ($b1 > $a2) ? False : True]
    }
    return [isOverlaped {*}$group]
}

puts "Part1: [llength [filter checkIfContained $cleanupGroups]]"
puts "Part2: [llength [filter checkIfOverlaped $cleanupGroups]]"
