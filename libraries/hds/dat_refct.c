#include "hds1_feature.h"	 /* Define feature-test macros, etc.	    */
#include "f77.h"		 /* F77 <-> C interface macros		    */
#include "cnf.h"		 /* F77 <-> C string handling functions	    */
#include "ems.h"		 /* EMS error reporting routines	    */
#include "ems_par.h"		 /* EMS public constants		    */
#include "hds1.h"		 /* Global definitions for HDS		    */
#include "rec.h"		 /* Public rec_ definitions		    */
#include "dat1.h"		 /* Internal dat_ definitions		    */
#include "dat_err.h"		 /* DAT__ error code definitions	    */

   F77_INTEGER_FUNCTION(dat_refct)( CHARACTER(LOC),
				    INTEGER(REFCT),
				    INTEGER(STATUS)
				    TRAIL(LOC) )
   {
/*
*+
*  Name:
*     DAT_REFCT

*  Purpose:
*     Enquire the reference count for a container file.

*  Language:
*     ANSI C

*  Invocation:
*     CALL DAT_REFCT( LOC, REFCT, STATUS )

*  Description:
*     The routine returns a count of the number of "primary" locators
*     associated with an HDS container file (its reference count). The
*     file will remain open for as long as this number is greater than
*     zero.

*  Arguments:
*     LOC = CHARACTER * ( * ) (Given)
*        Locator associated with any object in the container file.
*     REFCT = INTEGER (Returned)
*        Number of primary locators currently associated with the file.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     This routine may be used to determine whether annulling a primary
*     locator will cause a container file to be closed (also see the
*     routine DAT_PRMRY).

*  Copyright:
*     Copyright (C) 1992 Science & Engineering Research Council

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK, RAL)
*     {enter_new_authors_here}

*  History:
*     25-SEP-1992 (RFWS):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-
*/

/* Arguments Given:							    */
      GENPTR_CHARACTER(LOC)

/* Arguments Returned:							    */
      GENPTR_LOGICAL(REFCT)

/* Status:								    */
      GENPTR_INTEGER(STATUS)

/* Local Variables:							    */
      INT refcnt;		 /* Container file reference count	    */
      struct LCP *lcp;		 /* Pointer to LCP			    */

/*.									    */

/* Check the inherited global status.					    */
      if ( !_ok( *STATUS) ) return *STATUS;
      hds_gl_status = (INT) *STATUS;

/* Import the locator.							    */
      dat1_import_loc( LOC, LOC_length, &lcp );
      if ( _ok( hds_gl_status ) )
      {

/* Obtain the reference count for the container file and copy it to the	    */
/* returned argument.							    */
	 rec_refcnt( &lcp->data.han, 0, &refcnt, &hds_gl_status );
         if ( _ok( hds_gl_status ) )
         {
	    *REFCT = (F77_INTEGER_TYPE) refcnt;
	 }
      }

/* If an error occurred, then report contextual information.		    */
      if ( !_ok( hds_gl_status ) )
      {
	 ems_rep_c( "DAT_REFCT_ERR",
		    "DAT_REFCT: Error enquiring the reference count for a \
container file.",
		    &hds_gl_status );
      }

/* Return the current global status value.				    */
      *STATUS = (F77_INTEGER_TYPE) hds_gl_status;
      return *STATUS;
   }
