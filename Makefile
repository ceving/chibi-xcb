saxonhejar=/usr/share/java/Saxon-HE.jar
xsltclass=net.sf.saxon.Transform

xcb_h=xcb/xcb.h

all: xcb.so xcb.sld

clean:
	rm -f xcb.c xcb.so xcb.h%

devel-clean: clean
	rm -f xcb.xml xcb.stub xcb.sld

xcb.xml:
	echo '#include <$(xcb_h)>' | gccxml - -fxml=$@

xcb.h%:
	echo '#include <$(xcb_h)>' | gcc -E - >$@

xcb.stub: xcb.xml xcb.xslt
	java -cp $(saxonhejar) $(xsltclass) -s:$(filter %.xml,$^) -xsl:$(filter %.xslt,$^) -o:$@

xcb.c: xcb.stub
	chibi-ffi $<

xcb.so: xcb.c
	gcc -g -o $@ -fPIC -shared $< -lchibi-scheme

xcb.sld: xcb.stub stub2sld.scm
	chibi-scheme -m 'scheme base' stub2sld.scm < $< > $@
