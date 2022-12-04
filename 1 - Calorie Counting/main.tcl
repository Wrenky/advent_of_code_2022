namespace import ::tcl::mathop::*
source "../utils.tcl"

set data [readFile "./input"]
set elfsets [textutil::splitx $data {(?n)^\s*\n}]

proc sumSet s {return [fold 0 + [filter llength [split $s "\n"]]]}
set total [lsort -decreasing -integer [lmap x $elfsets {sumSet $x}]]

puts "Part 1: [lindex $total 0]"
puts "Part 2: [fold 0 + [lrange $total 0 2]]"

