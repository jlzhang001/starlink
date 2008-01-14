/*
*+
*  Name:
*     smf_reshapendf

*  Purpose:
*     Free a smfData and reshape the NDF.

*  Language:
*     Starlink ANSI C

*  Type of Module:
*     C function

*  Invocation:
*     void smf_reshapendf( smfData **data, smfTile *tile, int trim, 
*                          int *status )

*  Arguments:
*     data = smfData ** (Given and Returned)
*        Pointer to the structure describing the NDF to be closed and
*        re-shaped. NULL is returned.
*     tile = smfTile * (Given)
*        Pointer to the structure defining the required shape for the
*        re-shaped NDF. 
*     trim = int (Given)
*        A flag indicating if the bounds of the tile should be trimmed.
*     status = int * (Given and Returned)
*        Inherited status value. This function attempts to execute even
*        if status is set to an error value on entry.

*  Description:
*     This function closes the specified NDF and assocaited resources,
*     then optionally changes the pixel bounds of the NDF to match the 
*     unextended bounds of the specified tile.

*  Authors:
*     David S Berry (JAC, UCLan)
*     {enter_new_authors_here}

*  History:
*     4-SEP-2007 (DSB):
*        Initial version.
*     1-OCT-2007 (DSB):
*        Ensure the reshaped NDF has the same number of pixel axes 
*        as the original NDF.
*     14-JAB-2008 (DSB):
*        Added argument "trim".
*     {enter_further_changes_here}

*  Copyright:
*     Copyright (C) 2007, 2008 Science & Technology Facilities Council.
*     All Rights Reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 3 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful, but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public
*     License along with this program; if not, write to the Free
*     Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
*     MA 02111-1307, USA

*  Bugs:
*     {note_any_bugs_here}
*-
*/

/* Starlink includes */
#include "sae_par.h"
#include "ndf.h"
#include "star/kaplibs.h"

/* SMURF includes */
#include "libsmf/smf.h"

void smf_reshapendf( smfData **data, smfTile *tile, int trim, int *status ){

/* Local Variables */
   IRQLocs *qlocs;              
   char comm[ 100 ];
   int bit;
   int dim[ 3 ];
   int fixed;
   int ix;
   int iy;
   int iz;
   int lbnd[ 3 ];
   int ndim;
   int nel;           
   int there;
   int tndf;
   int ubnd[ 3 ];
   int value;
   unsigned char *ipq;
   unsigned char *q;
   unsigned char qval;

/* Do nothing if no data was supplied. */
   if( *data ) {

/* If the NDF identifier is available, clone it. */
      if( (*data)->file && tile ) {
         ndfClone( (*data)->file->ndfid, &tndf, status ); 
      } else {
         tndf = NDF__NOID;
      }

/* Close the smfData structure holding the NDF description. */
      smf_close_file( data, status );

/* Get the number of pixel axes in the original NDF (should be 3 for the
   main arrays, and 2 for the extension arrays). */
      if( tndf != NDF__NOID ) {

/* If required, change the shape of the NDF. */
         if( trim ) {
            ndfDim( tndf, 3, dim, &ndim, status ); 
            ndfSbnd( ndim, tile->lbnd, tile->ubnd, tndf, status ); 

/* Otherwise, update the quality array to include a quality flag
   indicating the border pixels. We assume that the output NDF currently
   has no quality information. */
         } else {

/* Do not store quality info in sub-NDFs such as TSYS, etc. These are
   distinguished by the fact that they do not already have a SMURF
   extension. */
            ndfXstat( tndf, "SMURF", &there, status );
            if( there ) {

/* Create a structure to hold new quality name info. */
               irqNew( tndf, "SMURF", &qlocs, status );

/* Add in quality names; "BORDER". */
               irqAddqn( qlocs, "BORDER", 0, "set iff a pixel is within "
                         "the tile overlap area", status );

/* Determine which bit is used to represent the BORDER quality, and set the
   required mumerical quality value. */
               irqGetqn( qlocs, "BORDER", &fixed, &value, &bit, comm, 100,
                         status );
               qval = pow( 2, bit );
            
/* Map the quality array of the output NDF. */
               ndfMap( tndf, "Quality", "_UBYTE", "WRITE", (void **) &ipq, &nel, 
                       status );

/* Check the pointer can be used safely. */
               if( *status == SAI__OK ) {

/* Fill the quality array with zeros, except for the border pixels that are
   assigned "qval". */
                  ndfBound( tndf, 3, lbnd, ubnd, &ndim, status ); 
                  q = ipq;
                  for( iz = lbnd[ 2 ]; iz <= ubnd[ 2 ]; iz++ ) {
                     for( iy = lbnd[ 1 ]; iy <= ubnd[ 1 ]; iy++ ) {
                        for( ix = lbnd[ 0 ]; ix <= ubnd[ 0 ]; ix++ ) {
                           if( ix < tile->lbnd[ 0 ] || ix > tile->ubnd[ 0 ] || 
                               iy < tile->lbnd[ 1 ] || iy > tile->ubnd[ 1 ] ){
                              *(q++) = qval;
                           } else {
                              *(q++) = 0;
                           }
                        }
                     }
                  }
               }

/* Release the quality name information. */
               irqRlse( &qlocs, status );
            }
         }

/* Free the clonded NDF identifier. */
         ndfAnnul( &tndf, status );
      }
   }          
}

