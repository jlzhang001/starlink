      SUBROUTINE PAR_GETNC ( PARAM, NDIM, MAXD, VALUES, ACTD, STATUS )
*+
*  Name:
*     PAR_GETNx
 
*  Purpose:
*     Obtains an array parameter value.
 
*  Language:
*     Starlink Fortran 77
 
*  Invocation:
*     CALL PAR_GETNx( PARAM, NDIM, MAXD, VALUES, ACTD, STATUS )
 
*  Description:
*     This routine obtains an n-dimensional array of values from a
*     parameter.  If necessary, the values are converted to the
*     required type.
 
*  Arguments:
*     PARAM = CHARACTER * ( * ) (Given)
*        The parameter name.
*     NDIM = INTEGER (Given)
*        The number of dimensions of the values array.
*        This must match the number of dimensions of the parameter.
*     MAXD( NDIM ) = INTEGER (Given)
*        Array specifying the maximum dimensions of the array to be
*        read. These may not be smaller than the dimensions of the
*        actual parameter nor greater than the dimensions of the VALUES
*        array.
*     VALUES( * ) = ? (Returned)
*        The values obtained from the parameter.  These are in Fortran
*        order.
*     ACTD( NDIM ) = INTEGER (Returned)
*        The actual dimensions of the array.  Unused dimensions are set
*        to 1.
*     STATUS = INTEGER
*        The global status.
 
*  Notes:
*     -  There is a routine for each of the data types character,
*     double precision, integer, logical, and real: replace "x" in the
*     routine name by C, D, I, L, or R respectively as appropriate.  The
*     VALUES argument must have the corresponding data type.
*     -  Note that this routine will accept a scalar value, returning
*     a single-element array with the specified number of dimensions.
 
*  Algorithm:
*     Call the underlying parameter-system primitives.
 
*  Authors:
*     BDK: B D Kelly (REVAD::BDK)
*     AJC: A J Chipperfield (STARLINK)
*     MJC: Malcolm J. Currie (STARLINK)
*     {enter_new_authors_here}
 
*  History:
*     7-NOV-1984 (BDK):
*        Original version.
*     2-JUN-1988 (AJC):
*        Revised prologue.
*     9-NOV-1990 (AJC):
*        Revised prologue again
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
      IMPLICIT NONE              ! No implicit typing
 
*  Global Constants:
      INCLUDE 'SAE_PAR'          ! Standard SAE constants
 
*  Arguments Given:
      CHARACTER * ( * ) PARAM
      INTEGER NDIM
      INTEGER MAXD( * )
 
*  Arguments Returned:
      CHARACTER*(*) VALUES( * )
      INTEGER ACTD( * )
 
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
 
*  Use the pointer to get the array of values.
      CALL SUBPAR_GETNC( NAMCOD, NDIM, MAXD, VALUES, ACTD, STATUS )
 
      END
