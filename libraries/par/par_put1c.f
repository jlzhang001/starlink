      SUBROUTINE PAR_PUT1C ( PARAM, NVAL, VALUES, STATUS )
*+
*  Name:
*     PAR_PUT1x
 
*  Purpose:
*     Puts a vector of values into a parameter.
 
*  Language:
*     Starlink Fortran 77
 
*  Invocation:
*     CALL PAR_PUT1x( PARAM, NVAL, VALUES, STATUS )
 
*  Description:
*     This routine puts a 1-dimensional array of values into a
*     parameter.  If necessary, the specified array is converted to
*     the type of the parameter.
 
*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The parameter name.
*     NVAL = INTEGER (Given)
*        The number of values that are to be put into the parameter.
*     VALUES( NVAL ) = ? (Given)
*        The array of values to be put into the parameter.
*     STATUS = INTEGER (Given and Returned)
*        The global status.
 
*  Notes:
*     -  There is a routine for each of the data types character,
*     double precision, integer, logical, and real: replace "x" in the
*     routine name by C, D, I, L, or R respectively as appropriate.  The
*     VALUES argument must have the corresponding data type.
*     - A scalar (0-dimensional) parameter is different from a vector
*     (1-dimensional) parameter containing a single value.
*     - In order to obtain a storage object for the parameter, the
*     current implementation of the underlying ADAM parameter system
*     will proceed in the same way as it does for input parameters.
*     This can result in users being prompted for 'a value'. This
*     behaviour, and how to avoid it, is discussed further in the
*     Interface Module Reference Manual (SUN/115).
*     -  Limit checks for IN, RANGE, MIN/MAX are not applied.
 
*  Algorithm:
*     Call the underlying parameter-system primitives.
 
*  Authors:
*     BDK: B D Kelly (REVAD::BDK)
*     AJC: A J Chipperfield (STARLINK)
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}
 
*  History:
*     18-NOV-1984 (BDK):
*        Original version.
*     1-JUN-1988 (AJC):
*        Check import status
*        Revised prologue.
*     9-NOV-1990 (AJC):
*        Revised prologue again
*     1992 March 27 (MJC):
*        Used SST prologues.
*     1992 November 9 (MJC):
*        Used PARAM as the first argument for consistency with other
*        routines.
*     1992 November 13 (MJC):
*        Commented the code, and renamed the NAMECODE identifier.
*        Re-tidied the prologue.
*     {enter_further_changes_here}
 
*  Bugs:
*     {note_any_bugs_here}
 
*-
 
*  Type Definitions:
      IMPLICIT NONE              ! No implicit typing
 
*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE Constants
 
*  Arguments Given:
      CHARACTER * ( * ) PARAM
      INTEGER NVAL
      CHARACTER*(*) VALUES( * )
 
*  Status:
      INTEGER STATUS              ! Global status
 
*  Local Variables:
      INTEGER NAMCOD              ! Pointer to the parameter
 
*.
 
*  Check the inherited global status.
      IF ( STATUS .NE. SAI__OK ) RETURN
 
*  Find the parameter-system pointer to the internal parameter space
*  associated with the parameter.
      CALL SUBPAR_FINDPAR( PARAM, NAMCOD, STATUS )
 
*  Use the pointer to put the values into the parameter.
      CALL SUBPAR_PUT1C( NAMCOD, NVAL, VALUES, STATUS )
 
      END
