namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

# Just calcuate the pixel at cycle and x
proc drawPixel {cycle x} {
    return [expr {($cycle == $x) || 
                  ($cycle == [+ 1 $x]) ||
                  ($cycle == [- $x 1]) ? "#" : "."}]
}


set cycle 0
set x 1
set SignalStrength 0

set rows [list]
set currRow ""
set data [readFile [lindex $argv 0]]
foreach line [split $data "\n"] {
    lassign [split $line] cmd arg

    incr cycle
    append currRow [drawPixel [- [% $cycle 40] 1] $x]
    if {([+ 20 $cycle] % 40) == 0} {
        incr SignalStrength [* $x $cycle]
    }
    if {($cycle % 40) == 0} {
        lappend rows $currRow
        set currRow ""
    }
	
    if {$cmd eq "noop"} {continue}
	# If here, this is an addx 
    
    incr cycle
    append currRow [drawPixel [- [% $cycle 40] 1] $x]
    if {([+ 20 $cycle] % 40) == 0} {
        incr SignalStrength [* $x $cycle]
    }
    if {($cycle % 40) == 0} {
        lappend rows $currRow
        set currRow ""
    }
    incr x $arg
}

puts "Part 1: $SignalStrength"
puts "Part 2: read the letters below:"
foreach row $rows {puts $row}
