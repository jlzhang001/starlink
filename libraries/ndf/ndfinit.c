#define _POSIX_SOURCE 1		 /* Declare POSIX source */

/* Header files. */
/* ============= */
/* C run-time library header files. */
#include <stdlib.h>              /* Utility functions */

/* External interfaces. */
#include "ems.h"                 /* EMS Error message service */
#include "sae_par.h"		 /* Standard SAE constants */

/* Internal header files. */
#include "ndf1.h"                /* NDF private interface */

/* Global variables. */
/* ================= */
/* Define global variables to hold command line argument information. */
int ndf1_argc = -1;
const char *const *ndf1_argv = NULL;

/* On Linux (really gcc/g77/libf2c), we need to define these global
   variables which are referenced by the Fortran system routine GETARG. 
   GETARG is not actually called if ndfInit has been used, as the 
   linker resolves the reference to these variables by pulling in a 
   function called ``main'' from a standard library, which then conflicts 
   with the user's ``main''. It may be necessary to tune the use of 
   these variables for differing compilers and operating systems, for
   now we just assume that gcc will be matched by g77/libf2c.
*/
#if defined( __GNUC__ )
int f__xargc;
char **f__xargv;
#endif

/* Function definitions. */
/* ===================== */
void ndfInit( int argc, char *const argv[], int *status ) {
/*
*+
*  Name:
*     ndfInit

*  Purpose:
*     Initialise the NDF_ library for use from a C main routine.

*  Language:
*     ANSI C

*  Synopsis:
*     void ndfInit( int argc, char *const argv[], int *status );

*  Description:
*     This function must be called to perform initialisation if the
*     NDF_ library is to be used in a program whose main routine is
*     written in C. It should be called before any other use of the
*     NDF_ library takes place.

*  Parameters:
*     argc
*        The number of command line arguments.
*     argv
*        Pointer to an array of pointers to null-terminated strings
*        (one for each argument) containing the command line argument
*        strings.
*     status
*        Pointer to the global status.

*  Notes:
*     - The actual arguments supplied for "argv" and "argc" should
*     normally be the standard arguments supplied to the C "main"
*     function by the operating system.
*     - If these arguments are not available, then an "argc" value of
*     zero should be given (whereupon the "argv" value will be
*     ignored).
*-
*/
   
/* Local Variables: */
   int iarg;                     /* Loop counter for arguments */

/*. */

/* Check inherited global status. */
   if ( *status != SAI__OK ) return;

/* Check the argument count for validity and report an error if
   necessary. */
   if ( argc < 0 ) {
      *status = NDF__ARCIN;
      ems_seti_c( "ARGC", argc );
      ems_rep_c( "ndfInit_argc", "Invalid argument count (^ARGC); this value "
                 "should not be less than zero.", status );

/* Check the argument vector pointer similarly to ensure it is not
   NULL. */
   } else if ( ( argc > 0 ) && !argv ) {
      *status = NDF__ARGIN;
      ems_rep_c( "ndfInit_arg1", "Invalid NULL pointer given for argument "
                 "list.", status );
      
/* Otherwise, check that each individual argument string pointer is
   valid (not NULL) and report an error if necessary. */
   } else {
      for ( iarg = 0; iarg < argc; iarg++ ) {
         if ( !argv[ iarg ] ) {
            *status = NDF__ARGIN;
            ems_seti_c( "ARG", iarg );
            ems_rep_c( "ndfInit_arg2", "Invalid NULL string pointer given for "
                       "argument number ^ARG.", status );
            break;
         }
      }
   }

/* If OK, store the argument count and argument vector pointer in
   global variables for use by ndf1_gtarg. */
   if ( *status == SAI__OK ) {
      ndf1_argc = argc;
      ndf1_argv = (const char **const) argv;

/* Otherwise, report context information and call the error tracing
   function. */
   } else {
      ems_rep_c( "ndfInit_err", "ndfInit: Error initialising the NDF_ library "
                 "for use from a C main routine.", status );
      ndf1Trace( "ndfInit", status );
   }
}
