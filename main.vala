public class Main : GLib.Object {
    public static int main(string[] args) {  
        if (!Thread.supported()) {
            stderr.printf("Cannot run without thread support.\n");
            return 1;
        }
        var mem = new G3DMemory();
        var t1 = new FourChan.Threads(ref mem);
        try {
            unowned Thread thread_1 = Thread.create(t1.do_request, true);
            thread_1.join();
        } catch (ThreadError e) {
            stderr.printf ("Error: %s\n", e.message);
            return 1;
        }
        
        
        Gtk.init(ref args);

        var sample = new Gui(ref mem);
        sample.default_width = 640;
        sample.default_height = 480;
        sample.show_all();
        Gtk.main ();

        return 0;
    }
}
