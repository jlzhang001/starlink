



      SUBROUTINE PDA_DB2VAL(XVAL,YVAL,IDX,IDY,TX,TY,
     :                      NX,NY,KX,KY,BCOEF,WORK,
     :                      RVALUE,IFAIL,STATUS)
C***BEGIN PROLOGUE  DB2VAL
C***DATE WRITTEN   25 MAY 1982
C***REVISION DATE  25 MAY 1982
C***CATEGORY NO.  E1A
C***KEYWORDS  INTERPOLATION, TWO-DIMENSIONS, GRIDDED DATA, SPLINES,
C             PIECEWISE POLYNOMIALS
C***AUTHOR  BOISVERT, RONALD, NBS
C             SCIENTIFIC COMPUTING DIVISION
C             NATIONAL BUREAU OF STANDARDS
C             WASHINGTON, DC 20234
C***PURPOSE  DB2VAL EVALUATES THE PIECEWISE POLYNOMIAL INTERPOLATING
C            FUNCTION CONSTRUCTED BY THE ROUTINE DB2INK OR ONE OF ITS
C            PARTIAL DERIVATIVES.
C            DOUBLE PRECISION VERSION OF B2VAL.
C***DESCRIPTION
C
C   DB2VAL  evaluates   the   tensor   product   piecewise   polynomial
C   interpolant constructed  by  the  routine  DB2INK  or  one  of  its
C   derivatives at the point (XVAL,YVAL). To evaluate  the  interpolant
C   itself, set IDX=IDY=0, to evaluate the first partial  with  respect
C   to x, set IDX=1,IDY=0, and so on.
C
C   DB2VAL returns 0.0E0 if (XVAL,YVAL) is out of range. That is, if
C            XVAL.LT.TX(1) .OR. XVAL.GT.TX(NX+KX) .OR.
C            YVAL.LT.TY(1) .OR. YVAL.GT.TY(NY+NY)
C   If the knots TX  and  TY  were  chosen  by  DB2INK,  then  this  is
C   equivalent to
C            XVAL.LT.X(1) .OR. XVAL.GT.X(NX)+EPSX .OR.
C            YVAL.LT.Y(1) .OR. YVAL.GT.Y(NY)+EPSY
C   where EPSX = 0.1*(X(NX)-X(NX-1)) and EPSY = 0.1*(Y(NY)-Y(NY-1)).
C
C   The input quantities TX, TY, NX, NY, KX, KY, and  BCOEF  should  be
C   unchanged since the last call of DB2INK.
C
C
C   I N P U T
C   ---------
C
C   XVAL    Double precision scalar
C           X coordinate of evaluation point.
C
C   YVAL    Double precision scalar
C           Y coordinate of evaluation point.
C
C   IDX     Integer scalar
C           X derivative of piecewise polynomial to evaluate.
C
C   IDY     Integer scalar
C           Y derivative of piecewise polynomial to evaluate.
C
C   TX      Double precision 1D array (size NX+KX)
C           Sequence of knots defining the piecewise polynomial in
C           the x direction.  (Same as in last call to DB2INK.)
C
C   TY      Double precision 1D array (size NY+KY)
C           Sequence of knots defining the piecewise polynomial in
C           the y direction.  (Same as in last call to DB2INK.)
C
C   NX      Integer scalar
C           The number of interpolation points in x.
C           (Same as in last call to DB2INK.)
C
C   NY      Integer scalar
C           The number of interpolation points in y.
C           (Same as in last call to DB2INK.)
C
C   KX      Integer scalar
C           Order of polynomial pieces in x.
C           (Same as in last call to DB2INK.)
C
C   KY      Integer scalar
C           Order of polynomial pieces in y.
C           (Same as in last call to DB2INK.)
C
C   BCOEF   Double precision 2D array (size NX by NY)
C           The B-spline coefficients computed by DB2INK.
C
C   WORK    Double precision 1D array (size 3*max(KX,KY) + KY)
C           A working storage array.
C
C   IFAIL   A returned error value.
C
C   RVALUE  The interpolated value.
C
C   STATUS  Integer. Starlink status report.
C
C***REFERENCES  CARL DE BOOR, A PRACTICAL GUIDE TO SPLINES,
C                 SPRINGER-VERLAG, NEW YORK, 1978.
C***ROUTINES CALLED  DINTRV,DBVAL2
C***END PROLOGUE  DB2VAL
C
C  ------------
C  DECLARATIONS
C  ------------

C  Starlink error status.
      INTEGER STATUS

C
C  PARAMETERS
C
      INTEGER          IFAIL
      DOUBLE PRECISION RVALUE,VALUE

      INTEGER          IDX,IDY,NX,NY,KX,KY
      DOUBLE PRECISION XVAL,YVAL,TX(1),TY(1),BCOEF(NX,NY),WORK(1)

C
C  LOCAL VARIABLES
C
      INTEGER         ILOY,INBVX,INBV,K,LEFTY,MFLAG,KCOL,IW
C
      DATA ILOY /1/,  INBVX /1/
C     SAVE ILOY    ,  INBVX
C
C
C***FIRST EXECUTABLE STATEMENT

*   Check the inherited global status.
      IF (STATUS.NE.0) RETURN

*   Clear interpolated value.
      RVALUE=0.0D0

      CALL PDA_DINTRV(TY,NY+KY,YVAL,ILOY,LEFTY,MFLAG)

      IF (MFLAG .NE. 0) GO TO 100
         IW = KY + 1
         KCOL = LEFTY - KY
         DO 50 K=1,KY
            KCOL = KCOL + 1
            CALL PDA_DBVAL2(TX,BCOEF(1,KCOL),NX,
     :                      KX,IDX,XVAL,INBVX,
     :                      WORK(IW),VALUE,IFAIL)
            WORK(K)=VALUE
  50     CONTINUE
         INBV = 1
         KCOL = LEFTY - KY + 1
         CALL PDA_DBVAL2(TY(KCOL),WORK,KY,KY,IDY,
     :                      YVAL,INBV,WORK(IW),VALUE,IFAIL)
         RVALUE=VALUE
  100 CONTINUE

*   Set up the status value.
      IF (IFAIL.NE.0) STATUS=1

      END
