C------------------------------- SUBROUTINE 'JTOC' ---------------------
C
C+++++++++++++++++++
C
      SUBROUTINE JTOC(JD,DATE,SECS,FLAG)
C
C++++++++++++++++++++++++++++++
C
C     THIS SUBROUTINE CONVERTS JULIAN DAY NUMBER TO CALENDAR DATE.
C
C     CALLING SEQUENCE PARAMETERS:
C
C     INPUT:
C
C         JD = JULIAN DATE AT WHICH CALENDAR DATE IS WANTED
C
C       FLAG = INTEGER CONTROLLING CALENDAR USED IN CONVERSION:
C
C               -1 => ALL DATES EXPRESSED IN JULIAN CALENDAR
C               +1 => ALL DATES EXPRESSED IN GREGORIAN CALENDAR
C                0 => AUTOMATIC MODE, WHERE DATES BEFORE JD 2299160
C                     (OCT 4, 1582) ARE JULIAN AND LATER DATES ARE
C                     GREGORIAN
C
C     OUTPUT:
C
C       DATE = 5-WD INTEGER ARRAY WITH MONTH, DAY, YEAR, HOUR, MINUTE
C              OF RESULTING ASTRONOMICAL CALENDAR DATE
C
C       SECS = D.P. SECONDS, INCLUDING FRACTION; E.G., 51.206
C
C     RESTRICTIONS - INPUT JULIAN CALENDAR MUST BE FOR A POSITIVE
C                    JULIAN DAY NUMBER. FOR GREGORIAN CALENDAR,
C                    JD > 1721119 (DATES MUST BE A.D.)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C       CALLING SEQUENCE DECLARATIONS
C
      DOUBLE PRECISION JD
      INTEGER DATE(5)
      DOUBLE PRECISION SECS
      INTEGER FLAG
C
C
      DT=JD+.500000000100D0
      J=IDINT(DT)
      DJA=DBLE(J)
      DT=(DT-DJA)*24.D0
      DATE(4)=IDINT(DT)
      DJA=DBLE(DATE(4))
      DT=(DT-DJA)*60.D0
      DATE(5)=IDINT(DT)
      DJA=DBLE(DATE(5))
      SECS=(DT-DJA)*60.D0
C
      IF(FLAG.LT.0 .OR. (FLAG.EQ.0 .AND. JD.LT.2299160.5D0)) THEN
        IY=4*(J+105498)/1461-5001
        IDY=J-(36525*(IY+5000))/100+105133
      ELSE
        IY=4*(J-1720754+3*(4*(J-1721119)/146097+1)/4)/1461-1
        IDY=J-36525*IY/100+3*(IY/100+1)/4-1721119
      ENDIF
C
      M=(5*IDY-3)/153+3
      DATE(2)=IDY-(153*(M-3)+2)/5
      IF(M.GE.13) M=M-12
      IF(M.LE.2) IY=IY+1
C
      DATE(1)=M
      DATE(3)=IY
C
      RETURN
C
      END