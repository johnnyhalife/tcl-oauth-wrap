if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded oauth_wrap 0.9 [list source [file join $dir wrap.tcl]]