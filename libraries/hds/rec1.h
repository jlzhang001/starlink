#if !defined( REC1_INCLUDED )	 /* rec1.h already included?		    */
#define REC1_INCLUDED 1

#include "rec.h"		 /* Public rec definitions		    */

/* VMS version include files:						    */
/* =========================						    */
#if defined( vms )

/* POSIX version include files:						    */
/* ===========================						    */
#else
#include <stddef.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

/* Constants:								    */
/* =========								    */
#define REC__BIGMEM 5121	 /* Bytes for a "big" memory request	    */
#define REC__MXCHIP 15		 /* No. chips in a block		    */
#define REC__MXSTK 96		 /* No. entries in free space stack	    */
#define REC__SZBLK 512		 /* Size of a container file block	    */
#define REC__SZCBM 2		 /* Size of a packed Chip Bitmap	    */
#define REC__SZCHAIN 4		 /* Size of a packed chained block number   */
#define REC__SZCHIP 34		 /* Size of a chip			    */

#define REC__STAMP 5456979	 /* HDS file identification stamp	    */
#define REC__VERSION 3		 /* Current file format version #	    */

#if defined( vms )
#define REC__NOIOCHAN 0		 /* Null value for an I/O channel	    */
#else
#define REC__NOIOCHAN NULL	 /* Null value for a file stream	    */
#endif

/* Macros:								    */
/* ======								    */

/* Number of chips required for a record.				    */
#define _nchips( len )\
		( ( REC__SZRCL + len + REC__SZCHIP - 1 ) / REC__SZCHIP )

/* Number of blocks required for a frame.				    */
#define _nblocs( len )\
		( ( len + REC__SZBLK - 1 ) / REC__SZBLK )


/* Data Structures:							    */
/* ===============							    */

/* STK - Stack fields.							    */
      struct STK
      {
         int bloc;		 /* Block number			    */
         int spare;		 /* Number of spare blocks or chips	    */
      };

/* HCB - Header Control Block.						    */
      struct HCB
      {
         struct STK stk[ REC__MXSTK ]; /* Free space stack		    */
         int eof;		 /* End-of-file block number		    */
         unsigned int stamp;	 /* Container file stamp		    */
         int version;		 /* Data-system version number		    */
      };

/* FID - File ID.							    */

#if defined( vms )		 /* VMS-specific file ID		    */
      struct FID
      {
         char dev[ 16 ];	 /* Device				    */
         short int fil[ 3 ];	 /* File				    */
         short int dir[ 3 ];	 /* Directory				    */
      };
#else				 /* Portable (POSIX) file ID		    */
      struct FID
      {
         dev_t st_dev;		 /* ID of device containing file (POSIX)    */
         ino_t st_ino;		 /* File serial number (POSIX)		    */
      };
#endif

/* FCV - File Control Vector.						    */
      struct FCV
      {
         char *name;		 /* Pointer to file name string		    */
         struct FID *fid;	 /* Pointer to file-ID			    */
         struct HCB *hcb;	 /* Pointer to HCB information		    */
#if defined( vms )
         unsigned int lid;	 /* Lock-ID				    */
         int read;		 /* Read-only I/O channel		    */
	 int write;		 /* Write I/O channel			    */
#else
         FILE *read;		 /* Read-only I/O channel		    */
	 FILE *write;		 /* Write I/O channel			    */
#endif
         int count;		 /* Reference count			    */
	 int dele;		 /* Marked for deletion?		    */
         int open;		 /* Slot open?				    */
         int locked;		 /* Locked?				    */
         int hcbmodify;		 /* HCB modified?			    */
      };

/* BID - Block ID.							    */
      struct BID
      {
         int slot;		 /* Slot number				    */
         int bloc;		 /* Block number			    */
      };

