<!doctype programcode public "-//Starlink//DTD DSSSL Source Code 0.2//EN" [
<!entity sldocs.dsl		system "sldocs.dsl">
<!entity slsect.dsl		system "slsect.dsl">
<!entity slmisc.dsl		system "slmisc.dsl">
<!entity slroutines.dsl		system "slroutines.dsl">
<!entity slmaths.dsl		system "slmaths.dsl">
<!entity sllinks.dsl		system "sllinks.dsl">
<!entity sltables.dsl		system "sltables.dsl">

<!entity slparams.dsl		system "sl-latex-parameters">

<!entity lib.dsl		system "../lib/sllib.dsl" subdoc>
<!entity common.dsl		system "../common/slcommon.dsl" subdoc>
<!entity slback.dsl		system "slback.dsl" subdoc>
]>

<!-- $Id$ -->

<docblock>
<title>Starlink to LaTeX stylesheet
<description>
This is the stylesheet for converting the Starlink General DTD to LaTeX.
<p>It requires a <em/modified/ version of Jade, which supports the
<code/-t latex/ back-end.

<authorlist>
<author id=ng affiliation='Glasgow'>Norman Gray

<copyright>Copyright 1999, Particle Physics and Astronomy Research Council


<codereference doc="lib.dsl" id="code.lib">
<title>Library code
<description>
<p>Some of this library code is from the standard, some from Norm
Walsh's stylesheet, other parts from me

<codereference doc="common.dsl" id="code.common">
<title>Common code
<description>
<p>Code which is common to both the HTML and print stylesheets.

<codereference doc="slback.dsl" id=code.back>
<title>Back-matter
<description>Handles notes, bibliography and indexing

<codegroup
  use="code.lib code.common code.back" id=latex>
<title>Conversion to LaTeX

<misccode>
<description>Declare the flow-object-classes to support the LaTeX back-end
of Jade, written by me.
<codebody>
(declare-flow-object-class command
  "UNREGISTERED::Norman Gray//Flow Object Class::command")
(declare-flow-object-class empty-command
  "UNREGISTERED::Norman Gray//Flow Object Class::empty-command")
(declare-flow-object-class environment
  "UNREGISTERED::Norman Gray//Flow Object Class::environment")
(declare-flow-object-class fi
  "UNREGISTERED::James Clark//Flow Object Class::formatting-instruction")
(declare-flow-object-class entity
  "UNREGISTERED::James Clark//Flow Object Class::entity")
(declare-characteristic escape-tex?
  "UNREGISTERED::Norman Gray//Characteristic::escape-tex?"
  #t)

(define %stylesheet-version%
  "Starlink LaTeX stylesheet, version 0.1")

;; incorporate the simple stylesheets directly

&sldocs.dsl;
&slsect.dsl;
&slmisc.dsl;
&slroutines.dsl;
&slmaths.dsl;
&sllinks.dsl;
&sltables.dsl;
&slparams.dsl;

<misccode>
<description>
The root rule.  Simply generate the LaTeX document at present.
<codebody>
(root
    (make sequence
      (process-children)
      (make-manifest)
      ))

<![ ignore [
<codegroup>
<title>The default rule
<description>There should be no default rule in the main group
(<code/style-specification/ in the terms of the DSSSL architecture),
so that it doesn't take priority over mode-less rules in other process
specification parts.  See the DSSSL standard, sections 7.1 and 12.4.1.

<p>Put a sample default rule in here, just to keep it out of the way
(it's ignored).
<misccode>
<description>The default rule
<codebody>
(default
  (process-children))
]]>

<func>
<routinename>make-manifest
<description>Construct a list of the LaTeX files generated by the main
processing.  Done only if <code/suppress-manifest/ is false and 
<code/%latex-manifest%/ is true, giving the
name of a file to hold the manifest.  
<p>This is reasonably simple, since the manifest will typically consist
of no more than the main output file, plus whatever files are used
by the "figurecontent" element.
<returnvalue none>
<argumentlist>
<parameter optional default='(current-node)'>nd<type>singleton-node-list
  <description>Node which identifies the grove to be processed.
<codebody>
(define (make-manifest #!optional (nd (current-node)))
  (if (and %latex-manifest% (not suppress-manifest))
      (let ((element-list (list (normalize "figurecontent")))
	    (rde (document-element nd)))
	(make entity system-id: %latex-manifest%
	      (make fi
		data: (string-append (root-file-name) ".tex
")) ; see sldocs.dsl
	      (with-mode make-manifest-mode
		(process-node-list
		 (node-list rde		;include current file
			    (node-list-filter-by-gi
			     (select-by-class (descendants rde)
					      'element)
			     element-list))))))
      (empty-sosofo)))

(mode make-manifest-mode
  (default 
    (empty-sosofo))

  (element figurecontent
    (let* ((image-ents (attribute-string (normalize "image")
					 (current-node)))
	   (best-ent (and image-ents
			  (get-sysid-by-notation image-ents
						 '("EPS")))))
      (if best-ent
	  (make fi data: (string-append best-ent "
"))
	  (empty-sosofo)))))



