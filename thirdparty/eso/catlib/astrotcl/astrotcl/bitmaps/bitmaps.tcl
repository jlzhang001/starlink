#!../bin/astrotcl_wish
#
# E.S.O. - VLT project
#
# "@(#) $Id: bitmaps.tcl,v 1.1.1.1 2002/04/04 20:11:39 brighton Exp $"
#
# script to generate C code declaring X bitmaps so that the (binary) application
# doesn't have to be delivered with the bitmap files.
#
# who             when       what
# --------------  ---------  ----------------------------------------
# Allan Brighton  21 Nov 95  Created

puts {
/*
 * E.S.O. - VLT project 
 * "@(#) $Id: bitmaps.tcl,v 1.1.1.1 2002/04/04 20:11:39 brighton Exp $"
 *
 * Bitmap definitions for Tk
 *
 * This file was generated by ../bitmaps/bitmaps.tcl  - DO NO EDIT
 */

#include <tcl.h>
#include <tk.h>

}
puts "void defineAstrotclBitmaps(Tcl_Interp *interp) {"
foreach file [glob -nocomplain *.xbm] {
    set name [file rootname $file]
    puts "    #include \"$file\""
    puts "    Tk_DefineBitmap(interp, Tk_GetUid(\"$name\"), (char*)${name}_bits, ${name}_width, ${name}_height);\n"
}
puts "}"
exit 0
