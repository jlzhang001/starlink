      SUBROUTINE PAR_PROMT ( PARAM, PROMPT, STATUS )
*+
*  Name:
*     PAR_PROMT

*  Purpose:
*     Sets a new prompt string for a parameter.

*  Language:
*     Starlink Fortran 77

*  Invocation:
*     CALL PAR_PROMT( PARAM, PROMPT, STATUS )

*  Description:
*     Replace the prompt string for the indicated parameter by the
*     given string.

*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The parameter name.
*     PROMPT = CHARACTER * ( * ) (Given)
*        The new prompt string.
*     STATUS = INTEGER
*        The global status.

*  Algorithm:
*     Call the underlying parameter-system primitives to put the given
*     string into the common-block array holding prompts.

*  Implementation Deficiencies:
*     In the original SSE spec, token interpretation was done on the
*     prompt string using the MSG_ routines.

*  Authors:
*     B D Kelly (REVAD::BDK)
*     A J Chipperfield (STARLINK)
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}

*  History:
*     25-NOV-1985:
*        Original (BDK)
*     1-JUN-1988:
*        Revised prologue  (AJC)
*     7-JAN-1991:
*        Revised prologue again (AJC)
*     1992 March 27 (MJC):
*        Used SST prologues.
*     1992 November 13 (MJC):
*        Commented the code, and renamed the NAMECODE identifier.
*        Re-tidied the prologue.
*     {enter_further_changes_here}

*  Bugs:
*     {note_any_bugs_here}

*-

*  Type Definitions:
      IMPLICIT NONE               ! No implicit typing

*  Global Constants:
      INCLUDE 'SAE_PAR'           ! SAE standard constants

*  Arguments Given:
      CHARACTER * ( * ) PARAM     ! Name of the parameter
      CHARACTER * ( * ) PROMPT    ! Prompt string

*  Status:
      INTEGER STATUS              ! Global Status

*  Local Variables:
      INTEGER NAMCOD              ! Index to the parameter

*.

*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN

*  Find the parameter-system pointer to the internal parameter space
*  associated with the parameter.
      CALL SUBPAR_FINDPAR( PARAM, NAMCOD, STATUS )

*  Use the pointer to set the prompt string.
      CALL SUBPAR_PROMT( NAMCOD, PROMPT, STATUS )

      END
