# E.S.O. - VLT project
#
# "@(#) $Id: man.mk,v 1.1.1.1 2002/04/04 20:11:39 brighton Exp $" 
#
# Makefile.in 
#
# generate the ESO/VLT style man pages 
# 
# who      when     what
# -------- -------- ------------------
# abrighto 15/04/96 created
# pbiereic 03/09/99 option to generate man pages from sources
#
# ------------------------------------------------------------------------
# 	Make include file for manual page files 
# ------------------------------------------------------------------------
#
# This make include file assumes that $(MAN_SECTIONS) is set to the list
# of man page sections (1 3 n ...) and $(MANDIR) is set to the install dir
# for man pages.
# The man pages can be generated directly from the sources. The path to the
# sources is defined by $(MAN1), $(MAN3) or $(MANn)
all:

man: 
	-@d="`date '+%d %h %y'`" ;\
	test -d ../doc || mkdir ../doc ;\
	if [ ! -z "$(MAN_SECTIONS)" ] ; then \
	  for i in $(MAN_SECTIONS) ;\
	  do \
	    if [ ! -z "$$i" ] ; then \
	      del="" ; \
	      test -d man$$i || mkdir man$$i ;\
	      test -d doc$$i || mkdir doc$$i ;\
              mp= ; \
	      case $$i in  \
	      1) \
	        mp="$(MAN1)" ;; \
	      3) \
	        mp="$(MAN3)" ;; \
	      n) \
	        mp="$(MANn)" ;; \
	      esac ; \
	      if [ ! -z "$$mp" ] ; then \
	        for j in $$mp ; \
	        do \
	          nam=`basename $$j` ; \
	          nam=`echo $$nam | sed 's/\./\//'` ; \
	          nam="`dirname $$nam`.man$$i" ; \
	          ln -s $$j $$nam ;\
	          del="$$del $$nam" ; \
	        done ;\
	      fi ; \
	      \
	      for j in *.man$$i ;\
	      do \
	        if [ "$$j" != "*.man$$i" ] ; then \
	          n=`basename $$j .man$$i` ;\
	          echo "generating man page for $$n" ;\
	          docDoManPages $$j $$i "$$d" > /dev/null ;\
	          mv ../doc/$$n.* doc$$i ;\
	          rm -f man$$i/$$i* ../doc/$$i* ;\
	        fi ; \
	      done ;\
	      \
	      rm -f $$del ;\
	    fi ; \
	  done ;\
	fi


# Install the man pages in the man install dir.
# Note that some man pages were written by hand in Tcl/Tk
# style (including man.macros file) and some were generated
# by docDoManPages.

install:
	@if [ ! -d $(MANDIR) ] ;\
	then \
	    echo "Making directory $(MANDIR)"; \
	    mkdir $(MANDIR); \
	    chmod 755 $(MANDIR); \
	fi ;\
	for s in $(MAN_SECTIONS); \
	do \
	   if [ ! -d $(MANDIR)/man$$s ] ;\
	   then \
	      echo "Making directory $(MANDIR)/man$$s"; \
	      mkdir $(MANDIR)/man$$s; \
	      chmod 755 $(MANDIR)/man$$s; \
	   fi; \
	   for i in man$$s/*.$$s; \
	    do if [ -f $$i ] ; \
	    then \
	      i=`basename $$i` ;\
	      echo "Installing man$$s/$$i in $(MANDIR)/man$$s"; \
	      $(RM) $(MANDIR)/man$$s/$$i; \
	      if fgrep -s man.macros man$$s/$$i ;\
	      then \
		echo "including man.macros with man$$s/$$i" ;\
		sed -e '/man\.macros/r man.macros' -e '/man\.macros/d' \
		    man$$s/$$i > $(MANDIR)/man$$s/$$i; \
	      else \
	 	cp man$$s/$$i $(MANDIR)/man$$s/$$i ;\
	      fi ;\
	      chmod 444 $(MANDIR)/man$$s/$$i; \
	    fi ;\
	    done ;\
	done

clean:
	rm -fr man* doc*

distclean: clean
	rm -f Makefile
