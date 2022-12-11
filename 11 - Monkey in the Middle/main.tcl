namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"


############################################################################
# Parse the data! Just a big ol regexp
############################################################################
set data [readFile [lindex $argv 0]]
set pattern    {Monkey\s(\d):\n}
append pattern {\s+Starting\sitems:\s((?:(?:\d+,?\s?))+)\n}
append pattern {\s+Operation:\snew\s=\sold\s((?:\*|\+)\s(?:old|\d+))\n}
append pattern {\s+Test:\sdivisible\sby\s(\d+)\n}
append pattern {\s+If\strue:\sthrow\sto\smonkey\s(\d+)\n}
append pattern {\s+If\sfalse:\sthrow\sto\smonkey\s(\d+)\n?}
set monkeys [regexp -inline -all -- $pattern $data]
set divisor 1
foreach {ignore monkey items op test t f} $monkeys {
    set divisor [* $divisor $test]
    dict set M $monkey [dict create\
                            items [lmap e [split $items ","] {string trim $e}]\
                            op    $op\
                            test  $test\
                            true $t\
                            false $f\
                            inspect 0\
            ]
}
puts "Monkeys parsed, Starting Rounds!"
############################################################################

# I am not proud
proc playRounds {M divisor roundCount worry_divsor} {
    for {set round 1} {$round < [+ $roundCount 1]} {incr round} {
        for {set m 0} {$m < [llength [dict keys $M]]} {incr m} {
            # $M $m is our current monkey
            # Pop the items from the monkey, then set the monkey to zero items.
            set items [dict get $M $m items]; dict set M $m items [list]

            foreach item $items {
                dict set M $m inspect [+ 1 [dict get $M $m inspect]]

                # 1) swap out any "old" references for the item
                # 2) Perform the monkey operation, then divide by the
                #    worry divisor (3 for part1, 1 for part2)
                # 3) Next mod with the divisor- All the monkey tests are prime numbers!
                #    this means we set an upper bound on the worry level by applying modulus 
                #    to the product of the monkey tests.
                set op [dict get $M $m op]
                regsub {old} $op $item op
                set new [% [/ [{*}$op $item] $worry_divsor] $divisor]
                
                # Do the monkey test and select the target monkey
                set target [expr {([% $new [dict get $M $m test]] == 0) ? [dict get $M $m true] : [dict get $M $m false]}]
                dict set M $target items [concat [dict get $M $target items] $new]
            }
        }
    }
    # Reduce the monkey list to just the inspect element, then filter out the monkey index
    # Sort and return the product of the two highest inspect counts (ic)
    set ic [lsort -integer -decreasing [lmap {i val} [dict map {k v} $M {dict get $v inspect}] {set val}]]
    return [* [lindex $ic 0] [lindex $ic 1]]
}

puts "Part 1: [playRounds $M $divisor 20 3]"
puts "Part 2: [playRounds $M $divisor 10000 1]"

