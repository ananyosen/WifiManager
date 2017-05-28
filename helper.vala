class Helper : GLib.Object { 
    public static void log(string msg)
	{
    	string path_prefix = "./logs/";
		if (msg == null) {
			return;
		}
		var date = new DateTime.now_local();
		string fname = path_prefix + date.format("%d-%m-%y") + ".txt";
		string data ="\n" + date.format("%H-%M-%S") + "\t" + msg + "\n";
		var outputFile = File.new_for_path(fname);
		
		try {
			var buf = new DataOutputStream(outputFile.append_to(FileCreateFlags.REPLACE_DESTINATION));
			buf.put_string(data);

		} catch (Error e) {
			stdout.printf("%s\n", e.message);
		}
	}

	public static void e(string _msg) {
		Helper.log("[ERROR] " + _msg);
	}

	public static void w(string _msg) {
		Helper.log("[WARN] " + _msg);
	}

	public static void i(string _msg) {
		Helper.log("[INFO] " + _msg);
	}

	public static void f(string _msg) {
		Helper.log("[FATAL] " + _msg);
	}

    public static string reduceString(string data, uint len){
        if(data.length <= len) {
            return data;
        }
        else {
            return (data.substring(0, len)).strip() + "…";
        }
    }
}