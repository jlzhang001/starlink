      SUBROUTINE PAR_GETVI( PARAM, MAXVAL, VALUES, ACTVAL, STATUS )
*+
*  Name:
*     PAR_GETVx
 
*  Purpose:
*     Obtains a vector of values from a parameter regardless of the
*     its shape.
 
*  Language:
*     Starlink Fortran 77
 
*  Invocation:
*     CALL PAR_GETVx( PARAM, MAXVAL, VALUES, ACTVAL, STATUS )
 
*  Description:
*     This routine obtains an array of values from a parameter
*     as if the parameter were vectorized (i.e. regardless of its
*     dimensionality).  If necessary, the values are converted to the
*     required type.
 
*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The parameter name.
*     MAXVAL = INTEGER (Given)
*        The maximum number of values that can be held in the values
*        array.
*     VALUES( MAXVAL ) = ? (Returned)
*        Array to receive the values associated with the object.
*     ACTVAL = INTEGER (Returned)
*        The actual number of values obtained.
*     STATUS = INTEGER (Given and Returned)
*        The global status.
 
*  Notes:
*     -  There is a routine for each of the data types character,
*     double precision, integer, logical, and real: replace "x" in the
*     routine name by C, D, I, L, or R respectively as appropriate.  The
*     VALUES argument must have the corresponding data type.
*     -  Note that this routine will accept a scalar value, returning
*     a single-element vector.
 
*  Algorithm:
*     Call the underlying parameter-system primitives.
 
*  Authors:
*     BDK: B D Kelly (REVAD::BDK)
*     AJC: A J Chipperfield (STARLINK)
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}
 
*  History:
*     19-NOV-1984 (BDK):
*        Original version.
*     1-JUN-1988 (AJC):
*        Check import status
*        Revised prologue.
*     9-NOV-1990 (AJC):
*        Revised prologue again
*     1992 March 27 (MJC):
*        Used SST prologues.
*     1992 November 13 (MJC):
*        Commented the code, and renamed the NAMECODE identifier.
*        Re-tidied the prologue.  Removed sticky and unused DAT_ERR
*        include file.
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
      INTEGER MAXVAL
 
*  Arguments Returned:
      INTEGER VALUES( * )
      INTEGER ACTVAL
 
*  Status:
      INTEGER STATUS             ! Global status
 
*  Local Variables:
      INTEGER NAMCOD             ! Pointer to parameter
 
*.
 
*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN
 
*  Find the parameter-system pointer to the internal parameter space
*  associated with the parameter.
      CALL SUBPAR_FINDPAR( PARAM, NAMCOD, STATUS )
 
*  Use the pointer to get the array of values, as if it were a vector.
      CALL SUBPAR_GETVI( NAMCOD, MAXVAL, VALUES, ACTVAL, STATUS )
 
      END
