#include <stdlib.h>
#include "sae_par.h"
#include "dat_par.h"
#include "ndf1.h"
#include "prm_par.h"
#include "dat_err.h"
#include "ndf.h"
#include "star/util.h"
#include "mers.h"

void ndfAcmsg_( const char *token, int indf, const char *comp, int iaxis,
               int *status ){
/*
*+
*  Name:
*     ndfAcmsg

*  Purpose:
*     Assign the value of an NDF axis character component to a message
*     token.

*  Synopsis:
*     void ndfAcmsg( const char *token, int indf, const char *comp,
*                    int iaxis, int *status )

*  Description:
*     This function assigns the value of the specified axis character
*     component of an NDF to a message token, for use in constructing
*     messages using the MSG_ or ERR_ functions (see SUN/104).

*  Parameters:
*     token
*        Pointer to a null terminated string holding the name of the
*        message token.
*     indf
*        NDF identifier.
*     comp
*        Pointer to a null terminated string holding the name of the axis
*        character component whose value is to be used: "LABEL" or "UNITS".
*     iaxis
*        Number of the NDF axis.
*     *status
*        The global status.

*  Notes:
*     -  If the requested axis component is in an undefined state, then an
*     appropriate default value will be assigned to the token.

*  Copyright:
*     Copyright (C) 2018 East Asian Observatory
*     All rights reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation; either version 2 of the License, or (at
*     your option) any later version.
*
*     This program is distributed in the hope that it will be useful,but
*     WITHOUT ANY WARRANTY; without even the implied warranty of
*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*     General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street,Fifth Floor, Boston, MA
*     02110-1301, USA

*  Authors:
*     RFWS: R.F. Warren-Smith (STARLINK)
*     DSB: David S. Berry (EAO)

*  History:
*     xxx (DSB):
*        Original version, based on equivalent Fortran function by RFWS.

*-
*/

/* Local Variables: */
   NdfACB *acb;          /* Pointer to the NDF entry in the ACB */
   NdfDCB *dcb;          /* Pointer to data object entry in the DCB */
   char *pntr;           /* Pointer to mapped component */
   char val[ 10 + VAL__SZI ];  /* Default value string */
   hdsdim lbnd[ NDF__MXDIM ];  /* Data object lower bounds */
   hdsdim ubnd[ NDF__MXDIM ];  /* Data object upper bounds */
   int iax1;             /* First (only) axis to process */
   int iax2;             /* Last (only) axis to process */
   int iccomp;           /* Character component identifier */
   int ndim;             /* Number of data object dimensions */
   int there;            /* Whether component exists */

/* Check inherited global status. */
   if( *status != SAI__OK ) return;

/* Ensure the NDF library has been initialised. */
   NDF_INIT( status );

/* Import the NDF identifier. */
   ndf1Impid( indf, &acb, status );

/* Validate the axis character component name. */
   ndf1Vaccn( comp, &iccomp, status );

/* Validate the axis number. */
   ndf1Van( acb, iaxis, 0, &iax1, &iax2, status );
   if( *status == SAI__OK ) {

/* Obtain an index to the data object entry in the DCB. */
      dcb = acb->dcb;

/* If this is an NDF section, then obtain the number of dimensions of
   the actual data object to which it refers from the ARY_ system
   identifier for its data array. */
      there = 1;
      if( acb->cut ) {
         aryBound( dcb->did, NDF__MXDIM, lbnd, ubnd, &ndim, status );

/* Note if the required axis exists in the actual data object. */
         if( *status == SAI__OK ) there = ( iax1 <= ndim );
      }

/* If the required axis exists, then ensure that axis character
   component information is available. */
      if( *status == SAI__OK ) {
         if( there ) {
            ndf1Dac( iax1, iccomp, dcb, status );
            if( *status == SAI__OK ) {

/* Note whether the required character component exists. */
               there = ( dcb->acloc[ iax1 ][ iccomp ] != NULL );
            }
         }
      }

/* If the component (or its axis) does not exist, then create a default
   value. */
      if( *status == SAI__OK ) {
         if( !there ) {

/* The label component defaults to "Axis n". */
            if( iccomp == NDF__ALAB ) {
               sprintf( val, "Axis %d", iax1 + 1 );

/* The units component defaults to "pixel". */
            } else if( iccomp == NDF__AUNI ) {
               star_strlcpy( val, "pixel", sizeof( val ) );
            }

/* Assign the default value. */
            msgSetc( token, val );

/* If the required component exists, then map it for reading and
   determine its length. */
         } else {
            pntr = ndf1Hmp0C( dcb->acloc[ iax1 ][ iccomp ], status );

/* Assign the mapped value to the message token. */
            if( pntr ) {
               msgSetc( token, pntr );
               pntr = astFree( pntr );
            }

/* Unmap the component. */
            ndf1Hunmp( dcb->acloc[ iax1 ][ iccomp ], status );
         }
      }
   }

/* If an error occurred, then report context information and call the
   error tracing function. */
   if( *status != SAI__OK ) {
      errRep( " ", "ndfAcmsg: Error assigning the value of an NDF axis "
              "character component to a message token.", status );
      ndf1Trace( "ndfAcmsg", status );
   }

/* Restablish the original AST status pointer */
   NDF_FINAL

}
