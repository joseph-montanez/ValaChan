namespace FourChan {

    string get_directory() {
        string data_dir = GLib.Environment.get_user_data_dir();
        string chan_dir = data_dir + "/4chan";
            
        try {
            GLib.Dir.open(chan_dir);
        } catch(GLib.FileError e) {
            Posix.mkdir(chan_dir, 0775);
        }
        
        return chan_dir;
    }

    public class Http : GLib.Object {
        public string? data = null;
        public size_t data_size = 0;
        public FileOutputStream? file_stream = null;
        public DataOutputStream? data_stream = null;
        
        public void url_get_contents(string url, string? filename = null) {
            File? file = null;
            if (filename != null) {
                file = File.new_for_path(filename);
            }
            stdout.printf("Loading URL: %s\n", url);
            if (file == null || !file.query_exists(null)) {
                // If there is not a json file cached, re-download from internet
                var session = new Soup.SessionAsync();
                var message = new Soup.Message("GET", url);
                stdout.printf("Sending...\n");
                session.send_message(message);
                stdout.printf("Receiving...\n");
                this.data = message.response_body.data;
                this.data_size = (size_t) message.response_body.length;
            }   
            stdout.printf("Finished URL: %s\n", url);
            
            // Try to create file
            try {
                file_stream = file.create(FileCreateFlags.NONE, null);
            } catch (GLib.Error e) { }
            
            // Try to write to file is there is data
            if (this.file_stream != null && this.data != null) {
                stdout.printf("Writing to File: %s\n", filename);
                this.data_stream = new DataOutputStream(this.file_stream);
                try {
                    this.data_stream.put_string(this.data, null);
                } catch (GLib.Error e) { }
            } else {
                // It has been cache so read from file
                try {
                    stdout.printf("Reading from File: %s\n", filename);
                    FileUtils.get_contents(filename, out this.data, out this.data_size);
                } catch (GLib.FileError e) {
                    stdout.printf("Holy shit batman, I cant write to donkey balls\n");
                }
            }
        }
    }

    public class Thread {
        public string? data = null;
        public size_t data_size = 0;
        
        public G3DMemory* memory;
        public Gui* gui;
        
        public Thread(ref G3DMemory memory, Gui gui) {
            this.memory = memory;
            this.gui = gui;
        }
        
        public void* download_icon() {
            // Data Directory
            var chan_dir = FourChan.get_directory();
            
            // Open File | Why does this segfault on a single line!?
            var filename = chan_dir;
            filename += "/image-";
            filename += this.memory->selected_thread;
            filename += ".json";
            
            var url = "http://www.gorilla3d.com/4chan/get-thread.php?threadId=" + this.memory->selected_thread;
            var http = new FourChan.Http();
            http.url_get_contents(url, filename);
            this.data = http.data;
            this.data_size = http.data_size;
            
            return null;
        }
        
        public void* do_request() {
            // Data Directory
            var chan_dir = FourChan.get_directory();
            
            // Open File | Why does this segfault on a single line!?
            var filename = chan_dir;
            filename += "/thread-";
            filename += this.memory->selected_thread;
            filename += ".json";
            
            var url = "http://www.gorilla3d.com/4chan/get-thread.php?threadId=" + this.memory->selected_thread;
            var http = new FourChan.Http();
            http.url_get_contents(url, filename);
            this.data = http.data;
            this.data_size = http.data_size;
            
            
            if (this.data == null) {
                // Crap something went wrong, sooo wrong
                stdout.printf("crap no data");
                return null;
            }
            
            // Parse Json Data, Go Go Json Waterfall
            var json = new Json.Parser();
            
            try {
                json.load_from_data(this.data, this.data_size);
            } catch (GLib.Error e) { }
            
            if (json.get_root() != null) {
                var root = json.get_root().copy();
                var object = root.get_object();
                    
                // Get Thread's Title
                var title_node = object.get_member("title").copy();
                // Get Thread's Photo Count
                var photos_node = object.get_member("photos").copy();
                // Get Thread's Id
                var id_node = object.get_member("id").copy();
                
                var chan_thread = new ChanThread();
                chan_thread.id = id_node.get_string();
                chan_thread.name = title_node.get_string();
                
                var photos = photos_node.get_array();
                if(photos != null) {

                    var photos_length = photos.get_length();
                    for (var i = 0; i < photos_length; i++) {
                        var photo_node = photos.get_element(i).get_object();
                        var chan_photo = new ChanPhoto();
                        
                        chan_photo.filename = photo_node.get_member("filename").get_string();
                        chan_thread.photos.append(chan_photo);
                    }
                }
                
                this.memory->threads.append(chan_thread);
                this.memory->chan_thread = chan_thread;
            } else {
                // Json got back, got back baby I say
                stdout.printf("Yo, bro no valid json here\n");
            }
            return null;
        }
    }

    public class Threads : Http {
        public G3DMemory* memory;
        
        public Threads(ref G3DMemory memory) {
            this.memory = memory;
        }
        
        public void* do_request() {
            // Data Directory
            var chan_dir = FourChan.get_directory();
            
            // Open File
            string filename = chan_dir + "/threads.json";
            string url = "http://www.gorilla3d.com/4chan/get-threads.php";
            
            this.url_get_contents(url, filename);
            
            
            // Parse Json Data
            var json = new Json.Parser();
            
            try {
                json.load_from_data(data, data_size);
            } catch (GLib.Error e) { }
            
            if (json.get_root() != null) {
                var root = json.get_root().copy();
                var array = root.get_array();
                var length = array.get_length();
                for (var i = 0; i < length; i++) {
                    var node = array.get_element(i).copy();
                    if (node.type_name() != "JsonObject") {
                        // it should be a json object!
                        continue;
                    }
                    var object = node.get_object();
                    
                    // Get Object's Title
                    var title_node = object.get_member("title").copy();
                    // Get Object's Photo Count
                    var photos_node = object.get_member("photos").copy();
                    // Get Object's Id
                    var id_node = object.get_member("id").copy();
                    
                    var chan_thread = new ChanThread();
                    chan_thread.id = id_node.get_string();
                    chan_thread.name = title_node.get_string();
                    chan_thread.photo_count = photos_node.get_int();
                    
                    this.memory->threads.append(chan_thread);
                }
            } else {
                // Json got back, got back baby I say
                stdout.printf("Yo, bro no valid json here\n");
            }

            return null;
        }
    }
}
