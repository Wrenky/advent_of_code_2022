namespace import ::tcl::mathop::*
package require struct::set
source "../utils.tcl"

##
# Asci A == 65
# Asci a == 97.
# To get to 
#   Lowercase item types a through z have priorities 1 through 26.
#   Uppercase item types A through Z have priorities 27 through 52.
proc determinePriority {e} {
    return [expr ($e > 90) ? [- $e 96] : [- $e 38]]
}
# Convert a string into two parts split at index,
#  then turn each part into a list of its characters.
proc spliter {str index} {
	return [lmap e [list [string range $str 0 $index-1] [string range $str $index end]] {split $e ""}]
}

set data [readFile [lindex $argv 0]] 
set shared [lmap line [split $data "\n"] {
    set ele [spliter $line [/ [string length $line] 2]]
    lindex [::struct::set intersect {*}$ele] 0
}]

puts "Part1: [fold 0 + [lmap e $shared {determinePriority [scan $e %c]}]]"

# Data is easier to process now! Just split each group by character and intersect.
set shared [lmap [list uno dos tres] [split $data "\n"] {
    lindex [::struct::set intersect [split $uno ""] [split $dos ""] [split $tres ""]] 0
}]

puts "Part2: [fold 0 + [lmap e $shared {determinePriority [scan $e %c]}]]"

