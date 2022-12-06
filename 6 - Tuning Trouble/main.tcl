namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

# Just iterate over the string, search for unique elements $len long.
#  Each iteration pops an element off the string, checks the next $len, then either
#  repeats or if it finds a match returns the accumulator.
proc find {str len} {
    proc find_off {str len accum} {
        if {[llength [lsort -unique [split [string range $str 0 [- $len 1]] ""]]] == $len} {
            return $accum
        }
        tailcall find_off [string range $str 1 end] $len [+ 1 $accum]
    }
    return [+ $len [find_off $str $len 0]]
}

set data [readFile [lindex $argv 0]]
puts "Part1: [find $data 4]"
puts "Part2: [find $data 14]"
