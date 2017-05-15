all: xcb.so

clean:
	rm -f xcb.xml xcb.stub xcb.c xcb.so

xcb.xml:
	echo '#include <xcb/xcb.h>' | gccxml - -fxml=$@

xcb.stub: xcb.xml
	bash xcb.bash $< > $@

xcb.c: xcb.stub
	chibi-ffi $<

xcb.so: xcb.c
	gcc -g -o $@ -fPIC -shared $< -lchibi-scheme
