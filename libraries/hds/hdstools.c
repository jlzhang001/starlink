#include "hds1_feature.h"	 /* Define feature-test macros, etc.	    */
/*+HDSTOOLS.C-*/

#include <string.h>
#include <stdio.h>
#include "f77.h"		 /* F77 <-> C interface macros		    */
#include "ems.h"		 /* EMS error reporting routines	    */
#include "hds1.h"		 /* Global definitions for HDS		    */
#include "rec.h"		 /* Public rec_ definitions		    */
#include "str.h"		 /* Character string import/export macros   */
#include "dat1.h"		 /* Internal dat_ definitions		    */
#include "dat_err.h"		 /* DAT__ error code definitions	    */

   F77_INTEGER_FUNCTION(hds_trace)( struct STR *locator_str, int *nlev,
                                    struct STR *path_str, struct STR *file_str,
				    int * status, int locator_lenarg,
				    int path_lenarg, int file_lenarg );

   F77_INTEGER_FUNCTION(hds_show)
                       (topic_str,status,topic_lenarg)

/*===============================*/
/* HDS_SHOW - Show HDS statistic */
/*===============================*/

struct STR		*topic_str;
int	  	     	*status;
int			 topic_lenarg;

{
#undef context_name
#undef context_message
#define context_name "HDS_SHOW_ERR"
#define context_message\
        "HDS_SHOW: Error displaying HDS statistics."

struct DSC		 topic;
int			 topic_len = topic_lenarg;

struct LCP		*lcp;
struct LCP_DATA		*data;
char			 name[DAT__SZNAM];
struct LOC		 loc;
struct STR	 	 locator;
struct STR	 	 path;
struct STR		 file;
int			 nlev;
int			 len;
int			 i;
int			 tracestat;

/* These buffers are only used when using VMS descriptors. */

#if defined( vms )
char	  		 lbuf[DAT__SZLOC];
char			 pbuf[STR_K_LENGTH];
char			 fbuf[STR_K_LENGTH];
#endif

/* Enter routine	*/

if (!_ok(*status))
	return *status;
hds_gl_status = DAT__OK;

/* Import the name of the statistic to be shown.	*/

_strimp(&topic,topic_str,&topic_len);

/* Initialise strings.	*/

_strinit(&locator, DAT__SZLOC, lbuf);
_strinit(&path, STR_K_LENGTH, pbuf);
_strinit(&file, STR_K_LENGTH, fbuf);

/* Ensure that HDS has been initialised.				    */
      if ( !hds_gl_active )
      {
         dat1_init( );
         if ( !_ok( hds_gl_status ) ) return hds_gl_status;
      }


/* Format the topic name and show the appropriate statistic.	*/
dau_check_name(&topic, name);

/* Display information about the native data representation.		    */
if ( _cheql( 4, name, "DATA" ) ) dat1_show_ndr( &hds_gl_status );

if (_cheql(4,name, "FILE"))
	rec_list_files( );
if (_cheql(4,name, "LOCA"))
	{
	lcp          = dat_ga_wlq;
	loc.check    = DAT__LOCCHECK;
	for (i=0; i<dat_gl_wlqsize; i++)
		{
		data                      = &lcp->data;
		if (!data->valid)
			lcp               = lcp->flink;
		else
			{
			loc.lcp           = lcp;
			loc.seqno = lcp->seqno;
			tracestat	  = DAT__OK;
			_chmove(DAT__SZLOC, &loc, locator.body);
			F77_CALL(hds_trace)(&locator, &nlev, &path,
				           &file, &tracestat, DAT__SZLOC,
					   STR_K_LENGTH, STR_K_LENGTH);
			if (!_ok(tracestat))
				*status   = tracestat;
			else
       				{
				len       = strchr(path.body, ' ') - path.body;
				if (len < 0)
					_call(DAT__TRUNC)
				_chcopy(8, ", group=", 0,
					STR_K_LENGTH-len,
					( (char *) path.body ) + len );
				_chcopy(DAT__SZGRP, data->group, 0,
					STR_K_LENGTH-8-len,
					( (char *) path.body ) + len + 8 );
				printf("%s\n",path.body);
				}
			lcp               = lcp->flink;
			}
		}
	}
return hds_gl_status;
}

   F77_INTEGER_FUNCTION(hds_trace)
                       (locator_str,nlev,path_str,file_str,status,
	   locator_lenarg,path_lenarg,file_lenarg)

/*==================================*/
/* HDS_TRACE - Trace path of object */
/*==================================*/


struct STR	 	 *locator_str;
int			 *nlev;
struct STR	 	 *path_str;
struct STR	 	 *file_str;
int			 *status;
int			  locator_lenarg;
int			  path_lenarg;
int			  file_lenarg;

