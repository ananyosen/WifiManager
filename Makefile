all: 1
	make run
res.c: res.xml apapplet.ui config.ui dns.ui
	glib-compile-resources res.xml \
		--target=$@ --sourcedir=$(srcdir) --c-name _ap --generate-source

%.o:%.c
	gcc -o $@ -c $< -Wall `pkg-config --cflags gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`

run: helper.o wifidevice.o manager.o dnsui.o config.o apapplet.o res.o run.o
	gcc -o $@  $^ `pkg-config --libs gtk+-3.0 libnm-glib dbus-glib-1 libnm-util gmodule-export-2.0`

clean: 
	rm -fv *.o *.c run

1:
	valac --pkg libnm-glib --pkg dbus-glib-1 --pkg libnm-util --pkg gtk+-3.0 helper.vala wifidevice.vala manager.vala dnsui.vala config.vala apapplet.vala run.vala --target-glib=2.38 --gresources ./res.xml -C 
# 2:
	# valac -C apapplet.vala --pkg libnm-glib --pkg dbus-glib-1 --pkg libnm-util --pkg gtk+-3.0 --target-glib=2.38 --gresources ./res.xml