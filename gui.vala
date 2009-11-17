using Gtk;

public class Gui : Window {
    public TreeView view;
    public TreeStore store;
    public Frame frame2;
    public G3DMemory* memory;
    public Gui (ref G3DMemory memory) {
        this.memory = memory;
        this.title = "TreeView Sample";
        set_default_size(640, 480);
        
        var hpaned = new HPaned();
        var frame1 = new Frame(null);
        this.frame2 = new Frame(null);
        
        hpaned.add1(frame1);
        hpaned.add2(this.frame2);
        
        frame1.set_shadow_type(Gtk.ShadowType.IN);
        this.frame2.set_shadow_type(Gtk.ShadowType.IN);
        
        var scrolled = new ScrolledWindow(null, null);
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        
        this.view = new TreeView();
        // Registar Events
        var veiw_selection = this.view.get_selection();
        veiw_selection.changed.connect(this.changed);
        view.row_expanded.connect(this.click_thread);
        
        setup_treeview(view);
        scrolled.add_with_viewport(view);
        frame1.add(scrolled);
        
        add(hpaned);
        
        this.destroy.connect(Gtk.main_quit);
    }
    
    public void changed() {
        var selection = this.view.get_selection();
        
        TreeModel model;
        TreeIter iter;
        
        if (selection.get_selected(out model, out iter)) {
            GLib.Value selected_value;
            model.get_value(iter, 0, out selected_value);
            
            string thread_id = selected_value.get_string();
            this.memory->selected_thread = thread_id;
            
            stdout.printf("selected index %s\n", this.memory->selected_thread);
            
            // TODO: call json from website to load images
            var chan_thread = new FourChan.Thread(ref this.memory, this);
            chan_thread.do_request();
            
        } else {
            stdout.printf("nothing selected\n");
        }
        
    }
    
    public void click_thread(TreeIter iter, TreePath path) {
        stdout.printf("click\n");
    }

    private void setup_treeview (TreeView view) {
        this.store = new TreeStore(2, typeof(string), typeof(string));
        view.set_model(this.store);
        
        view.insert_column_with_attributes(-1, "4Chan Section", new CellRendererText (), "text", 0, null);
        view.insert_column_with_attributes(-1, "Photo Count", new CellRendererText (), "text", 1, null);

        TreeIter category_iter;
        TreeIter product_iter;

        this.store.append (out category_iter, null);
        this.store.set (category_iter, 0, "Anime Wallpaper", -1);
        
        
        foreach (ChanThread thread in this.memory->threads) {
            //stdout.printf("Thread: %s (%d)\n", thread.name, thread.photo_count);
            string photo_count = thread.photo_count.to_string() + " Photos";
            this.store.append (out product_iter, category_iter);

            this.store.set (product_iter, 0, thread.name, 1, photo_count, -1);
        }
/*
        this.store.append (out category_iter, null);
        this.store.set (category_iter, 0, "Films", -1);

        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Amores Perros", 1, "$7.99", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Twin Peaks", 1, "$14.99", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Vertigo", 1, "$20.49", -1);
*/
        //view.expand_all ();
    }
    
        /*
        Gtk.init (ref args);

        var sample = new Main ();
        sample.show_all ();
        Gtk.main ();
        */
        
}