/* BCP - Block Control Packet.						    */
      struct BCP
      {
         struct BCP *flink;	 /* Forward link to next BCP		    */
         struct BCP *blink;	 /* Backward link to last BCP		    */
         struct BID bid;	 /* Block ID				    */
         int count;		 /* Reference count			    */
         unsigned char *bloc;	 /* Pointer to block's cached data	    */
         int modify;		 /* Block modified?			    */
      };

      extern int rec_gl_active;	 /* rec_ facility active?		    */
      extern int rec_gl_endslot; /* Next FCV slot # to use		    */
      extern int rec_gl_mxslot;  /* Number of FCV slots allocated	    */
      extern int rec_gl_wplsize; /* Current Working Page List size	    */
      extern struct BCP *rec_ga_fpl; /*	Free Page List			    */
      extern struct BCP *rec_ga_lastbcp; /* Address of last used BCP	    */
      extern struct BCP *rec_ga_wpl; /*	Working Page List		    */
      extern struct FCV *rec_ga_fcv; /*	File control vector		    */
      extern struct WLD *rec_gl_wldque; /* Wild-card search context queue   */

/* Function Prototypes:							    */
/* ===================							    */
      int rec1_alloc_frame( int slot, int size, int *bloc );
      void rec1_clear_cbm( unsigned char cbm[ 2 ], int nchip, int pos );
      int rec1_close_file( int slot, char mode );
      int rec1_close_slot( int slot );
      void rec1_create_file( int expand, const char *file, int file_len,
			     int size, int *slot, int *alq );
      int rec1_deall_frame( int slot, int size, int bloc );
      int rec1_extend_file( int slot, int size, int *actsize );
      int rec1_extend_frame( int slot, int size, int extra, int *bloc );
#if defined( vms )
      void rec1_find_file( void );
#else
      void rec1_find_file( const char *fspec, INT fspec_len, pid_t *pid,
			   FILE **stream );
#endif
      int rec1_flush_block( struct BCP *bcp );
      void rec1_fmsg( const char *token, int slot );
      int rec1_get_addr( size_t size, unsigned char **start,
                         unsigned char **end );
#if defined( vms )		 /* These routines not used on VMS:	    */
      void rec1_get_fid( void );
      void rec1_get_path( void );
      void rec1_getcwd( void );
#else
      void rec1_get_fid( const char *fns, struct FID *fid );
      void rec1_get_path( const char *fname, INT fname_len, char **path,
			  INT *path_len );
      void rec1_getcwd( char **cwd, INT *lcwd );
#endif
      int rec1_locate_hcb( int slot, char mode, struct HCB **hcb );
      int rec1_lock_slot( int slot );
      int rec1_map_frame( int slot, int bloc, int length, int offset,
                          char mode, unsigned char **pntr );
      void rec1_open_file( int expand, const char *file, int file_len,
			   char mode, int *slot, int *newslot );
      int rec1_pack_chain( int chain, unsigned char pchain[ 4 ] );
      int rec1_pack_hcb( const struct HCB *hcb,
                         unsigned char phcb[ REC__SZBLK ] );
      int rec1_pack_ncomp( int ncomp, unsigned char pncomp[ 4 ] );
      int rec1_pack_rcl( const struct RCL *rcl, unsigned char prcl[ 10 ] );
      void rec1_put_addr( unsigned char *start, unsigned char *end,
                          int *status );
      int rec1_read_file( int slot, int bloc, int size, unsigned char *buffer );
      int rec1_scan_cbm( const unsigned char cbm[ 2 ], int nchip, int *pos );
      void rec1_set_cbm( unsigned char cbm[ 2 ], int nchip, int pos );
#if defined( vms )
      void rec1_shell( void );
#else
      void rec1_shell( pid_t *pid, FILE *stream[ 2 ] );
#endif
      int rec1_test_cbm( const unsigned char cbm[ 2 ], int start, int nchip );
      int rec1_unlock_slot( int slot );
      int rec1_unmap_frame( int slot, int bloc, int length, int offset,
                            char mode, unsigned char **pntr );
      int rec1_unpack_chain( const unsigned char pchain[ 4 ], int *chain );
      int rec1_unpack_hcb( const unsigned char phcb[ REC__SZBLK ],
                           struct HCB *hcb );
      int rec1_unpack_ncomp( const unsigned char pncomp[ 4 ], int *ncomp );
      int rec1_unpack_rcl( const unsigned char prcl[ 10 ], struct RCL *rcl );
      int rec1_update_free( int slot, int bloc, const unsigned char cbm[ 2 ] );
      int rec1_write_file( int slot, int size, const unsigned char *buffer,
                           int bloc );

#endif
