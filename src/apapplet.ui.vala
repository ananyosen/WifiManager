/**
 * One access point view
 **/

 using Gtk;

 [GtkTemplate (ui = "/home/dexter/projects/vala/four/apapplet.ui")]
 public class ApApplet : Box {

     [GtkChild]
     private Label ap_name;
     [GtkChild]
     private Label ap_security;
     [GtkChild]
     private Label text_mac;
     [GtkChild]
     private Label text_freq;
     [GtkChild]
     private Label text_strength;
     [GtkChild]
     private Label text_saved;
     [GtkChild]
     private Button button_connect;
     [GtkChild]
     private Button button_mod_connect;
     [GtkChild]
     private Label text_channel;
     [GtkChild]
     private Button button_delete;
     [GtkChild]
     private Label label_ip_type;
     [GtkChild]
     private Label label_applet_ip;
     [GtkChild]
     private Label label_applet_subnet;
     [GtkChild]
     private Label label_applet_gateway;
     [GtkChild]
     private Box box_ip_container;

    //   private int deviceID = -1;
    //   private int apID = -1; 
    private WifiUtility.WifiDevice device = null;
    private NM.AccessPoint access_point = null;
    private Gtk.Window config_window = null;
    private ConfigIP config_ip = null;
    private NM.Connection remote_connection = null;
    private NM.SettingIP4Config setting_ip4_config;

    private NM.IP4Address default_ip4;
    private bool modified = false;

    private bool matched;
    private bool is_dhcp4 = true;
    public string ssid {
         set {ap_name.label = value;}
        //   get {return this.ssid;}
     }
     
     public string security {
         set {ap_security.label = value;}         
     }
     
     public string mac {
         set {text_mac.label = value;}         
     }

     public string freq {
         set {text_freq.label = value + " MHz";}         
     }

     public int strength {
         set {
                 string t = "";
                 if(value < 10) {
                     t = "NA";
                 }
                 else if(value < 30) {
                     t = "Poor";
                 }
                 else if(value < 60) {
                     t = "Medium";
                 }
                 else if(value < 90) {
                     t = "Good";
                 }
                 else if(value <=100) {
                     t = "Glorious";
                 }
                 text_strength.label = t + " (" + value.to_string() + ")";
            }         
     }

     public bool saved {
         set {text_saved.label = (value)?"saved":"not saved";}         
     }

     public string channel {
         set {text_channel.label ="CH: " + value;}         
     }

     public void remoteCOnnectionRemovedCB(NM.RemoteConnection _connection, GLib.Error err) {

         stdout.printf("\n remote connection removed\n");

     }

     public ApApplet(WifiUtility.WifiDevice _device, NM.AccessPoint _ap, bool _matched, NM.Connection _connection = new NM.Connection()) {
        this.name = "ap_applet";
        this.set_margin_bottom(3);
        this.set_margin_top(2);
        this.set_margin_left(1);
        this.set_margin_right(1);
        this.device = _device;
        this.access_point = _ap;
        this.remote_connection = _connection;
        this.matched = _matched;
        this.setting_ip4_config = this.remote_connection.get_setting_ip4_config();
        this.text_saved.label = (this.matched)?"saved":"not saved";
        if(this.matched) {
            string _ip4_method = this.setting_ip4_config.method;
            this.is_dhcp4 = (_ip4_method == "auto");
        }
       this.button_delete.set_sensitive(this.matched);
       this.button_mod_connect.set_sensitive(this.matched);
        this.mac = _ap.bssid;
        this.ssid = NM.Utils.ssid_to_utf8(_ap.get_ssid());
        this.freq = _ap.frequency.to_string();
        this.strength = (int)_ap.strength;
        this.channel = (NM.Utils.wifi_freq_to_channel(_ap.frequency)).to_string();
        this.box_ip_container.name = "applet_ip_container";
        this.box_ip_container.set_margin_top(5);
        if(!this.is_dhcp4) {
            if(this.setting_ip4_config.get_num_addresses() > 0) {

                /**
                 * Method 1: NM.IP4Address = NM.SettingIP4Config.get_address(index);
                 * 
                 * problem: NM.IP4Address causes segfault on deref 
                 * and probably .get_address(index) removes it from NM.SettingIP4Config
                 **/    

                /**
                 * Method 2: 
                 * 
                 * HashTable <string, GLib.Value?> _setting_ip4_config = this.setting_ip4_config.to_hash(NM.SettingHashFlags.NO_SECRETS);
                weak GenericArray<Array<uint>> _addresses = (GenericArray<Array<uint>>) _setting_ip4_config.@get("addresses");
                Array<uint> _ip4_network_ints = _addresses[0];
                *
                * problem:  netmask not always accurate
                *
                **/

                /**
                 * Method 3: DIY 
                 **/
                //TODO: Deal with multiple addresses
                GenericArray<Array<string>> _data_all =  Helper.parseSettingString(this.setting_ip4_config.to_string());
                Array<string> _data = _data_all[0];
                uint32 _netmask_prefix = int.parse(_data.data[1]);
                stdout.printf("\n netmask: %d\n", (int)_netmask_prefix);
                uint32 _netmask = NM.Utils.ip4_prefix_to_netmask(_netmask_prefix);
                this.label_ip_type.label = "Static";
                this.label_applet_ip.label = _data.data[0];
                this.label_applet_gateway.label = _data.data[2];
                this.label_applet_subnet.label = Helper.networkIntToIp4Dotted(_netmask);
            }
        }
        else {
            this.label_ip_type.label = "DHCP";
            this.label_applet_ip.label = "";
            this.label_applet_gateway.label = "";
            this.label_applet_subnet.label = "";
        }
        button_connect.clicked.connect(() => {
            NM.Client _client = new NM.Client();
            if(this.matched) {
                _client.activate_connection(
                    this.remote_connection, 
                    this.device.getRawDevice(),
                    this.access_point.get_path(),
                    (one, two, three) => {

                    }
                );
            }
            else {
                //  NM.SettingIP4Config _sett = new NM.SettingIP4Config();
                //  if(this.modified) {
                //      _sett.add_address(this.default_ip4);
                //  }
                //  stdout.printf("\n\nsett\n\n" + _sett.to_string());
                //  NM.Connection _cnn = new NM.Connection.from_hash(
                //      (HashTable<string,GLib.HashTable<weak void*,weak void*>>)_sett.to_hash(NM.SettingHashFlags.ALL)
                //      );
                NM.Connection _cnn = new NM.Connection();
                //  _cnn.add_setting(_sett);
                _client.add_and_activate_connection(
                    _cnn,
                    this.device.getRawDevice(),
                    this.access_point.get_path(),
                    (client, device, path, error) => {
                        
                    }
                );
            }
             connectClicked();
         });
        button_delete.clicked.connect(()=>{
            NM.RemoteConnection _remote = (NM.RemoteConnection) this.remote_connection;
            _remote.@delete(this.remoteCOnnectionRemovedCB);
        });
        button_mod_connect.clicked.connect(() => {
            if(this.config_window != null) {
                this.config_window.present();
                return;
            }
            this.config_window = new Gtk.Window();
            this.config_ip = new ConfigIP(this.access_point, this.remote_connection, this.is_dhcp4);
            this.config_window.set_resizable(false);
            Label window_title = new Gtk.Label("Config: " + NM.Utils.ssid_to_utf8(this.access_point.get_ssid()));
            window_title.set_margin_top(5);
            window_title.set_margin_bottom(5);
            Gtk.Box _title_box = new Box(Gtk.Orientation.VERTICAL, 0);
            _title_box.add(window_title);
            this.config_window.set_titlebar((Widget)_title_box);
            this.config_ip.closeUnsaved.connect(() => {
                this.config_window.close();
                //do something
                this.config_window = null;
            });
            this.config_window.add(this.config_ip);
            this.config_window.key_release_event.connect((evt) => {
                if(evt.keyval == Gdk.Key.Escape) {
                    this.config_window.close();
                    //do something
                    this.config_window = null;
                }
                return false;
            });
            this.config_window.show_all();
             modConnectClicked();
         });
     }

     public WifiUtility.WifiDevice getDevice() {
         return this.device;
     }

     public signal void connectClicked();
     public signal void modConnectClicked();
 }