saxonhejar=/usr/share/java/Saxon-HE.jar
xsltclass=net.sf.saxon.Transform

xcb_h=xcb/xcb.h

all: xcb.so

clean:
	rm -f xcb.xml xcb.stub xcb.c xcb.so xcb.h%

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
