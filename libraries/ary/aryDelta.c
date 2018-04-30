#include "sae_par.h"
#include "ary1.h"
#include "star/hds.h"
#include "mers.h"
#include "ary_err.h"
#include "prm_par.h"
#include <string.h>
#include <ctype.h>

void aryDelta( Ary *ary1, int zaxis, const char *type, float minrat,
               AryPlace **place, float *zratio, Ary **ary2, int *status ) {
/*
*+
*  Name:
*     aryDelta

*  Purpose:
*     Compress an array using delta compression.

*  Synopsis:
*     void aryDelta( Ary *ary1, int zaxis, const char *type, float minrat,
*                    AryPlace **place, float *zratio, Ary **ary2, int *status )

*  Description:
*     This function creates a copy of the supplied array stored in DELTA form,
*     which provides a lossless compression scheme for integer data. This
*     scheme assumes that adjacent integer values in the input array tend
*     to be close in value, and so differences between adjacent values can
*     be represented in fewer bits than the absolute values themselves.
*     The differences are taken along a nominated pixel axis within the
*     supplied array (specified by argument ZAXIS).
*
*     In practice, the scheme is limited currently to representing differences
*     between adjacent values using a HDS integer data type (specified by
*     argyument TYPE) - that is, arbitrary bit length is not yet supported.
*     So for instance an _INTEGER input array can be compressed by storing
*     differences as _WORD or _BYTE values, but a _WORD input array can only
*     be compressed by storing differences as _BYTE values.
*
*     Any input value that differs from its earlier neighbour by more than
*     the data range of the selected data type is stored explicitly using
*     the data type of the input array.
*
*     Further compression is achieved by replacing runs of equal input values
*     by a single occurrence of the value with a correspsonding repetition
*     count.
*
*     It should be noted that the degree of compression achieved is
*     dependent on the nature of the data, and it is possible for the
*     compressed array to occupy more space than the uncompressed array.
*     The compression factor actually achieved is returned in argument
*     "zratio" (the ratio of the supplied array size to the compressed
*     array size). A minmum allowed compression ratio may be specified via
*     argument "minrat". If the compression ratio is less than this value,
*     then the returned copy is left uncompressed.

*  Parameters:
*     ary1
*        The input array identifier. This can be stored in any form. If
*        it is already stored in DELTA form, it is uncompressed and then
*        re-compressed using the supplied compression parameters. If
*        is is stored in SCALED form, the internal integer values are
*        compressed and the scale and zero terms are copied into the
*        DELTA array.
*     zaxis
*        The one-based index of the pixel axis along which differences are
*        to be taken. If this is zero, a default value will be selected that
*        gives the greatest compression. An error will be reported if a
*        value less than zero or greater than the number of axes in the
*        input array is supplied.
*     type
*        The data type in which to store the differences between adjacent
*        input values. This must be one of '_BYTE', '_WORD' or
*        '_INTEGER'. Additionally, a blank string may be supplied in which
*        case a default value will be selected that gives the greatest
*        compression.
*     minrat
*        The minimum allowed ZRATIO value. If compressing the input array
*        results in a ZRATIO value smaller than or equal to MINRAT, then
*        the returned array is left uncompressed. If the supplied value is
*        zero or negative, then the array will be compressed regardless of
*        the compression ratio.
*     place
*        Address of an array placeholder pointer (e.g. generated by the
*        aryPlace function), which indicates the position in the data system
*        where the new array will reside. The placeholder is annulled by this
*        function, and a value of NULL will be returned.
*     zratio
*        Returned holding the compression factor actually achieved (the ratio
*        of the supplied array size to the compressed array size). Genuine
*        compressions are represented by values more than 1.0, but values
*        less than 1.0 may be returned if the input data is not suited
*        to delta compression (i.e. if the "compression" actually expands
*        the array storage). Note, the returned value of ZRATIO may be
*        smaller than MINRAT, in which case the supplied array is left
*        unchanged. The returned compression factor is approximate as it
*        does not take into account the space occupied by the HDS metadata
*        describing the extra components of a DELTA array (i.e. the
*        component names, data types, dimensions, etc). This will only be
*        significant for very small arrays.
*     ary2
*        Returned holding a pointer to the new DELTA array.
*     status
*        The global status.

*  Notes:
*     - An error will be reported if the supplied array does not hold
*     integer values. In the case of a SCALED array, the internal
*     (scaled) values must be integers, but the external (unscaled) values
*     can be of any data type.
*     - The compression axis and compressed data type actually used can
*     be determined by passing the returned array to aryGtdlt.
*     -  An error will result if the array, or any part of it, is
*     currently mapped for access (e.g. through another identifier).
*     -  An error will result if the array holds complex values.

*  Copyright:
*      Copyright (C) 2017 East Asian Observatory
*      All rights reserved.

*  Licence:
*     This program is free software; you can redistribute it and/or
*     modify it under the terms of the GNU General Public License as
*     published by the Free Software Foundation; either version 2 of
*     the License, or (at your option) any later version.
*
*     This program is distributed in the hope that it will be
*     useful,but WITHOUT ANY WARRANTY; without even the implied
*     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
*     PURPOSE. See the GNU General Public License for more details.
*
*     You should have received a copy of the GNU General Public License
*     along with this program; if not, write to the Free Software
*     Foundation, Inc., 51 Franklin Street,Fifth Floor, Boston, MA
*     02110-1301, USA

*  Authors:
*     DSB: David S. Berry (EAO)

*  History:
*     03-JUL-2017 (DSB):
*        Original version, based on equivalent Fortran routine.

*-
*/

/* Local variables: */
   AryACB *acb1;              /* Input array ACB */
   AryACB *acb2;              /* Output array ACB */
   AryACB *acbt;              /* Input copy ACB */
   AryDCB *dcb2;              /* Output array DCB */
   AryDCB *dcbt;              /* Input copy DCB */
   AryPCB *pcb=NULL;          /* Placeholder PCB */
   HDSLoc *locc=NULL;         /* Locator for component */
   HDSLoc *loct=NULL;         /* Locator for temporary copy of array */
   char name[DAT__SZNAM+1];   /* Name of component */
   char ztyold[DAT__SZTYP+1]; /* Old compressed data type */
   const char *p;             /* Pointer to next character */
   const char *ztyuse;        /* Best compressed data type */
   float ratio;               /* Compression ratio for current combination */
   float zratold;             /* Old compression ratio */
   int blank_type;            /* Is the supplied type string blank? */
   int erase;                 /* Whether to erase placeholder object */
   int icomp;                 /* Component index */
   int ncomp;                 /* Component count */
   int ndim;                  /* Number of axes in supplied array */
   int zax;                   /* Current compression axis */
   int zaxhi;                 /* Highest compression axis to test */
   int zaxlo;                 /* Lowest compression axis to test */
   int zaxold;                /* Old compression axis */
   int zaxuse;                /* Best compression axis */
   int zty;                   /* Current compressed data type */
   int ztyhi;                 /* Highest compressed data type to test */
   int ztylo;                 /* Lowest compressed data type to test */

/* Supported compressed data types */
   const char *types[ 3 ] = {"_BYTE", "_WORD", "_INTEGER"};

/* Initialise the returned pointer. */
   *ary2 = NULL;

/* Check inherited global status. */
   if( *status != SAI__OK ) return;

/* Import the input array identifier. */
   acb1 = (AryACB *) ary1Impid( ary1, 1, 1, 1, status );

/* If the array is not a base array, produce a temporary copy of it. */
   if( acb1->cut ){
      ary1Temp( "ARRAY", 0, NULL, &loct, status );
      ary1Cpy( acb1, 1, &loct, 1, &acbt, status );

/* If the array is a base array, use it directly. */
   } else {
      loct = NULL;
      acbt = acb1;
   }

/* Check it is safe to de-reference pointer acbt. */
   if( *status != SAI__OK ) goto L999;

/* Obtain the input data object (DCB) and ensure that storage form, data
   type and bounds information is available for it. */
   dcbt = acbt->dcb;
   ary1Dfrm( dcbt, status );
   ary1Dtyp( dcbt, status );
   ary1Dbnd( dcbt, status );

/* Get the number of axes in the input array. */
   ndim = dcbt->ndim;

/* Report an error if the array holds complex values. */
   if( dcbt->complex && *status == SAI__OK ){
      *status = ARY__FRMCV;
      datMsg( "ARRAY", dcbt->loc );
      errRep( " ", "The array ^ARRAY holds complex values (possible "
              "programming error).", status );
      goto L999;
   }

/* Report an error if the ZAXIS value is wrong. */
   if( ( zaxis < 0 || zaxis > ndim ) && *status == SAI__OK ){
      *status = ARY__DIMIN;
      msgSeti( "Z", zaxis );
      msgSeti( "N", ndim );
      errRep( " ", "Compression axis ^Z is invalid - it should be in the "
              "range 1 to ^N (possible programming error).", status );
      goto L999;
   }

/* Set a flag indicating if the supplied type string is blank. */
   p = type - 1;
   while( *(++p) && isspace(*p) );
   blank_type = (*p == 0);

/* Check the supplied TYPE. Report an error if it is not a signed integer
   type, or blank. */
   if( strcmp( type, "_INTEGER" ) && strcmp( type, "_WORD" ) &&
       strcmp( type, "_BYTE" ) && !blank_type && *status == SAI__OK ){
      *status = ARY__TYPIN;
      msgSetc( "T", type );
      errRep( " ", "Illegal compressed data type '^T' - (possible programming"
              "error).", status );
      goto L999;
   }

/* Check if the data object is mapped. Report an error if it is. */
   if( ( dcbt->nwrite != 0  || dcbt->nread != 0 ) && *status == SAI__OK ){
      *status = ARY__ISMAP;
      datMsg( "ARRAY", dcbt->loc );
      errRep( " ", "The array ^ARRAY is mapped for access, perhaps through"
              "another identifier (possible programming error).", status );
      goto L999;
   }

/* Import the array placeholder, converting it to a PCB index. */
   pcb = (AryPCB *) ary1Impid( *place, 0, 0, 0, status );

/* Indicate we have not yet created the output array. */
   acb2 = NULL;

/* If the array is already in delta form, we may be able simply to copy it
   to produce the output array. If not, we need to uncompress it before
   re-compressing it. */
   if( !strcmp( dcbt->form, "DELTA" ) ){

/* If the supplied array was not a base array, then the act of copying it
   (above) should have uncompressed any delta array, and so we can re-use
   the LOCT locator here. Report an error if copying the array does not
   seem to have uncompressed it. */
      if( loct && *status == SAI__OK ){
         *status = ARY__FATIN;
         errRep( " ", "aryDelta: Array has delta form after being copied"
                 "(internal programming error).", status );
         goto L999;
      }

/* Get the old compression parameters. */
      ary1Gtdlt( dcbt, &zaxold, ztyold, &zratold, status );

/* If they are the same as the new ones, just copy the supplied array to
   create the output array. We want the copy to be a DELTA compressed
   array, so do not expand the compressed array. */
      if( zaxold == zaxis && ztyold == type ){
         ary1Cpy( acb1, pcb->tmp, &(pcb->loc), 0, &acb2, status );

/* If they are not the same as the new ones, we need to uncompress the
   supplied delta array so that we can re-compress it with the new
   parameters. Taking a temporary copy of the supplied array is the
   simplest way to uncompress it. */
      } else {
         ary1Temp( "ARRAY", 0, 0, &loct, status );
         ary1Cpy( acb1, 1, &(loct), 1, &acbt, status );

/* Get the DCB entry for the uncompressed copy, and ensure type
   information is available for it in the DCB. */
         dcbt = acbt->dcb;
         ary1Dtyp( dcbt, status );
      }
   }

/* If we created the output array above, there is nothing more to do. */
   if( !acb2 && *status == SAI__OK ){

/* If required, find the best compression parameters. */
      if( zaxis == 0 || blank_type ){

/* Determine the range of ZAXIS to test. */
         if( zaxis == 0 ){
            zaxlo = 1;
            zaxhi = ndim;
         } else {
            zaxlo = zaxis;
            zaxhi = zaxis;
         }

/* Determine the list of compressed data types to test. */
         if( !strcmp( type, "_BYTE" ) ){
            ztylo = 0;
            ztyhi = 0;
         } else if( !strcmp( type, "_WORD" ) ){
            ztylo = 1;
            ztyhi = 1;
         } else if( !strcmp( type, "_INTEGER" ) ){
            ztylo = 2;
            ztyhi = 2;
         } else if( !strcmp( dcbt->type, "_INTEGER" ) ){
            ztylo = 0;
            ztyhi = 2;
         } else if( !strcmp( dcbt->type, "_WORD" ) ){
            ztylo = 0;
            ztyhi = 1;
         } else {
            ztylo = 0;
            ztyhi = 0;
         }

/* Initialise the best compression found so far. */
         *zratio = VAL__MINR;

/* Loop round all ZAXIS values */
         for( zax = zaxlo; zax <= zaxhi; zax++ ){

/* Skip this axis if it spans less than two pixels. */
            if( acbt->ubnd[ zax - 1 ] > acbt->lbnd[ zax - 1 ] + 1 ){

/* Loop round all compressed data types. */
               for( zty = ztylo; zty <= ztyhi; zty++ ){

/* See how much compression could be expected using this combination of
   compression axis and data type. */
                  ary1S2dlt( dcbt->loc, zax, types[ zty ], NULL, &ratio,
                             status );

/* Record the current compresson axis and type if this combination gives
   more compression than any other combination tested so far. */
                  if( ratio > *zratio ){
                     *zratio = ratio;
                     zaxuse = zax;
                     ztyuse = types[ zty ];
                  }
               }
            }
         }

/* Otherwise, just use the supplied compression values. */
      } else {
         zaxuse = zaxis;
         ztyuse = type;
      }

/* Create a new simple array structure in place of the placeholder object,
   obtaining a DCB entry which refers to it. Creation of the primitive
   array is deferred since we do not yet know how big it will need to be. */
      ary1Dcre( 1, dcbt->type, dcbt->complex, acbt->ndim, acbt->lbnd,
                acbt->ubnd, pcb->tmp, pcb->loc, &dcb2, status );
      if( *status != SAI__OK ) goto L999;

/* Erase all components within the data object - they will be re-created in
   compressed form by ary1S2dlt. */
      datNcomp( dcb2->loc, &ncomp, status );
      for( icomp = 0; icomp < ncomp; icomp++ ){
         datIndex( dcb2->loc, 1, &locc, status );
         datName( locc, name, status );
         datAnnul( &locc, status );
         datErase( dcb2->loc, name, status );
      }

/* Now do the compression using the best combination. */
      ary1S2dlt( dcbt->loc, zaxuse, ztyuse, dcb2->loc, zratio, status );

/* If the compression ratio is too small, annul the DCB entry created above
   and create a copy of the supplied array instead. */
      if( *zratio <= minrat ){

/* The data object locator is needed as a placeholder for the copy, so take
   a clone of it now, and then annul the DCB entry, without disposing of
   the data object. */
         datClone( dcb2->loc, &pcb->loc, status );
         ary1Danl( 0, &dcb2, status );

/* Empty the old data object so we can use it as a placeholder for the new
   copy. */
         datNcomp( pcb->loc, &ncomp, status );
         for( icomp = 0; icomp < ncomp; icomp++ ){
            datIndex( pcb->loc, 1, &locc, status );
            datName( locc, name, status );
            datAnnul( &locc, status );
            datErase( pcb->loc, name, status );
         }

         ary1Cpy( acbt, pcb->tmp, &(pcb->loc), 1, &acb2, status );

/* If the compression ratio was high enough, and all went well, store the
   new storage form in the DCB. */
      } else if( *status == SAI__OK ){
         strcpy( dcb2->form, "DELTA" );

/* Obtain a locator to the non-imaginary data component to the new array. */
         datFind( dcb2->loc, "DATA", &dcb2->dloc, status );

/* Indicate state information is out of date. */
         dcb2->kstate = 0;

/* Create a base array entry in the ACB to refer to the output DCB entry. */
         ary1Crnba( dcb2, &acb2, status );
      }
   }

/* Arrive here if an error occurrs. */
L999:

/* If all went well, export an identifier for the output array */
   if( *status == SAI__OK ){
      *ary2 = ary1Expid( (AryObject *) acb2, status );

/* If an error occurred, then annul the new ACB entry. */
      if( ( *status != SAI__OK ) && acb2 ) acb2 = ary1Anl( acb2, status );
   }

/* Annul any temporary base copy of the input array. */
   if( loct ) ary1Antmp( &loct, status );

/* Annul the placeholder, erasing the associated object if any error has
   occurred. */
   if( pcb ){
      erase = ( *status != SAI__OK );
      ary1Annpl( erase, &pcb, status );
   }

/* If an error occurred, then report context information and call the error
   tracing routine. */
   if( *status != SAI__OK ){
      errRep( " ", "aryDelta: Error compressing an array using delta "
              "compression.", status );
      ary1Trace( "aryDelta", status );
   }

}
