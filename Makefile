# THIS_FILE := $()

release: compile_vala compile_res
	[ -d builds ] || mkdir ./builds
	[ -d builds/release ] || mkdir ./builds/release
	cd ./builds/release/ && $(MAKE) -f ../../Makefile run

debug: compile_vala compile_res
	[ -d builds ] || mkdir ./builds
	[ -d builds/debug ] || mkdir ./builds/debug
	cd ./builds/debug/ && $(MAKE) -f ../../Makefile debug_run	

compile_res: res.xml apapplet.ui config.ui dns.ui device.ui main.ui
	[ -d builds ] || mkdir ./builds	
	glib-compile-resources res.xml \
		--target=./builds/res.c --sourcedir=$(srcdir) --c-name _ap --generate-source

%.o:../%.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`

%.d.o:../%.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`

run: helper.o wifidevice.o manager.o dnsui.o config.o apapplet.o deviceui.o mainui.o res.o run.o
	gcc -o $@  $^ `pkg-config --libs gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`

debug_run: helper.d.o wifidevice.d.o manager.d.o dnsui.d.o config.d.o apapplet.d.o deviceui.d.o mainui.d.o res.d.o run.d.o
	gcc -o $@  $^ -g `pkg-config --libs gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`


clean: clean_builds

clean_builds: 
	rm -rfv ./builds

clean_release: 
	cd ./builds/release/ && rm -fv *.o run

clean_debug: 
	cd ./builds/debug/ && rm -fv *.o debug_run

clean_c:
	cd ./builds/ && rm -fv *.c

compile_vala:
	[ -d builds ] || mkdir ./builds
	valac --pkg libnm-glib --pkg dbus-glib-1 --pkg libnm-util --pkg gtk+-3.0 \
	 helper.vala wifidevice.vala manager.vala dnsui.vala config.vala apapplet.vala deviceui.vala mainui.vala run.vala \
	  --target-glib=2.38 --gresources ./res.xml -C -d ./builds/

all: release debug