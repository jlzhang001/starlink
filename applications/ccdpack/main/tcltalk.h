/*
*+
*  Name:
*     tcltalk.h

*  Type of Module:
*     C header file.

*  Purpose:
*     Include file for communication with ccdwish.

*  Description:
*     This include file declares the routines which can be used by 
*     calling C code to communicate with a ccdwish Tcl interpreter.
*     These routines should be used rather than directly using the Tcl 
*     library routines declared in tcl.h and the Tcl documentation.

*  Authors:
*     MBT: Mark Taylor (STARLINK)

*  History:
*     10-OCT-2000 (MBT):
*        Original version.
*-
*/

#ifndef CCD_TCLTALK_DEFINED
#define CCD_TCLTALK_DEFINED

/* The following constants must be distinct from legitimate TCL return codes,
   TCL_OK, TCL_ERROR, TCL_RETURN, TCL_BREAK and TCL_CONTINUE. */
#define CCD_CCDMSG 2112
#define CCD_CCDLOG 2113
#define CCD_CCDERR 2114

   typedef struct {
      int downfd[ 2 ];
      int upfd[ 2 ];
   } ccdTcl_Interp;


   ccdTcl_Interp *ccdTclStart( int *status );
   void ccdTclDo( ccdTcl_Interp *cinterp, int callret, int *status );
   void ccdTclStop( ccdTcl_Interp *cinterp, int *status );
   void ccdTclRun( ccdTcl_Interp *cinterp, char *filename, int *status );
   void ccdTclAppC( ccdTcl_Interp *cinterp, char *name, char *value, 
                    int *status );
   void ccdTclSetI( ccdTcl_Interp *cinterp, char *name, int value, 
                    int *status );
   void ccdTclSetD( ccdTcl_Interp *cinterp, char *name, double value, 
                    int *status );
   void ccdTclSetC( ccdTcl_Interp *cinterp, char *name, char *value, 
                    int *status );
   void ccdTclGetI( ccdTcl_Interp *cinterp, char *script, int *value, 
                    int *status );
   void ccdTclGetD( ccdTcl_Interp *cinterp, char *script, double *value, 
                    int *status );
   char *ccdTclGetC( ccdTcl_Interp *cinterp, char *script, int *status );
#define ccdTclDo(cinterp,script,status) \
   (void) ccdTclGetC( cinterp, script, status )

#endif  /* CCD_TCLTALK_DEFINED */

/* $Id$ */
