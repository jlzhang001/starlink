	SUBROUTINE FITSWSUB( TAPEORDISK, MTCHAN, LUNO, DIMSX, DIMSY, 
     :    DATAARRAY, BZERO, BSCALE, ARRAY, INST, PLATESCALE, 
     :    OBSERVERS, ORIGIN, SOFTWARE, HEIGHT, LAT, LONG, TELESCOPE, 
     :	  BIAS, CONF, MAX, MIN, DEC, AIRMASS, EQUINOX, EVENMEAN, 
     :    EVENSTD, EXPO, FILTER, GAIN, GATE, LOCALTIME, MODE, 
     :    COADDS, OBJECT, ODDMEAN, ODDSTD, OFFSETDEC, OFFSETRA, RA, 
     :    READRATE, TEMP, TITLE, IMAGENAME, UT, HA, ST, FPX, FPY, 
     :    FPZ, XHEAD_ARCSECPMM, XHEAD_DEC_ZERO, XHEAD_RA_ZERO,
     :	  XHEAD_DEC, XHEAD_RA, COMMENTS, SWAPBYTES)
	IMPLICIT NONE

	INTEGER MTCHAN, LUNO, DIMSX, DIMSY

	REAL DATAARRAY( DIMSX, DIMSY), BZERO, BSCALE, PLATESCALE, HEIGHT,
     :	 LAT( 3), LONG( 3), BIAS, MAX, MIN, DEC( 3), EQUINOX, 
     :   EVENMEAN, EVENSTD, EXPO, GAIN, GATE, COADDS, ODDMEAN, 
     :   ODDSTD, RA( 3), READRATE, TEMP, AIRMASS, UT( 4), OFFSETRA, 
     :   OFFSETDEC, XHEAD_ARCSECPMM, XHEAD_DEC_ZERO, XHEAD_RA_ZERO, 
     :   XHEAD_DEC, XHEAD_RA, HA( 3), ST( 3), FPX, FPY, FPZ

	CHARACTER*( *) TAPEORDISK, CONF, MODE, ARRAY, INST, OBSERVERS, 
     :	           ORIGIN, SOFTWARE, TELESCOPE, FILTER, LOCALTIME, 
     :	           OBJECT, TITLE, IMAGENAME

	CHARACTER*80 COMMENTS( 5)

	LOGICAL SWAPBYTES

*   Write FITS header for this file

	CALL FITSWHEAD( TAPEORDISK, MTCHAN, LUNO, DIMSX, DIMSY, BZERO, BSCALE, 
     :	            ARRAY, INST, PLATESCALE, OBSERVERS, ORIGIN, SOFTWARE, 
     :	            HEIGHT, LAT, LONG, TELESCOPE, BIAS, CONF, MAX, MIN, 
     :	            DEC, AIRMASS, EQUINOX, EVENMEAN, EVENSTD, EXPO, 
     :              FILTER, GAIN, GATE, LOCALTIME, MODE, COADDS, OBJECT, 
     :	            ODDMEAN, ODDSTD, OFFSETDEC, OFFSETRA, RA, READRATE, 
     :	            TEMP, TITLE, IMAGENAME, UT, HA, ST, FPX, FPY, FPZ,
     :	            XHEAD_ARCSECPMM, XHEAD_DEC_ZERO, XHEAD_RA_ZERO,
     :	            XHEAD_DEC, XHEAD_RA, COMMENTS)

*   Write array to tape

	CALL FITSWARRAY( TAPEORDISK, MTCHAN, LUNO, BZERO, BSCALE, DATAARRAY, 
     :	                 DIMSX, DIMSY, SWAPBYTES)

	END
