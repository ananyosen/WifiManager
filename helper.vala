class Helper : GLib.Object { 
    public static string path_prefix = "./log/";
    public static void log(string msg)
	{
		if (msg == null) {
			return;
		}
		var date = new DateTime.now_local();
		string fname = Helper.path_prefix + date.format("%d-%m-%y") + ".txt";
		string data ="\n" + date.format("%H-%M-%S") + "\t" + msg + "\n";
		var outputFile = File.new_for_path(fname);
		
		try {
			var buf = new DataOutputStream(outputFile.append_to(FileCreateFlags.REPLACE_DESTINATION));
			buf.put_string(data);

		} catch (Error e) {
			stdout.printf("%s\n", e.message);
		}
	}

    public static string reduceString(string data, uint len){
        if(data.length <= len) {
            return data;
        }
        else {
            return data.substring(0, len) + "…";
        }
    }
}