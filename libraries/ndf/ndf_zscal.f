      SUBROUTINE NDF_ZSCAL( INDF1, TYPE, SCALE, ZERO, PLACE, INDF2,
     :                      STATUS )
*+
*  Name:
*     NDF_ZSCAL

*  Purpose:
*     Create a compressed copy of an NDF using SCALE compression

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL NDF_ZSCAL( INDF1, TYPE, SCALE, ZERO, PLACE, INDF2, STATUS )

*  Description:
*     The routine creates a new NDF holding a compressed copy of the
*     supplied NDF. The compression is performed by scaling the DATA
*     and VARIANCE arrays using a simple linear scaling, and then
*     casting the scaled values into the specified data type. The amount
*     of compression, and the amount of information lost, is thus determined
*     by the input and output data types. For instance, if the input NDF is
*     of type _DOUBLE (eight bytes) and the output is of type _WORD (two
*     bytes), the compression ratio for each array component will be four
*     to one.

*  Arguments:
*     INDF1 = INTEGER (Given)
*        Identifier for the input NDF.
*     TYPE = CHARACTER * ( * ) (Given)
*        Numeric type of the output NDF's DATA component (e.g. '_REAL' or
*        '_INTEGER').
*     SCALE( 2 ) = DOUBLE PRECISION (Given and Returned)
*        The scale factors to use when compressing the array components in the
*        supplied NDF. The DATA array will be scaled using SCALE( 1 ) and
*        the VARIANCE array - if present - will be scaled using SCALE( 2 ).
*        If either of these is set to VAL__BADD, then a suitable value
*        will be found automatically by inspecting the supplied array
*        values. The values actually used will be returned on exit. See
*        "Notes:" below. On exit, any supplied values will be rounded to
*        values that can be represented accurately in the data type of
*        the input NDF.
*     ZERO( 2 ) = DOUBLE PRECISION (Given and Returned)
*        The zero offsets to use when compressing the array components in the
*        supplied NDF. The DATA array will be offset using ZERO( 1 ) and
*        the VARIANCE array - if present - will be offset using ZERO( 2 ).
*        If either of these is set to VAL__BADD, then a suitable value
*        will be found automatically by inspecting the supplied array
*        values. The values actually used will be returned on exit. See
*        "Notes:" below. On exit, any supplied values will be rounded to
*        values that can be represented accurately in the data type of
*        the input NDF.
*     PLACE = INTEGER (Given and Returned)
*        An NDF placeholder (e.g. generated by the NDF_PLACE routine)
*        which indicates the position in the data system where the new
*        NDF will reside. The placeholder is annulled by this routine,
*        and a value of NDF__NOPL will be returned (as defined in the
*        include file NDF_PAR).
*     INDF2 = INTEGER (Returned)
*        Identifier for the new NDF.
*     STATUS = INTEGER (Given and Returned)
*        The global status.

*  Notes:
*     -  The compressed data may not be of type _DOUBLE. An error will be
*     reported if TYPE is '_DOUBLE'.
*     -  Only arrays that are stored in SIMPLE or PRIMITIVE form can
*     be compressed. An error is reported if any other storage form is
*     encountered whilst compressing the input NDF.
*     -  The uncompressed array values are obtained by multiplying the
*     compressed values by SCALE and then adding on ZERO.
*     -  The default scale and zero values (used if VAL__BADD values are
*     supplied for SCALE and/or ZERO) are chosen so that the extreme array
*     values will fit into the dynamic range of the output data type,
*     allowing a small safety margin.
*     -  Complex arrays cannot be compressed using this routine. An error
*     will be reported if the input NDF has a complex type, or if "TYPE"
*     represents a complex data type.
*     -  The resulting NDF will be read-only. An error will be reported if
*     an attempt is made to map it for WRITE or UPDATE access.
*     - When the output NDF is mapped for READ access, uncompression occurs
*     automatically. The pointer returned by NDF_MAP provides access to the
*     uncompressed array values.
*     -  The result of copying a compressed NDF (for instance, using
*     NDF_PROP, etc.) will be an equivalent uncompressed NDF.
*     - When applied to a compressed NDF, the NDF_TYPE and NDF_FTYPE
*     routines return information about the data type of the uncompressed
*     NDF.
*     -  If this routine is called with STATUS set, then a value of
*     NDF__NOID will be returned for the INDF2 argument, although no
*     further processing will occur. The same value will also be
*     returned if the routine should fail for any reason. In either
*     event, the placeholder will still be annulled. The NDF__NOID
*     constant is defined in the include file NDF_PAR.

