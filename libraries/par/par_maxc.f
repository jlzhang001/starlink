      SUBROUTINE PAR_MAXC( PARAM, VALUE, STATUS )
*+
*  Name:
*     PAR_MAXx
 
*  Purpose:
*     Sets a maximum value for a parameter.
 
*  Language:
*     Starlink Fortran 77
 
*  Invocation:
*     CALL PAR_MAXx( PARAM, VALUE, STATUS )
 
*  Description:
*     This routine sets a maximum value for the specified parameter.
*     The value will be used as an upper limit for any value
*     subsequently obtained for the parameter.
*
*     If the routine fails, any existing maximum value will be unset.
*
*  Arguments:
*     PARAM = CHARACTER*(*) (Given)
*        The parameter name.
*     VALUE = ? (Given)
*        The value to be set as the maximum.  It must not be outside
*        any RANGE specified for the parameter in the interface file.
*     STATUS = INTEGER (Given and Returned)
*        The global status.
 
*  Notes:
*     -  There is a routine for each of the data types character,
*     integer, real, and double precision: replace "x" in the routine
*     name by C, I, R, or D respectively as appropriate.  The VALUE
*     argument must have the corresponding data type.  If the parameter
*     has a different type, the maximum value will be converted to the
*     type of the parameter which must be character, double precision,
*     integer, or real.
*     -  If a minimum value has been set (using PAR_MINx) that is
*     greater than the maximum at the time the parameter value is
*     obtained, only values between the limits will not be permitted.
*     -  The maximum value set by this routine overrides any upper
*     RANGE value which may have been specified in the interface file.
*     The specified value must not be outside any RANGE values.  The
*     maximum value may also be selected as the parameter value---again
*     in preference to any upper RANGE value---by specifying MAX as the
*     parameter value on the command line or in response to a prompt.
*
*  Implementation Deficiencies:
*     {routine_deficiencies}...
 
*  Authors:
*     AJC: A J Chipperfield (STARLINK)
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}
 
*  History:
*     28-SEP-1990 (AJC):
*        Original version.
*     1993 May 7 (MJC):
*        Minor rearrangement of the documentation for consistency.
*     1993 May 26 (MJC):
*        Added note concerning the minimum being greater than the
*        maximum.
*     {enter_further_changes_here}
 
*  Bugs:
*     {note_any_bugs_here}
 
*-
 
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing
 
*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
 
*  Arguments Given:
      CHARACTER * ( * ) PARAM
      CHARACTER*(*) VALUE
 
*  Status:
      INTEGER STATUS             ! Global status
 
*  Local Variables:
      INTEGER NAMCOD             ! Parameter index
 
*.
 
*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN
 
*  Find the parameter-system pointer to the internal parameter space
*  associated with the parameter.
      CALL SUBPAR_FINDPAR( PARAM, NAMCOD, STATUS )
 
*  Set the maximum value for the parameter.
      CALL SUBPAR_MAXC( NAMCOD, VALUE, STATUS )
 
      END
