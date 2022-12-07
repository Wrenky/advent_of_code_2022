#############################################
## Functional primitives
#############################################
namespace import ::tcl::mathop::*
package require textutil
proc fold {res op l} {foreach e $l {set res [$op $res $e]}; set res}
proc filter {cond l} {set res {}; foreach e $l {if [{*}$cond $e] {lappend res $e}}; set res}

proc lpop {listVar {count 1}} {
	upvar 1 $listVar l
	set r [lrange $l 0 [incr count -1]]
	set l [lreplace $l 0 $count]
	return $r
}
#############################################

#############################################
## Helpers
#############################################
proc readFile {filename} {
    if {$filename eq ""} {return ""}
	set fh [open $filename]
	set data [read -nonewline $fh]
	close $fh
	return $data
}
