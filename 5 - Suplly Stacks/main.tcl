namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

package require struct::matrix

############################################################
# These procedures parse the stack portion into something usable.
# Its hard okay
proc getStackWidth {stack} {
    set endLine [lindex [split $stack "\n"] end]
    return [lindex [regexp -inline {(\d+)\s$} $endLine] 1]
}
proc parseStacks {stack width} {
    # The regexp pattern looks way worse than it is. Its also why we need width
    # First part is either: (3 spaces) OR ([a letter]) followed by a space.
    set pattern [string repeat {(\s\s\s|\[\w\])\s} [- $width 1]]
    append pattern {(\s\s\s|\[\w\])$}

    # Now apply the pattern to each line, getting a list of lines
    set rows [lmap line [split $stack "\n"] {
        set values [regexp -inline $pattern $line]
        if {[lindex $values 1] eq ""} {continue}
        lrange $values 1 end
    }]

    # Remove the outer [] on each element if present, or be empty.
    return [lmap l $rows {
        lmap ele $l {lindex [regexp -inline {(\w)} $ele] 1}
    }]
}
proc buildStacks {stackStr} {

    set rows [parseStacks $stackStr [getStackWidth $stackStr]]

    # Predicate function to check if an element is _not_ empty
    proc notEmpty {e} {return [expr {$e != ""}]}

    # Use the matrix pacakge to transpose the rows. I'm lazy okay
    ::struct::matrix m
    m add columns [+ 1 [llength $rows]]
    foreach r $rows {
        m add row $r
    }
    m transpose

    # Build the stacks dict from the transposed rows
    set stacks [dict create]
    for {set i 0} {$i < [m rows]} {incr i} {
        dict set stacks [+ $i 1] [filter notEmpty [m get row $i]]
    }
    return $stacks
}
############################################################

proc printStacks {stacks} {dict for {k v} $stacks {puts $v}}

############################################################
# These procedures execute the instruction sets, using moveChunk
# to perform the actual move 
proc moveChunk {stacks amount from to} {
    set fromStack [dict get $stacks $from]
    dict set stacks $to [concat [lpop fromStack $amount] [dict get $stacks $to]]
    dict set stacks $from $fromStack
    return $stacks
}
proc applyInstructions {stacks instructions} {
    foreach line [split $instructions "\n"] {
        lassign [regexp -inline {move\s(\d+)\sfrom\s(\d+)\sto\s(\d+)} $line] all move from to
        for {set i 1} {$i <= $move} {incr i} {
            set stacks [moveChunk $stacks 1 $from $to]
        }
    }
    return $stacks
}
proc applyBulkInstructions {stacks instructions} {
    foreach line [split $instructions "\n"] {
        lassign [regexp -inline {move\s(\d+)\sfrom\s(\d+)\sto\s(\d+)} $line] all move from to
        set stacks [moveChunk $stacks $move $from $to]
    }
    return $stacks
}
############################################################

proc collapse {stacks} {
    return [join [lmap l [dict values $stacks] {lindex $l 0}] ""]
}

set data [readFile [lindex $argv 0]]
lassign [regexp -all -inline {^(.*)?\n\n(.*)$} $data] -> stack instructions
set stacks [buildStacks $stack]
puts "Part 1: [collapse [applyInstructions     $stacks $instructions]]"
puts "Part 2: [collapse [applyBulkInstructions $stacks $instructions]]"

