      SUBROUTINE USI_NAMES( MODE, STRNGS, STATUS )
*+
*  Name:
*     USI_NAMES

*  Purpose:
*     Construct an ADI string array of USI input or output filenames

*  Language:
*     Starlink Fortran

*  Invocation:
*     CALL USI_NAMES( MODE, STRNGS, STATUS )

*  Description:
*     {routine_description}

*  Arguments:
*     MODE = CHARACTER*(*) (given)
*        Access mode of parameters to list, either I or O
*     STRNGS = INTEGER (returned)
*        ADI identifier of string array
*     STATUS = INTEGER (given and returned)
*        The global status.

*  Examples:
*     {routine_example_text}
*        {routine_example_description}

*  Pitfalls:
*     {pitfall_description}...

*  Notes:
*     {routine_notes}...

*  Prior Requirements:
*     {routine_prior_requirements}...

*  Side Effects:
*     {routine_side_effects}...

*  Algorithm:
*     {algorithm_description}...

*  Accuracy:
*     {routine_accuracy}

*  Timing:
*     {routine_timing}

*  External Routines Used:
*     {name_of_facility_or_package}:
*        {routine_used}...

*  Implementation Deficiencies:
*     {routine_deficiencies}...

*  References:
*     USI Subroutine Guide : http://www.sr.bham.ac.uk/asterix-docs/Programmer/Guides/usi.html

*  Keywords:
*     package:usi, usage:public

*  Copyright:
*     Copyright (C) University of Birmingham, 1995

*  Authors:
*     DJA: David J. Allan (Jet-X, University of Birmingham)
*     {enter_new_authors_here}

*  History:
*      4 Jan 1996 (DJA):
*        Original version.
*     {enter_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
      INCLUDE 'DAT_PAR'

*  Global Variables:
      INCLUDE 'USI_CMN'                                 ! USI common block

*  Arguments Given:
      CHARACTER*(*)		MODE

*  Arguments Returned:
      INTEGER			STRNGS

*  Status:
      INTEGER 			STATUS             	! Global status

*  External References:
      EXTERNAL			CHR_LEN
        INTEGER			CHR_LEN

*  Local Constants:
      CHARACTER*1		NUL
        PARAMETER		( NUL = CHAR(0) )

*  Local Variables:
      CHARACTER*4		FSTR			! File number string
      CHARACTER*1		LMODE			! Local copy of MODE
      CHARACTER*255		NAME, PATH		! Trace info

      INTEGER			CID			! Array cell identifier
      INTEGER			FNDIG			! # digits used in FSTR
      INTEGER			I			! Loop over USI slots
      INTEGER			LEVELS			! Trace depth
      INTEGER			NLINE			! # lines of text
*.

*  Check inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Make local capitalised copy of mode
      LMODE = MODE(1:1)
      CALL CHR_UCASE( LMODE )

*  Count the number of files matching the mode
      NLINE = 0
      DO I = 1, USI__NMAX
        IF ( DS(I).USED .AND. (DS(I).IO.EQ.LMODE) ) NLINE = NLINE + 1
      END DO

*  Create return value
      CALL ADI_NEW1C( NLINE, STRNGS, STATUS )

*  Count the number of files matching the mode
      NLINE = 0
      DO I = 1, USI__NMAX
        IF ( DS(I).USED .AND. (DS(I).IO.EQ.LMODE) ) THEN

*      Increment file counter
          NLINE = NLINE + 1
          CALL CHR_ITOC( NFILE, FSTR, FNDIG )

*      Perform trace
          IF ( DS(I).ADIFPN ) THEN
            CALL ADI_FTRACE( DS(I).ADI_ID, LEVELS, PATH, NAME, STATUS )
          ELSE
            CALL HDS_TRACE( DS(I).LOC, LEVELS, PATH, NAME, STATUS )
          END IF

*      Locate character array cell
          CALL ADI_CELL( STRNGS, 1, NLINE, CID, STATUS )

*      Construct string separating bits with nulls
          IF ( LEVELS .GT. 1 ) THEN
            CALL ADI_PUT0C( CID, 'Input dataset '//FSTR(:FNDIG)//':'//
     :                      NUL//NAME(:CHR_LEN(NAME))//NUL//
     :                      'Input object '//FSTR(:FNDIG)//':'//NUL//
     :                      PATH(:CHR_LEN(PATH)), STATUS )
          ELSE
            CALL ADI_PUT0C( CID, 'Input dataset '//FSTR(:FNDIG)//':'//
     :                      NUL//NAME(:CHR_LEN(NAME)), STATUS )
          END IF

*      Release array cell
          CALL ADI_ERASE( CID, STATUS )

        END IF
      END DO

*  Report any errors
      IF ( STATUS .NE. SAI__OK ) CALL AST_REXIT( 'USI_NAMES', STATUS )

      END
