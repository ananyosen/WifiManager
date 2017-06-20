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

	public static string uint8ToHex(uint8 data) {
		if(data < 0 || data > 255) {
			return "";
		}
		if(data == 0) {
			return "00";
		}
		string[] letters = {"a", "b", "c", "d", "e", "f"};
		uint8 div = data;
		uint8 rem;
		string res = "";

		while(div != 0) {
			rem = div%16;
			div = div/16;
			string h = (rem < 10)?rem.to_string():letters[rem - 10];
			res = h + res;
		}
		if(res.length == 1) {
			res = "0" + res;
		}
		return res;
	}

	public static string uint32ToHex(uint32 data) {
		string[] letters = {"a", "b", "c", "d", "e", "f"};
		uint32 div = data;
		uint32 rem;
		string res = "";

		while(div != 0) {
			rem = div%16;
			div = div/16;
			string h = (rem < 10)?rem.to_string():letters[rem - 10];
			res = h + res;
		}
		for(int iii = res.length; iii < 8; iii++) {
			res = "0" + res;
		}
		return res;
	}

	public static uint32 hexToUint32(string _hex) {
		uint8 len = (uint8)sizeof(uint32)/4;
		string hex = _hex.down();
		uint32 res = 0;
		if(hex.length > len) {
			//error
		}
		for(uint8 iii = 0; iii < hex.length; iii++) {
			string s = hex.substring(iii, 1);
			int curr = 0;
			switch (s) {
				case "a":
				curr =  10;
				break;
				case "b":
				curr =  11;
				break;
				case "c":
				curr =  12;
				break;
				case "d":
				curr =  13;
				break;
				case "e":
				curr =  14;
				break;
				case "f":
				curr =  15;
				break;
				default:
				curr =  int.parse(s);
				break;
			}
			res = res*16 + curr;
		}
		return res;
	}

	public static uint32 ip4DottedToNetworkInt(string _ip4) {
		string[] parts = _ip4.split(".");
		string hex = "";
		foreach(string part in parts) {
			hex = Helper.uint8ToHex((uint8)int.parse(part)) + hex;
		}
		uint32 net_int = Helper.hexToUint32(hex);
		return net_int;
	}

	public static string networkIntToIp4Dotted(uint32 _ip) {
		string hex = Helper.uint32ToHex(_ip);
		string res = "";
		for(int iii = 0; iii < 4; iii++) {
			string part_s = hex.substring(2*iii, 2);
			uint32 part_i = Helper.hexToUint32(part_s);
			res = part_i.to_string() + "." + res;
		}
		res = res.substring(0, res.length - 1);
		return res;
	}

	public static string getStringPart(string _src, string _start, string _end) {
		//  string _start = "addresses : ";
		//  string _end = "(";
		string _part = "";
		uint _index_start = _src.index_of(_start, 0);
		uint _index_end = _src.index_of(_end, (int)_index_start);
		_part = _src.substring(_index_start + _start.length, _index_end - _index_start - _start.length).strip();
		return _part;
	}

	public static GenericArray<Array<string>> parseSettingString(string _setting) {
		string parsed = Helper.getStringPart(_setting, "addresses : ", "(");
		GenericArray<Array<string>> data = new GenericArray<Array<string>>();
		string[] parsed_parts = parsed.split(";");
		foreach(string _parsed_part in parsed_parts) {
			_parsed_part = _parsed_part.strip();
			string[] _ip_parts = _parsed_part.split(",");
			string _ip = Helper.getStringPart(_ip_parts[0], "{ ip = ", "/");
			string _netmask = _ip_parts[0].split("/")[1];
			string _gateway = Helper.getStringPart(_ip_parts[1], "gw = ", " }");
			Array<string> _current_ip4 = new Array<string>();
			_current_ip4.append_val(_ip);
			_current_ip4.append_val(_netmask);
			_current_ip4.append_val(_gateway);
			data.add(_current_ip4);
			//  stdout.printf("x" + _gateway + "x\n");
		}
		return data;
	}
}