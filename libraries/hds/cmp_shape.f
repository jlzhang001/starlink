*+ CMP_SHAPE - Component Shape enquiry
      subroutine cmp_shape(struct, comp, maxdim, dims, ndim, status)
*    Description :
*     A shape enquiry is made for a structure component.
*    Invocation :
*     CALL CMP_SHAPE(LOC, NAME, MAXDIM; DIMS, ACTDIM, STATUS)
*    Parameters :
*     LOC=CHARACTER*(DAT__SZLOC)
*           Variable containing a locator associated with a structured
*           data object.
*     NAME=CHARACTER*(*)
*           Expression specifying the component name of a primitive
*           object contained in the structure.
*     MAXDIM=INTEGER
*           Expression specifying the size of array, DIMS, supplied
*           to receive the object dimensions.
*     DIMS(MAXDIM)=INTEGER
*           Array to receive the object dimensions.   It must be
*           of sufficient size to contain all of the dimensions.
*     ACTDIM=INTEGER
*           Variable to receive the actual number of object dimensions.
*     STATUS=INTEGER
*           Variable holding the status value. If this variable is not
*           SAI__OK on input, the routine will return without action.
*           If the routine fails to complete, this variable will be
*           set to an appropriate error number.
*    Method :
*     Get object locator using DAT_FIND and then get shape from
*     DAT_SHAPE.
*    Authors :
*     Jack Giddings (UCL::JRG)
*    History :
*     3-JAN-1983:  Original.  (UCL::JRG)
*     15-APR-1987:  Improved prologue layout (RAL::AJC)
*    Global constants :
      INCLUDE 'SAE_PAR'
      INCLUDE 'DAT_PAR'
*    Import :
      character*(*) struct		! Structure Locator
      character*(*) comp		! Component Name
      integer maxdim			! Maximum number of dimensions
*    Export :
      integer dims(*)			! Object dimensions
      integer ndim			! Number of dimensions
*    Status return :
      integer status			! Status Return
*    Local variables :
      character*(DAT__SZLOC) loc	! Component locator
*-

      if (status .eq. SAI__OK) then
         call dat_find(struct, comp, loc, status)
         if (status .ne. SAI__OK) then
            call cmp_erdsn(struct, comp, status)
         else
            call dat_shape(loc, maxdim, dims, ndim, status)
            if (status .ne. SAI__OK) then
               call cmp_erdsn(struct, comp, status)
            endif
            call dat_annul(loc, status)
         endif
      endif

      end


