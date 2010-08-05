all:
	rm -f 4Chan
	time valac --thread\
		-g\
		--output=4Chan\
		--pkg=gdk-2.0\
		--pkg=gtk+-2.0\
		--pkg=json-glib-1.0\
		--pkg=libsoup-2.4\
		--pkg=glib-2.0\
		--pkg=posix\
		gui.vala\
		thread.vala\
		memory.vala\
		chanthread.vala\
		main.vala
	./4Chan