*  Copyright:
*     Copyright (C) 2010 Science & Technology Facilities Council.

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
*     DSB: David S Berry (STARLINK)
*     {enter_new_authors_here}

*  History:
*     8-OCT-2010 (DSB):
*        Original version.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'DAT_PAR'          ! DAT_ public constants
      INCLUDE 'NDF_PAR'          ! NDF_ public constants
      INCLUDE 'NDF_ERR'          ! NDF_ error constants
      INCLUDE 'NDF_CONST'        ! NDF_ private constants

*  Global Variables:
      INCLUDE 'NDF_ACB'          ! NDF_ Access Control Block
*        ACB_DID( NDF__MXACB ) = INTEGER (Read)
*           ARY_ system identifier for the NDF's data array.

*  Arguments Given:
      INTEGER INDF1
      CHARACTER * ( * ) TYPE

*  Arguments Given and Returned:
      DOUBLE PRECISION SCALE( 2 )
      DOUBLE PRECISION ZERO( 2 )
      INTEGER PLACE

*  Arguments Returned:
      INTEGER INDF2

*  Status:
      INTEGER STATUS             ! Global status

*  Local Variables:
      CHARACTER COMP( 2 )*8      ! Names of array components to scale
      CHARACTER DATYP( NDF__TYPUB:NDF__MXTYP )*( NDF__SZTYP )  ! Data types
      CHARACTER FORM*( NDF__SZFRM )! Array storage form
      INTEGER EL                 ! Number of array elements
      INTEGER IACB1              ! Index to input NDF entry in ACB
      INTEGER IACB2              ! Index to output NDF entry in ACB
      INTEGER ICOMP              ! Component index
      INTEGER INTYPE             ! Data type of input NDF
      INTEGER IPCB               ! Index to placeholder entry in the PCB
      INTEGER NCOMP              ! The number of array components to scale
      INTEGER OUTTYP             ! Data type of output NDF
      INTEGER PNTR1              ! Pointer to input array
      INTEGER PNTR2              ! Pointer to output array#
      INTEGER ZTYPE              ! Pre-existing input NDF compression type
      LOGICAL CPF( NDF__MXCPF )  ! Component propagation flags
      LOGICAL ERASE              ! Whether to erase placeholder object
      LOGICAL THERE              ! Does the VARIANCE component exist?


*  Local Data:
      DATA DATYP( NDF__TYPB ) / '_BYTE' / ! Data type code translations
      DATA DATYP( NDF__TYPD ) / '_DOUBLE' /
      DATA DATYP( NDF__TYPI ) / '_INTEGER' /
      DATA DATYP( NDF__TYPK ) / '_INT64' /
      DATA DATYP( NDF__TYPR ) / '_REAL' /
      DATA DATYP( NDF__TYPUB ) / '_UBYTE' /
      DATA DATYP( NDF__TYPUW ) / '_UWORD' /
      DATA DATYP( NDF__TYPW ) / '_WORD' /

      DATA COMP / 'DATA', 'VARIANCE' /  ! Names of arrays to scale

*.

*  Set an initial value for the INDF argument.
      INDF2 = NDF__NOID

*  Check the inherited status
      IF( STATUS .NE. SAI__OK ) RETURN

*  Import the NDF placeholder, converting it to a PCB index.
      IPCB = 0
      CALL NDF1_IMPPL( PLACE, IPCB, STATUS )

*  Import the input NDF identifier.
      CALL NDF1_IMPID( INDF1, IACB1, STATUS )

*  Parse the output data type.
      CALL NDF1_PSTYP( TYPE, OUTTYP, STATUS )

*  Report an error if the input DATA array is not stored in SIMPLE
*  or PRIMITIVE form.
      CALL ARY_FORM( ACB_DID( IACB1 ), FORM, STATUS )
      IF( FORM .NE. 'SIMPLE' .AND. FORM .NE. 'PRIMITIVE' .AND.
     :    STATUS .EQ. SAI__OK ) THEN
         STATUS = NDF__BADSF
         CALL MSG_SETC( 'F', FORM )
         CALL ERR_REP( 'NDF_ZSCAL_ERR1', 'The NDF is already '//
     :                 'compressed (using ^F compression).', STATUS )
      END IF

