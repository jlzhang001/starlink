      SUBROUTINE PARSECON_SETPTY ( ENTRY, STATUS )
*+
*  Name:
*     PARSECON_SETPTY

*  Purpose:
*     Sets-up parameter PTYPE.

*  Language:
*     VAX Fortran

*  Invocation:
*     CALL PARSECON_SETPTY ( ENTRY, STATUS )

*  Description:
*     Loads the provided string into the PTYPE store for the most
*     recently declared program parameter.

*  Arguments:
*     ENTRY=CHARACTER*(*) (given)
*        Physical device type specifier
*     STATUS=INTEGER

*  Algorithm:
*     Superfluous quotes are removed from the given string, and the
*     result is put, in upper case, into the array holding PTYPE.

*  Copyright:
*     Copyright (C) 1984, 1990, 1992, 1993 Science & Engineering Research Council.
*     All Rights Reserved.

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
*     Foundation, Inc., 59 Temple Place,Suite 330, Boston, MA
*     02111-1307, USA

*  Authors:
*     B.D.Kelly (REVAD::BDK)
*     A J Chipperfield (STARLINK)
*     {enter_new_authors_here}

*  History:
*     19.09.1984:  Original (REVAD::BDK)
*     16.10.1990:  define QUOTE portably
*        convert all strings to upper case
*        use CHR for conversion (RLVAD::AJC)
*     27.02.1992:  assume ENTRY is ucase unless quoted string (RLVAD::AJC)
*     24.03.1993:  Add DAT_PAR for SUBPAR_CMN
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE


*  Global Constants:
      INCLUDE 'SAE_PAR'
      INCLUDE 'DAT_PAR'


*  Arguments Given:
      CHARACTER*(*) ENTRY             ! the PTYPE string


*  Status:
      INTEGER STATUS


*  Global Variables:
      INCLUDE 'SUBPAR_CMN'


*  External References:
*     None


*  Local Constants:
      CHARACTER*(*) QUOTE
      PARAMETER ( QUOTE = '''' )

*.


      IF ( STATUS .NE. SAI__OK ) RETURN

*
*   If ENTRY is a quoted string, process the quotes
*   and convert to upper case
      IF ( ENTRY(1:1) .EQ. QUOTE ) THEN

         CALL STRING_STRIPQUOT ( ENTRY, PARPTY(PARPTR), STATUS )
         CALL CHR_UCASE( PARPTY(PARPTR) )

      ELSE

         PARPTY(PARPTR) = ENTRY

      ENDIF

      END