{
#undef context_name
#undef context_message
#define context_name "HDS_TRACE_ERR"
#define context_message\
        "HDS_TRACE: Error tracing the path name of an HDS object."

struct DSC		  locator;
struct DSC		  path;
struct DSC		  file;
int			  locator_len = locator_lenarg;
int			  path_len = path_lenarg;
int			  file_len = file_lenarg;

struct LCP		 *lcp;
struct LCP_DATA	    	 *data;
struct LCP_STATE	 *state;
unsigned char *srv;
unsigned char *crv;
struct ODL		  odl;
struct RCL		  rcl;
const char *fns;
struct HAN		  han[2];
char			  buf[STR_K_LENGTH];
int			  subs[DAT__MXDIM];
int			  trunc;
int			  off;
int			  buflen;
int			  pathlen;
struct RID		  rid;
struct RID		  owner;
int			  ncomp;
int			  cell;
int			  level;
struct RID rid1;
char *name1;
int lfns;

rid = rec_gl_ridzero;
owner = rec_gl_ridzero;

/* Enter routine.	*/

if(!_ok(*status))
	return *status;
hds_gl_status = DAT__OK;

/* Import the locator string and export the path and file strings.	*/

_strimp(&locator,locator_str,&locator_len);
_strexp(&path,path_str,&path_len);
_strexp(&file,file_str,&file_len);

/* Import the locator.	*/

_call(dau_import_loc(&locator, &lcp))
data	      = &lcp->data;
state	      = &data->state;

/* Demand the container file name and determine the # of levels.	*/

rec_locate_fns( &data->han, &fns );
lfns = strlen( fns );
_chcopy( lfns, fns, ' ', (int) file.length, file.body );
trunc         = ( lfns > (int) file.length );
*nlev         = data->level + 1;

/* Copy the object name to the buffer and determine its length.	*/

_chcopy(DAT__SZNAM, data->name, ' ', STR_K_LENGTH, buf);
buflen        = strchr(buf, ' ') - buf;

/* If the object is sliced, then encode the subscript expression.	*/

if (state->slice)
	hds1_encode_subs(2, data->naxes, &(data->bounds[0][0]), buf, &buflen);

/* If the object is an element of an array, then convert the offset to a set
   of subscripts and then encode them.	*/

if (state->cell)
	{
	_call(dat1_get_odl(&data->han, &odl))
	hds1_get_subs(odl.naxes, odl.axis, data->offset, subs);
	hds1_encode_subs(1, odl.naxes, subs, buf, &buflen);
	}

/* Copy the contents to the path buffer and return on overflow.	*/

_chcopy(buflen, buf, ' ', (int) path.length, path.body);
if (buflen > (int) path.length)
	_call(DAT__TRUNC)

/* Save the current path length and then stick a handle on the object's
   parent record.	*/

pathlen       = buflen;
han[0]        = data->han;
_call(rec_get_rcl(&han[0], &rcl))
rec_get_handle(&rcl.parent, &han[0], &han[1]);

/* Scan up the levels until the top-level object is reached.	*/

for (level = data->level; level>=1; level--)

/*    Stick a handle on the next component record in sequence.	*/

	{
	rid = rcl.parent;
	_call(rec_get_rcl(&han[1], &rcl))
	rec_get_handle(&rcl.parent, &han[1], &han[0]);

/*    Stick a handle on the next structure record in sequence.	*/

        owner = rcl.parent;
	_call(rec_get_rcl(&han[0], &rcl))
	rec_get_handle(&rcl.parent, &han[0], &han[1]);

/*    Read the structure's Object Descriptor Label and determine if the node
      is an array cell. If it is, then locate the Structure Record Vector and
      search for the Record-ID. When found, convert the offset to the corres-
      ponding subscript values.   	*/

	_call(dat1_get_odl(&han[0], &odl))
	cell        = (odl.naxes != 0);
	if (cell)
		{
		_call(rec_locate_data(&han[0], rcl.dlen, 0, 'R', &srv))
                for ( off = 0; ; off ++ )
                {
		   dat1_unpack_srv( srv + ( off * DAT__SZSRV ), &rid1 );
		   if ( ( rid1.bloc == rid.bloc ) &&
                        ( rid1.chip == rid.chip ) )
                   {
		      break;
		   }
		}
		hds1_get_subs(odl.naxes, odl.axis, off, subs);
		rec_release_data(&han[0], rcl.dlen, 0, 'R', &srv);
		}

/*    Read the component count and locate the Component Record Vector. Search
      for the Record-ID and copy the component name to the buffer when found.
      If the structure is n-dimensional, then encode the subscript expression.*/

	if (level > 1)
		dat1_get_ncomp(&han[1], &ncomp);
	else
		ncomp = 1;
	_call(rec_locate_data(&han[1], ncomp*DAT__SZCRV, 0, 'R', &crv))
        for ( off = 0; ; off++ )
        {
	   dat1_unpack_crv( crv, off, &rid1 );
	   if ( ( rid1.bloc == owner.bloc ) && ( rid1.chip == owner.chip ) )
	   {
	      break;
	   }
        }
	dat1_locate_name( crv, off, &name1 );
	_chcopy(DAT__SZNAM, name1, ' ', STR_K_LENGTH, buf);
	buflen      = strchr(buf, ' ') - buf;
	rec_release_data(&han[1], ncomp*DAT__SZCRV, 0, 'R', &crv);
	if (cell)
		hds1_encode_subs(1, odl.naxes, subs, buf, &buflen);

/*    Add a '.' delimiter to the buffer contents and then append the current
      path string. Increment the path length accordingly and write back the
      buffer contents. (Return if path buffer cannot accommodate the string). */

	buf[buflen] = '.';
	++buflen;
	_chmove(pathlen, path.body, &buf[buflen]);
	pathlen    += buflen;
	_chcopy(pathlen, buf, ' ', (int) path.length, path.body);
	if (pathlen > (int) path.length)
		_call(DAT__TRUNC)
	}

/* Space fill the path buffer.	*/

if (pathlen < (int) path.length)
	_chcopy(0, buf, ' ', ( (int) path.length ) - pathlen,
	                     ( (char *) path.body ) + pathlen );

/* Return with error if the file name was truncated.	*/

if (trunc)
	_call(DAT__TRUNC)
return hds_gl_status;
}

