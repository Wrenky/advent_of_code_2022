namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

package require csv
package require struct::matrix

#################################################
##  Get the data in two lists. U G L Y
#  Using the csv/matrix parsing so I dont have to think about it
#################################################
::struct::matrix data
set chan [open [lindex $argv 0]] 
csv::read2matrix $chan data " " auto 
close $chan
set elfPlay [data get column 0]
set myPlay  [data get column 1]


#################################################


#################################################
## Part 1
#################################################
# Score map!
set scores [dict create\
    X 1 Y 2 Z 3\
    A 1 B 2 C 3\
]

## 
# Use the absolute relation between 3-2-1 r-p-s to figure it out.
#  abs (Elf - me) determines if we draw/lose/win
# If the relation is equal         (0 case), its a draw.
# If the relation is consecutive   (1 case), its a loss if elf is larger.
# If the relation is !consecutive, (2 case)  its a loss if elf is smaller
# Result = (Loss = 0, Draw = 3, Win = 6) + the value of my sign ($me)
proc matchPoints {elf me} {
    if {$elf eq $me} {return [+ 3 $me]}
    set operator [expr {([abs [- $elf $me]] == 1) ? ">" : "<"}]
    return [+ [expr ($elf $operator $me) ? 0 : 6] $me]
}

# Take both lists, and call matchPoints on each RPS match. That will give us
#   the result per match, then just fold em up to get the total score.
set scoreList [lmap elf $elfPlay me $myPlay {
    matchPoints [dict get $scores $elf]\
                [dict get $scores $me]}]

puts "Part 1: [fold 0 + $scoreList]"


#################################################
## Part 2
# X - 1 - Lose
# Y - 2 - Draw
# Z - 3 - Win
#################################################
#
# PickSign works by using the sam relation matchPoints does.
# To win any RPS, you add 1 to elf. To lose, you add 2, and draw is 0.
# To handle overflow, you need to compute, check if larger than 3, then mod if 
#   it is larger than 3.
proc pickSym {elf me} {
    set notdraw [expr ($me == 3) ? 1 : 2]
    set res [+ $elf [expr {($me == 2) ? 0 : $notdraw}]]
    return [expr {$res > 3} ? [% $res 3] : $res]
}

# Same this as part one, but insert pickSym into our sign.
set res [lmap elf $elfPlay me $myPlay {\
        matchPoints [dict get $scores $elf]\
                    [pickSym [dict get $scores $elf] [dict get $scores $me]]\
    }]

puts "Part 2: [fold 0 + $res]"

