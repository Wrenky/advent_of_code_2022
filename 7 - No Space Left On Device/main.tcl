namespace import ::tcl::mathop::*
namespace import ::tcl::mathfunc::*
source "../utils.tcl"

#####################################################################
# Tree functions
#####################################################################
# Print the tree! (for debugging)
proc printTree {tree indent} {
    puts "[string repeat "   " $indent] [dict get $tree name] - [dict get $tree size]"
    foreach child [dict get $tree children] {printTree [dict get $tree $child] [+ $indent 1] }
}

# Sums the entire tree from the node passed in
proc sumTree {tree} {
    if {[dict get $tree children] == [list]} {return [dict get $tree size]}
    return [fold 0 + [lmap c [dict get $tree children] {sumTree [dict get $tree $c]}]]
}

# Predicates we need for filter calls
proc overTarget {size e} {return [expr ($e >= $size) ? True : False]}
proc under100k {e} {return [expr ($e >=100000)? False : True]}
proc isDir {child} {return [expr ([dict get $child size] == 0)? True : False]}

# Returns all the directory sizes from this tree node down
proc findDirSizes {tree} {
    if {[dict get $tree children] == [list]} {return [list]}
    set dirChildrenNodes [filter isDir [lmap c [dict get $tree children] {dict get $tree $c}]]
    set childSizes [lmap n $dirChildrenNodes {sumTree $n}]
    return [concat $childSizes {*}[lmap n $dirChildrenNodes {findDirSizes $n}]]
}

#####################################################################
# Process input into our "tree"
#####################################################################
dict set myTree "/" [dict create name "/" size 0 children [list]]
set keyPath [list]
set data [readFile [lindex $argv 0]]
foreach line [split $data "\n"] {
    switch -regexp -matchvar matches $line {
        {\$\scd\s(.*)} {
            # Append the cd to the keypath, or pop one off if its ..
            lassign $matches -> name 
            set keyPath [expr {($name eq "..") ? [lrange $keyPath 0 end-1] : [concat $keyPath $name]}]
        }
        {\$\sls} {# do nothing}
        {dir\s(.*)} -
        {(\d+)\s(.*)} {
            # On a new element, insert a blank node, then update the current nodes children.
            lassign [expr {([llength $matches] == 3) ? [lreverse $matches] : [list [lindex $matches 1] 0]}] name size
            dict set myTree {*}$keyPath $name [dict create name $name size $size children [list]]
            dict set myTree {*}$keyPath children [lsort -unique [list {*}[dict get $myTree {*}$keyPath children] $name]]
        }
    }
}


#####################################################################
# Do the Stuff
#####################################################################

# Get all the directory sizes, then fold up the ones under 100k
puts "Part 1: [fold 0 + [filter under100k [findDirSizes [dict get $myTree "/"]]]]"

# Total space, 70000000. Subtract the sum the base tree with sumTree
# We have [- 70000000 used]] space free
# We need to free [- 30000000 [- 70000000 used ]] space
set totalSpace 70000000
set needSpace  30000000
set targetSize [- $needSpace [- $totalSpace [sumTree [dict get $myTree "/"]]]]

# Get all the directory sizes, then filter for ones larger than our target size.
#   Sort that list by increasing (default) integer value, then grab the first one.
puts "Part 2: [lindex [lsort -integer [filter [list overTarget $targetSize] [findDirSizes [dict get $myTree "/"]]]] 0]"



