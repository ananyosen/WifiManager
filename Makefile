release: compile_vala compile_res
	@[ -d "/home/dexter/projects/vala/four/builds/release/" ] || mkdir -p "/home/dexter/projects/vala/four/builds/release/"
	@cd "/home/dexter/projects/vala/four/builds/release/" && $(MAKE) -f "/home/dexter/projects/vala/four/Makefile" run

/home/dexter/projects/vala/four/builds/release/helper.o: /home/dexter/projects/vala/four/builds/src/helper.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/wifidevice.o: /home/dexter/projects/vala/four/builds/src/wifidevice.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/manager.o: /home/dexter/projects/vala/four/builds/src/manager.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/dns.ui.o: /home/dexter/projects/vala/four/builds/modified_src/dns.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/config.ui.o: /home/dexter/projects/vala/four/builds/modified_src/config.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/apapplet.ui.o: /home/dexter/projects/vala/four/builds/modified_src/apapplet.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/device.ui.o: /home/dexter/projects/vala/four/builds/modified_src/device.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/main.ui.o: /home/dexter/projects/vala/four/builds/modified_src/main.ui.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/exec.o: /home/dexter/projects/vala/four/builds/src/exec.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/release/res.xml.o: /home/dexter/projects/vala/four/builds/res.xml.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

run: /home/dexter/projects/vala/four/builds/release/helper.o /home/dexter/projects/vala/four/builds/release/wifidevice.o /home/dexter/projects/vala/four/builds/release/manager.o /home/dexter/projects/vala/four/builds/release/dns.ui.o /home/dexter/projects/vala/four/builds/release/config.ui.o /home/dexter/projects/vala/four/builds/release/apapplet.ui.o /home/dexter/projects/vala/four/builds/release/device.ui.o /home/dexter/projects/vala/four/builds/release/main.ui.o /home/dexter/projects/vala/four/builds/release/exec.o /home/dexter/projects/vala/four/builds/release/res.xml.o
	gcc -o /home/dexter/projects/vala/four/builds/release/run  $^ `pkg-config --libs libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

debug: compile_vala compile_res
	@[ -d "/home/dexter/projects/vala/four/builds/debug/" ] || mkdir -p "/home/dexter/projects/vala/four/builds/debug/"
	@cd "/home/dexter/projects/vala/four/builds/debug/" && $(MAKE) -f "/home/dexter/projects/vala/four/Makefile" debug_run

/home/dexter/projects/vala/four/builds/debug/helper.o: /home/dexter/projects/vala/four/builds/src/helper.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/wifidevice.o: /home/dexter/projects/vala/four/builds/src/wifidevice.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/manager.o: /home/dexter/projects/vala/four/builds/src/manager.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/dns.ui.o: /home/dexter/projects/vala/four/builds/modified_src/dns.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/config.ui.o: /home/dexter/projects/vala/four/builds/modified_src/config.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/apapplet.ui.o: /home/dexter/projects/vala/four/builds/modified_src/apapplet.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/device.ui.o: /home/dexter/projects/vala/four/builds/modified_src/device.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/main.ui.o: /home/dexter/projects/vala/four/builds/modified_src/main.ui.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/exec.o: /home/dexter/projects/vala/four/builds/src/exec.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

/home/dexter/projects/vala/four/builds/debug/res.xml.o: /home/dexter/projects/vala/four/builds/res.xml.c
	gcc -o $@ -g -c $< -Wall `pkg-config --cflags libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

debug_run: /home/dexter/projects/vala/four/builds/debug/helper.o /home/dexter/projects/vala/four/builds/debug/wifidevice.o /home/dexter/projects/vala/four/builds/debug/manager.o /home/dexter/projects/vala/four/builds/debug/dns.ui.o /home/dexter/projects/vala/four/builds/debug/config.ui.o /home/dexter/projects/vala/four/builds/debug/apapplet.ui.o /home/dexter/projects/vala/four/builds/debug/device.ui.o /home/dexter/projects/vala/four/builds/debug/main.ui.o /home/dexter/projects/vala/four/builds/debug/exec.o /home/dexter/projects/vala/four/builds/debug/res.xml.o
	gcc -o /home/dexter/projects/vala/four/builds/debug/debug_run $^ -g `pkg-config --libs libnm-util libnm-glib gtk+-3.0 gmodule-export-2.0`

compile_vala: reload_vala
	@[ -d "/home/dexter/projects/vala/four/builds/"] || mkdir -p "/home/dexter/projects/vala/four/builds/"
	valac --pkg libnm-util --pkg libnm-glib --pkg gtk+-3.0 /home/dexter/projects/vala/four/src/helper.vala /home/dexter/projects/vala/four/src/wifidevice.vala /home/dexter/projects/vala/four/src/manager.vala /home/dexter/projects/vala/four/modified_src/dns.ui.vala /home/dexter/projects/vala/four/modified_src/config.ui.vala /home/dexter/projects/vala/four/modified_src/apapplet.ui.vala /home/dexter/projects/vala/four/modified_src/device.ui.vala /home/dexter/projects/vala/four/modified_src/main.ui.vala /home/dexter/projects/vala/four/src/exec.vala  --target-glib=2.38 --gresources /home/dexter/projects/vala/four/res.xml -C -d /home/dexter/projects/vala/four/builds/

reload_vala:
	@[ -d /home/dexter/projects/vala/four/modified_src/ ] || mkdir -p /home/dexter/projects/vala/four/modified_src/
	ruby generator.rb -r

compile_res: /home/dexter/projects/vala/four/res.xml /home/dexter/projects/vala/four/src/apapplet.ui /home/dexter/projects/vala/four/src/dns.ui /home/dexter/projects/vala/four/src/config.ui /home/dexter/projects/vala/four/src/device.ui /home/dexter/projects/vala/four/src/main.ui
	@[ -d "/home/dexter/projects/vala/four/builds/"] || mkdir -p "/home/dexter/projects/vala/four/builds/"
	glib-compile-resources /home/dexter/projects/vala/four/res.xml --target=/home/dexter/projects/vala/four/builds/res.xml.c --sourcedir=$(srcdir) --c-name _ap --generate-source

clean:
	@rm -rfv /home/dexter/projects/vala/four/builds/release/
	@rm -rfv /home/dexter/projects/vala/four/builds/debug/
	@rm -rfv /home/dexter/projects/vala/four/modified_src/
	@rm -rfv /home/dexter/projects/vala/four/builds/

all: debug release