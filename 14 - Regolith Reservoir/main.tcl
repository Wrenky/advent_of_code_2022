namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"


##########################################################
# Draw the rocks on the passed in matrix!
##########################################################
proc line {a b} {return [expr {$a >= $b ? [range $b [+ $a 1]] : [range $a [+ $b 1]]}]}
proc getPoints {ax ay bx by} {
    return [expr {($ax == $bx) ? 
                [expr {($ay == $by) ? 
                    [list [list $ax $ay]] : 
                    [lmap y [line $ay $by] {list $ax $y}]}] :
                [lmap x [line $ax $bx] {list $x $ay}]}]
}
proc drawRocks {g rockLines} {
    foreach p $rockLines {
        foreach point [getPoints {*}[concat {*}$p]] {
            set g [::matrix::setCell $g {*}$point "#"]
        }
    }
    return $g
}
##########################################################

# Trio of possible next, in the order we parse.
proc next {x y} {return [lmap i [list 0 -1 1] {list [+ $x $i] [+ $y 1]}]}
proc Simulate {g curr} {
    global sandStart

    # Part 1 - Have we fallen into the abyss?
    if {[lindex $curr 1] == [- [lindex [::matrix::size $g] 1] 1]} {return $g}
    foreach p [next {*}$curr] {
        if {[::matrix::getCell $g {*}$p] eq "."} {
            tailcall Simulate $g $p
        }
    }

    # Part 2 - Is the top sand port blocked?
    if {$curr == $sandStart} {return [::matrix::setCell $g {*}$curr "O"]}

    # All blocked! Call on sandstart after drawing curr.
    tailcall Simulate [::matrix::setCell $g {*}$curr "O"] $sandStart
}

##########################################################
# Parse and normalize data
##########################################################
set rockLines [list]
set data [readFile [lindex $argv 0]]
foreach line [split $data "\n"] {
    set l [regexp -all -inline {(\d+,\d+)} $line]
    lappend rockLines [list [lindex $l 0] [lindex $l 1]]
    set prev [lindex $l 1]
    foreach p [lrange $l 2 end] {
        lappend rockLines [list $prev $p]
        set prev $p
    }
}
# Normalize chart, find the furthest left and set that as 0

# Find the furthest down, left and right, then fix them
# Right and left need to be adjust to be closer to 0,0!
#    for left, we are going to use this value to adjust rock points
#    for right, we need to shift it by the left value (to zero it out)
#       and add down for a little space on either side (Diagonols can
#       really screw us up otherwise!
#  as extra room. Ex: if down is 10, left is 400, and right is 500, we set them to
#  down: 10, right 110 left 400 (left gets applied when we build rocklines!
set down        [max [lolcat pair $rockLines {lmap y [split $pair] {lindex [split $y ","] 1}}]]
set left        [min [lolcat pair $rockLines {lmap x [split $pair] {lindex [split $x ","] 0}}]]
set right [+ [- [max [lolcat pair $rockLines {lmap x [split $pair] {lindex [split $x ","] 0}}]] $left] $down]


# build up rocklines! Currently they are a list in the form {x,y x1,y1}..
#   We need it to be in the form {{x y} {x1 y1}}.. so we can draw it easily.
set rockLines [lmap l $rockLines {
    lmap x [split $l] { 
        set p [split $x ,]
        list [+ $down [- [lindex $p 0] $left]] [lindex $p 1]
    }
}]

# if we adjust x, we have to adjust the sandstart
set sandStart [list [+ [- 500 $left] $down] 0]
##########################################################


# Base matrix that we draw rocks onto
set base [lmap i [range [+ $down 1 2]] {lrepeat [+ $right 1 $down] "."}]


# Run Part1
puts "Part 1: [fold 0 + [lmap l [Simulate [drawRocks $base $rockLines] $sandStart] {
     puts "$l"
     llength [lsearch -all -inline -exact $l "O"]
}]]"

# Add a new line along the bottom
lappend rockLines [lolcat {r c} [lmap x [::matrix::size $base] {- $x 1}] {list [list 0 $c] [list $r $c]}]

# Run part 2!
puts "Part 2: [fold 0 + [lmap l [Simulate [drawRocks $base $rockLines] $sandStart] {
     llength [lsearch -all -inline -exact $l "O"]
}]]"