*  Propagate all components of the input NDF, except for the DATA and
*  VARIANCE arrays, to create a new base NDF and an ACB entry to describe it.
      DO ICOMP = 1, NDF__MXCPF
         CPF( ICOMP ) = .TRUE.
      END DO
      CPF( NDF__DCPF ) = .FALSE.
      CPF( NDF__VCPF ) = .FALSE.

      CALL NDF1_PRP( IACB1, 0, ' ', CPF, IPCB, IACB2, STATUS )

*  Set a new full data type for the data and variance arrays of the new
*  NDF. Since the NDF has only just been created, we know its array
*  component are not mapped, so we do not need to check.
      CALL ARY_STYPE( TYPE, ACB_DID( IACB2 ), STATUS )
      CALL NDF1_VSFTP( TYPE, IACB2, STATUS )

*  If the variance component does not exist, we only need to loop over
*  one array component (DATA).
      CALL NDF1_VSTA( IACB1, THERE, STATUS )
      IF( THERE ) THEN
         NCOMP = 2
      ELSE
         NCOMP = 1
      END IF

*  Loop to scale the DATA and VARIANCE arrays
      DO ICOMP = 1, NCOMP

*  If this is the VARIANCE component, report an error if the input
*  VARIANCE array is not stored in SIMPLE form.
         IF( ICOMP .EQ. 2 ) THEN
            CALL NDF1_VFRM( IACB1, FORM, STATUS )
            IF( FORM .NE. 'SIMPLE' .AND. STATUS .EQ. SAI__OK ) THEN
               STATUS = NDF__BADSF
               CALL MSG_SETC( 'F', FORM )
               CALL ERR_REP( 'NDF_ZSCAL_ERR2', 'The NDF is already '//
     :                       'compressed (using ^F compression).',
     :                       STATUS )
            END IF
         END IF

*  Determine the numeric type of the input array.
         CALL NDF1_TYP( IACB1, COMP( ICOMP ), INTYPE, STATUS )

*  Map the input array for READ access.
         CALL NDF1_MAP( IACB1, COMP( ICOMP ), DATYP( INTYPE ), .FALSE.,
     :                  'READ', PNTR1, PNTR1, STATUS )

*  Map the output array for WRITE access.
         CALL NDF1_MAP( IACB2, COMP( ICOMP ), TYPE, .FALSE., 'WRITE',
     :                  PNTR2, PNTR2, STATUS )

*  Calculate the number of array elements.
         CALL ARY_SIZE( ACB_DID( IACB1 ), EL, STATUS )

*  Scale the input array, storing the results in the output array. If
*  necessary, default scale and zero terms are found and returned.
         CALL NDF1_ZSCAL( INTYPE, PNTR1, EL, OUTTYP, SCALE( ICOMP ),
     :                    ZERO( ICOMP ), PNTR2, STATUS )

*  Unmap the input and output arrays. */
         CALL NDF1_UMP( IACB1, COMP( ICOMP ), STATUS )
         CALL NDF1_UMP( IACB2, COMP( ICOMP ), STATUS )

      END DO

*  Store the scale and zero terms with the output NDF.
      CALL NDF1_ZPSCA( IACB2, INTYPE, SCALE, ZERO, STATUS )

*  Export an identifier for the new NDF.
      CALL NDF1_EXPID( IACB2, INDF2, STATUS )

*  If an error occurred, then annul any ACB entry which may have been
*  acquired.
      IF( STATUS .NE. SAI__OK ) THEN
         CALL NDF1_ANL( IACB2, STATUS )
      END IF

*  Annul the placeholder, erasing the associated object if any error has
*  occurred.
      IF( IPCB .NE. 0 ) THEN
         ERASE = ( STATUS .NE. SAI__OK )
         CALL NDF1_ANNPL( ERASE, IPCB, STATUS )
      END IF

*  Reset the PLACE argument.
      PLACE = NDF__NOPL

*  If an error occurred, reset the INDF2 argument, report the error context
*  and call the error tracing routine.
      IF( STATUS .NE. SAI__OK ) THEN
         INDF2 = NDF__NOID
         CALL ERR_REP( 'NDF_ZSCAL_ERR', 'NDF_ZSCAL: Error compressing'//
     :                 ' an NDF using the SCALE algorithm.', STATUS )
         CALL NDF1_TRACE( 'NDF_ZSCAL', STATUS )
      END IF

      END
