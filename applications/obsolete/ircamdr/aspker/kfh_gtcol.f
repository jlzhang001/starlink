*+  KFH_GTCOL - Get a colour from the user.
      SUBROUTINE KFH_GTCOL(COL,STATUS)
*    Description :
*     This subroutine prompts the user for a colour, which
*     is given in terms of red, green and blue intensities.
*     Each intensity is in the range 0 to 255.
*    Invocation :
*     CALL KFH_GTCOL(COL,STATUS)
*    Parameters :
*     COL(3) = INTEGER
*        This array returns the three intensities.
*     STATUS = INTEGER
*        This is the status value generated by the calls to
*        the environment routines.
*    Method :
*     The user is prompted for a set of three intensities.
*     There are basically three possible outcomes that need
*     to be considered:
*     1) The user gives a perfect response.
*        In this instance the subroutine is left, and the
*        three values returned.
*     2) The status is O.K. but there is something wrong with
*        the response. Here the user is asked to try again.
*     3) There is a bad status. In this case the subroutine
*        is left irrespective of the users enterred values.
*    Deficiencies :
*     The method of input does not seem the easiest possible.
*    Bugs :
*     <description of any "bugs" which have not been fixed>
*    Authors :
*     A.P.Horsfield (RGVAD::KFH)
*    History :
*     22 July 1983: Original (RGVAD::KFH)
*    Type Definitions :
      IMPLICIT NONE
*    Global constants :
      INCLUDE 'SAE_PAR'
*    Status :
      INTEGER STATUS
*    Local variables :
      INTEGER COL(3)			! The array returning
*					! the three intensities.
      INTEGER NUMVAL			! The number of values
*					! returned by the user.
      LOGICAL REPEAT			! Flag used in a DO
*					! WHILE loop to simulate
*					! a REPEAT..UNTIL loop.
*-

      REPEAT = .TRUE.

      DO WHILE (REPEAT)

*
*       Prompt user for a colour.
*

         CALL PAR_GET1I('RGB',3,COL,NUMVAL,STATUS)

*
*       If the status is bad then return.
*

         IF (STATUS.NE.SAI__OK) THEN

            REPEAT = .FALSE.

*
*       If the response is perfect then return.
*

         ELSEIF (COL(1).GE.0.AND.COL(1).LE.255.AND.
     :           COL(2).GE.0.AND.COL(2).LE.255.AND.
     :           COL(3).GE.0.AND.COL(3).LE.255) THEN

            REPEAT = .FALSE.

*
*       If the status is alright but the user has not given
*       a perfect response then prompt him again.
*

         ELSE

            CALL MSG_OUT('WARN','ILLEGAL COLOUR.',STATUS)
            CALL PAR_CANCL('RGB',STATUS)

         ENDIF

      ENDDO

      CALL PAR_CANCL('RGB',STATUS)

      END
