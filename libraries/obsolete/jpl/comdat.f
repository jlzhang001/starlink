C-------------------------- BLOCK DATA SUBPROGRAM 'COMDAT' -------------
C
C++++++++++++++++++++++++++++
C
      BLOCK DATA COMDAT
C
C++++++++++++++++++++++++++++
C
C     THIS BLOCK DATA PROGRAM INITIALIZES VARIOUS COMMON-AREA VARIABLES
C
C       KSIZE = SIZE OF EPHEMERIS BUFFER (S.P. WORDS)
C
      PARAMETER (KSIZE=1652)
C
C       COMMON AREA FOR BUFFER ASSIGNMENT
C
      INTEGER IBSZ
      INTEGER IB(KSIZE)
*
*  Variables re-ordered to avoid alignment problems.  Elsewhere,
*  this has also necessitated an explicit 1652 instead of KBSIZE.
*
*  P.T.Wallace   Starlink   14 April 1994
*
      COMMON/EPCOMM/IB,IBSZ
C
C       'PLEPH' COMMON AREA FOR POSITION/VELOCITY SWITCH
C
      INTEGER IPV
      COMMON/PLECOM/IPV
C
C       'STATE' COMMON AREA FOR KM AND SS-BARYCENTER FLAGS
C
      LOGICAL KM
      LOGICAL BARY
      DOUBLE PRECISION PVSUN(3,2)
      COMMON/STCOMM/KM,BARY,PVSUN
C
C       'EPHOPN' COMMON AREA FOR EPHEMERIS UNIT NUMBER
C
      INTEGER FILE
      COMMON/EPUNIT/FILE
C
C       DATA STATEMENTS INITIALIZING COMMON
C
      DATA IBSZ/KSIZE/
      DATA IPV/2/
      DATA KM/.FALSE./
      DATA BARY/.FALSE./
      DATA FILE/12/
C
      END