hds1_encode_subs(nlim,nsub,subs,buf,nchar)

/*+
 * ENCODE_SUBS - Encode subscript expression
 *
 * This routine encodes a set of array subscripts in one of the following
 * formats:
 *
 *	  (n,n....)		for an array cell, or
 *	  (l:u,l:u....)		for a slice
 *
 * Calling sequence:
 *
 * 	  ENCODE_SUBS(NLIM,NSUB,SUBS,BUF,NCHAR)
 *
 * NLIM	  is the number of limits for each subscript (1 or 2).
 * NSUB	  is the number of subscripts.
 * SUBS   is the address of a longword vector which contains the subscripts.
 * BUF	  is the address of a buffer to receive the encoded string.
 * NCHAR  is the address of a longword which contains the current number of
 *	  characters in the buffer. This is updated to reflect the size of
 *	  the encoded string.
 *
 * Routine value:
 *
 * 	  DAT__OK    always.
 */

int			  nlim;
int			  nsub;
int			 *subs;
char			 *buf;
int			 *nchar;

{
int			  i;
int			  n;
int			  m;
int nc;

/* Return if the number of subscripts is zero.	*/

if (nsub == 0)
	return hds_gl_status;

/* Initialise the buffer index and setup the left bracket.	*/

i		= *nchar;
buf[i]		= '(';

/* Encode each subscript expression (the terminating null byte is overwritten
   by the delimiting colon).	*/

for (n=0; n<nsub; n++)
	{
	for (m=0; m<nlim; m++)
		{
		++i;
		(void) sprintf( buf + i, "%d%n", subs[ n * nlim + m ], &nc );
		i += nc;
		buf[i]	 = ':';
		}
	buf[i]	= ',';
	}

/* Append the closing bracket and return the string length.	*/

buf[i]		= ')';
*nchar		= i+1;
return hds_gl_status;
}

hds1_get_subs(ndim,dims,offset,subs)

/*+
 * GET_SUBS - Get subscripts (from offset)
 *
 * This routine converts a linear zero-based offset to a set of array sub-
 * scripts.
 *
 * Calling sequence:
 *
 * 	  GET_SUBS(NDIM,DIMS,OFFSET,SUBS)
 *
 * NDIM	  is the number of dimensions.
 * DIMS   is the address of a longword vector whose elements contain the
 *	  size of each dimension.
 * OFFSET is the zero-based offset value to be converted.
 * SUBS   is the address of a longword vector which is to receive the sub-
 *	  scripts.
 *
 * Routine value:
 *
 * 	  DAT__OK    always.
 */

int			  ndim;
int			 *dims;
int			  offset;
int			 *subs;

{
int			  disp;
int			  i;

disp	= offset;
subs[0]	= dims[0];
for (i=1; i<ndim; i++)
	subs[i]	= subs[i-1] * dims[i];
for (i=ndim-1; i>=1; i--)
	{
	subs[i]	= disp / subs[i-1];
	disp   -= subs[i-1] * subs[i];
	++subs[i];
	}
subs[0]	= disp + 1;
return hds_gl_status;
}
