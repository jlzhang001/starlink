#+
#  Name:
#     extreme.csh
#
#  Purpose:
#     Start the EXTREME system from the C shell
#
#  Type of module:
#     C shell script
#
#  Invocation:
#     source extreme.csh
#
#  Description:
#     This procedure starts the EXTREME system for use from the C shell by
#     setting aliases for the commands it provides and setting up any 
#     environment variables.
#
#  Authors:
#     MBT: Mark Taylor (Starlink)
#
#  History:
#     10-MAR-2000 (MBT):
#        Initial version.
#-

#  Set the value of the executables directory.  The value of to which 
#  EXTREME_DIR is set gets edited into the script at install time.
      setenv EXTREME_DIR INSTALL_BIN

#  Set aliases for all the public commands provided by the package.
      alias extmk $EXTREME_DIR/extmk

      alias crepint $EXTREME_DIR/crepint
      alias frepint $EXTREME_DIR/frepint
      alias inscnf $EXTREME_DIR/frepint

      alias do-crepint $EXTREME_DIR/do-crepint
      alias do-frepint $EXTREME_DIR/do-frepint
      alias do-inscnf $EXTREME_DIR/do-inscnf

      alias cmp-crepint $EXTREME_DIR/cmp-crepint
      alias cmp-frepint $EXTREME_DIR/cmp-frepint
      alias cmp-inscnf $EXTREME_DIR/cmp-insncf

#  Write startup message.
      echo " "
      echo "   EXTREME commands are now available -- Version PKG_VERS"
      echo " "


# $Id$
