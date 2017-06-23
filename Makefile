release: compile_vala compile_res
	@[ -d "/home/dexter-vb/four/builds/release/" ] || mkdir -p "/home/dexter-vb/four/builds/release/"
	@cd "/home/dexter-vb/four/builds/release/" && $(MAKE) -f "/home/dexter-vb/four/Makefile" run

/home/dexter-vb/four/builds/release/helper.o: /home/dexter-vb/four/builds/src/helper.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/wifidevice.o: /home/dexter-vb/four/builds/src/wifidevice.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/manager.o: /home/dexter-vb/four/builds/src/manager.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/dns.ui.o: /home/dexter-vb/four/builds/modified_src/dns.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/config.ui.o: /home/dexter-vb/four/builds/modified_src/config.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/apapplet.ui.o: /home/dexter-vb/four/builds/modified_src/apapplet.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/device.ui.o: /home/dexter-vb/four/builds/modified_src/device.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/main.ui.o: /home/dexter-vb/four/builds/modified_src/main.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/run.o: /home/dexter-vb/four/builds/src/run.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/release/res.xml.o: /home/dexter-vb/four/builds/res.xml.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

run: /home/dexter-vb/four/builds/release/helper.o /home/dexter-vb/four/builds/release/wifidevice.o /home/dexter-vb/four/builds/release/manager.o /home/dexter-vb/four/builds/release/dns.ui.o /home/dexter-vb/four/builds/release/config.ui.o /home/dexter-vb/four/builds/release/apapplet.ui.o /home/dexter-vb/four/builds/release/device.ui.o /home/dexter-vb/four/builds/release/main.ui.o /home/dexter-vb/four/builds/release/run.o /home/dexter-vb/four/builds/release/res.xml.o
	gcc -o /home/dexter-vb/four/builds/release/run  $^ `pkg-config --libs libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

debug: compile_vala compile_res
	@[ -d "/home/dexter-vb/four/builds/debug/" ] || mkdir -p "/home/dexter-vb/four/builds/debug/"
	@cd "/home/dexter-vb/four/builds/debug/" && $(MAKE) -f "/home/dexter-vb/four/Makefile" debug_run

/home/dexter-vb/four/builds/debug/helper.o: /home/dexter-vb/four/builds/src/helper.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/wifidevice.o: /home/dexter-vb/four/builds/src/wifidevice.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/manager.o: /home/dexter-vb/four/builds/src/manager.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/dns.ui.o: /home/dexter-vb/four/builds/modified_src/dns.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/config.ui.o: /home/dexter-vb/four/builds/modified_src/config.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/apapplet.ui.o: /home/dexter-vb/four/builds/modified_src/apapplet.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/device.ui.o: /home/dexter-vb/four/builds/modified_src/device.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/main.ui.o: /home/dexter-vb/four/builds/modified_src/main.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/run.o: /home/dexter-vb/four/builds/src/run.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter-vb/four/builds/debug/res.xml.o: /home/dexter-vb/four/builds/res.xml.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

debug_run: /home/dexter-vb/four/builds/debug/helper.o /home/dexter-vb/four/builds/debug/wifidevice.o /home/dexter-vb/four/builds/debug/manager.o /home/dexter-vb/four/builds/debug/dns.ui.o /home/dexter-vb/four/builds/debug/config.ui.o /home/dexter-vb/four/builds/debug/apapplet.ui.o /home/dexter-vb/four/builds/debug/device.ui.o /home/dexter-vb/four/builds/debug/main.ui.o /home/dexter-vb/four/builds/debug/run.o /home/dexter-vb/four/builds/debug/res.xml.o
	gcc -o /home/dexter-vb/four/builds/debug/debug_run $^ -g `pkg-config --libs libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

compile_vala: reload_vala
	@[ -d "/home/dexter-vb/four/builds/"] || mkdir -p "/home/dexter-vb/four/builds/"
	valac --pkg libnm-util --pkg libnm-glib --pkg gtk+-3.0 /home/dexter-vb/four/src/helper.vala /home/dexter-vb/four/src/wifidevice.vala /home/dexter-vb/four/src/manager.vala /home/dexter-vb/four/modified_src/dns.ui.vala /home/dexter-vb/four/modified_src/config.ui.vala /home/dexter-vb/four/modified_src/apapplet.ui.vala /home/dexter-vb/four/modified_src/device.ui.vala /home/dexter-vb/four/modified_src/main.ui.vala /home/dexter-vb/four/src/run.vala  --target-glib=2.38 --gresources /home/dexter-vb/four/res.xml -C -d /home/dexter-vb/four/builds/

reload_vala:
	@[ -d /home/dexter-vb/four/modified_src/ ] || mkdir -p /home/dexter-vb/four/modified_src/
	ruby generator.rb -r

compile_res: /home/dexter-vb/four/res.xml /home/dexter-vb/four/src/apapplet.ui /home/dexter-vb/four/src/dns.ui /home/dexter-vb/four/src/config.ui /home/dexter-vb/four/src/device.ui /home/dexter-vb/four/src/main.ui
	@[ -d "/home/dexter-vb/four/builds/"] || mkdir -p "/home/dexter-vb/four/builds/"
	glib-compile-resources /home/dexter-vb/four/res.xml --target=/home/dexter-vb/four/builds/res.xml.c --sourcedir=$(srcdir) --c-name _ap --generate-source

clean:
	@rm -rfv /home/dexter-vb/four/builds/release/
	@rm -rfv /home/dexter-vb/four/builds/debug/
	@rm -rfv /home/dexter-vb/four/modified_src/
	@rm -rfv /home/dexter-vb/four/builds/

all: debug release