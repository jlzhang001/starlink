/*
 * C error define file for facility NBS (1802)
 * Generated by the MESSGEN utility
 */

#ifndef NBS_ERROR_DEFINED
#define NBS_ERROR_DEFINED

/* noticeboard already existed */
#define NBS__SECTIONEXISTED	252347171	/* messid=100 */

/* more dimensions than maximum allowed */
#define NBS__TOOMANYDIMS	252347968	/* messid=200 */

/* more bytes than maximum allowed */
#define NBS__TOOMANYBYTES	252347976	/* messid=201 */

/* offset is less than zero */
#define NBS__BADOFFSET 	252347984	/* messid=202 */

/* illegal parameter / item name */
#define NBS__BADOPTION 	252347992	/* messid=203 */

/* data part of noticeboard not saved - cannot restore it */
#define NBS__DATANOTSAVED	252348000	/* messid=204 */

/* currently defining noticeboard contents */
#define NBS__DEFINING  	252348770	/* messid=300 */

/* not currently defining noticeboard contents */
#define NBS__NOTDEFINING	252348778	/* messid=301 */

/* NIL static ID */
#define NBS__NILSID    	252348786	/* messid=302 */

/* NIL item ID */
#define NBS__NILID     	252348794	/* messid=303 */

/* item is primitive */
#define NBS__PRIMITIVE 	252348802	/* messid=304 */

/* item is not primitive */
#define NBS__NOTPRIMITIVE	252348810	/* messid=305 */

/* item does not exist */
#define NBS__ITEMNOTFOUND	252348818	/* messid=306 */

/* noticeboard does not exist */
#define NBS__SECTIONNOTFOUND	252348826	/* messid=307 */

/* can't open noticeboard definition file */
#define NBS__CANTOPEN  	252348834	/* messid=308 */

/* can't write noticeboard definition file */
#define NBS__CANTWRITE 	252348842	/* messid=309 */

/* can't read noticeboard definition file */
#define NBS__CANTREAD  	252348850	/* messid=310 */

/* non-owner attempted to alter noticeboard */
#define NBS__NOTOWNER  	252348858	/* messid=311 */

/* time out finding noticeboard or getting item value or shape */
#define NBS__TIMEOUT   	252348866	/* messid=312 */

/* data part of noticeboard saved - cannot restore definition */
#define NBS__DATASAVED 	252348874	/* messid=313 */

/* data was not restored from noticeboard file - cannot save it */
#define NBS__DATANOTRESTORED	252348882	/* messid=314 */

/* item / noticeboard has items derived from it - cannot lose it */
#define NBS__HASIDS    	252348890	/* messid=315 */

/* item is not top-level (ie not noticeboard) - cannot lose it */
#define NBS__NOTTOPLEVEL	252348898	/* messid=316 */

/* item is top-level (ie noticeboard) - cannot lose it */
#define NBS__TOPLEVEL  	252348906	/* messid=317 */

/* parent has no items derived from it - cannot lose it */
#define NBS__NEVERFOUND	252348914	/* messid=318 */

/* couldn't initialise storage allocator */
#define NBS__INITALLOCFAILED	252349572	/* messid=400 */

/* couldn't get memory - increase MAX_DEFN_SIZE if when defining */
#define NBS__NOMOREROOM	252349580	/* messid=401 */

/* noticeboard or definition file had wrong version */
#define NBS__BADVERSION	252349588	/* messid=402 */

/* something impossible happened - system error */
#define NBS__IMPOSSIBLE	252349596	/* messid=403 */

#endif	/* NBS_ERROR_DEFINED */
