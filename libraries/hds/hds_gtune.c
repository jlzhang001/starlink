#include "hds1_feature.h"	 /* Define feature-test macros, etc.	    */

#include "f77.h"		 /* F77 <-> C interface macros		    */
#include "ems.h"		 /* EMS error reporting routines	    */
#include "hds1.h"		 /* Global definitions for HDS		    */
#include "rec.h"		 /* Public rec_ definitions		    */
#include "str.h"		 /* Character string import/export macros   */
#include "dat1.h"		 /* Internal dat_ definitions		    */
#include "dat_err.h"		 /* DAT__ error code definitions	    */

   F77_INTEGER_FUNCTION(hds_gtune)
                       ( struct STR *param_str,
		         int *value,
			 int *status,
			 int param_lenarg )
   {
/*
*+
*  Name:
*     HDS_GTUNE

*  Purpose:
*     Obtain tuning parameter value.

*  Language:
*     ANSI C

*  Invocation:
*     CALL HDS_GTUNE( PARAM, VALUE, STATUS )

*  Description:
*     The routine returns the current value of an HDS tuning parameter
*     (normally this will be its default value, or the value last
*     specified using the HDS_TUNE routine).

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        Name of the tuning parameter whose value is required (case
*        insensitive).
*     VALUE = INTEGER (Returned)
*        Current value of the parameter.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     Tuning parameter names may be abbreviated to 4 characters.

*  Copyright:
*     Copyright (C) 1992 Science & Engineering Research Council

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK, RAL)
*     {enter_new_authors_here}

*  History:
*     13-AUG-1991 (RFWS):
*        Original version.
*     25-FEB-1992 (RFWS):
*        Added auto-initialisation of HDS.
*     30-NOV-1992 (RFWS):
*        Added support for the "SHELL" tuning parameter.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
*/

/* Local variables:							    */
      char name[ DAT__SZNAM + 1 ]; /* Validated tuning parameter name	    */
      int param_len = param_lenarg; /* Parameter string length		    */
      struct DSC param;		 /* Parameter string descriptor		    */

/*.									    */

/* Check the inherited global status.					    */
      if ( !_ok( *status ) ) return *status;
      hds_gl_status = *status;

/* Import the tuning parameter name and perform preliminary validation.	    */
      _strimp( &param, param_str, &param_len );
      dau_check_name( &param, name );

/* Ensure that HDS has been initialised.				    */
      if ( !hds_gl_active ) dat1_init( );

/* Return the appropriate value. Note that where "one-shot" values are	    */
/* provided, we return these, rather than the default tuning setting (e.g.  */
/* hds_gl_inalq, rather than hds_gl_inalq0).				    */
      if( _ok( hds_gl_status ) )
      {
         if ( strncmp( name, "INAL", 4 ) == 0 )
         {
            *value = hds_gl_inalq;
         }
         else if ( strncmp( name, "MAP", 3 ) == 0 )
         {
            *value = hds_gl_map;
         }
         else if ( strncmp( name, "MAXW", 4 ) == 0 )
         {
            *value = hds_gl_maxwpl;
         }
         else if ( strncmp( name, "NBLO", 4 ) == 0 )
         {
            *value = hds_gl_nblocks;
         }
         else if ( strncmp( name, "NCOM", 4 ) == 0 )
         {
            *value = hds_gl_ncomp;
         }
         else if ( strncmp( name, "SHEL", 4 ) == 0 )
         {
            *value = hds_gl_shell;
         }
         else if ( strncmp( name, "SYSL", 4 ) == 0 )
         {
            *value = hds_gl_syslck;
         }
         else if ( strncmp( name, "WAIT", 4 ) == 0 )
         {
            *value = hds_gl_wait;
         }

/* If the tuning parameter name was not recognised, then report an error.   */
	 else
	 {
	    hds_gl_status = DAT__NAMIN;
	    ems_setc_c( "PARAM", (char *) param.body, param.length );
	    ems_rep_c( "HDS_GTUNE_1",
	               "Unknown tuning parameter name \'^PARAM\' specified \
(possible programming error).",
		       &hds_gl_status );
         }
      }		       

/* If an error occurred, then report contextual information.		    */
      if ( !_ok( hds_gl_status ) )
      {
         ems_rep_c( "HDS_GTUNE_ERR",
	            "HDS_GTUNE: Error obtaining the value of an HDS tuning \
parameter.",
		    &hds_gl_status );
      }

/* Return the current global status value.				    */
      *status = hds_gl_status;
      return *status;
   }
