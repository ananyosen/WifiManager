
using Gtk;

[GtkTemplate (ui="/home/dexter/projects/vala/four/main.ui")]
class MainUi : Gtk.Box { 
    [GtkChild]
    private Switch switch_wifi;
    [GtkChild]
    private Button button_scan;
    [GtkChild]
    private Box box_main;
    [GtkChild]
    private ScrolledWindow scroll_dev;

    private Viewport vp_ap = null;
    private Viewport vp_dev = null;
    private ListBox box_dev = null;
    private Box box_ap = null;
    private Label label_all_net;
    private Box all_net_box;
    //  private List<Widget> dev_children;
    //  private List<Widget> ap_children;
    private Gtk.Stack stack_ap = null;

    private GenericArray<Gtk.ScrolledWindow> scroll_aps = null;
    private GenericArray<Gtk.Viewport> vp_aps = null;
    private GenericArray<Gtk.Box> box_aps = null;
    private GenericArray<DeviceUi> device_uis = null;

    private GenericArray<NM.RemoteConnection> remote_connections = null;
    

    public bool wifi_on {
        set {this.switch_wifi.active = value;}
        get {return this.switch_wifi.active;}
    }

    public signal void wifiSwitchToggled();
    public signal void startScan();

    private void setAllNetworks() {
        this.all_net_box = new Box(Gtk.Orientation.VERTICAL, 0);
        this.all_net_box.set_margin_bottom(5);
        this.label_all_net = new Label("All Networks");
        this.label_all_net.set_margin_bottom(3);
        this.label_all_net.set_margin_top(3);
        this.all_net_box.add(this.label_all_net);
        this.box_dev.add(this.all_net_box);
        Box box_all = new Box(Gtk.Orientation.VERTICAL, 0);
        Viewport vp_all = new Viewport(null, null);
        ScrolledWindow scroll_all = new ScrolledWindow(null, null);
        box_all.hexpand = true;
        box_all.vexpand = true;
        box_all.name = "ap_list";        
        vp_all.add(box_all);
        scroll_all.add(vp_all);
        scroll_all.set_min_content_width(400);
        scroll_all.set_min_content_height(250);
        this.scroll_aps.add(scroll_all);
        this.vp_aps.add(vp_all);
        this.box_aps.add(box_all);
        this.stack_ap.add(scroll_all);
    }

    public void init() {
        this.vp_dev = new Viewport(null, null);
        this.scroll_aps = new GenericArray<Gtk.ScrolledWindow>();
        this.vp_aps = new GenericArray<Gtk.Viewport>();
        this.box_aps = new GenericArray<Gtk.Box>();
        this.device_uis = new GenericArray<DeviceUi>();
        //  this.vp_ap = new Viewport(null, null);
        this.stack_ap = new Stack();
        this.stack_ap.vexpand = true;
        this.stack_ap.hexpand = true;
        this.stack_ap.name = "ap_list";
        this.stack_ap.set_border_width(1);
        this.stack_ap.set_margin_left(10);
        this.stack_ap.set_margin_right(10);  
        //  this.stack_ap.set_size_request(600, 500);      
        this.box_main.add(this.stack_ap);
        this.box_dev = new ListBox();
        this.vp_dev.add(this.box_dev);
        this.scroll_dev.name = "dev_list";
        this.scroll_dev.add(this.vp_dev);
        this.setAllNetworks();

        this.switch_wifi.state_flags_changed.connect(() => {
            this.wifiSwitchToggled();
        });
        this.button_scan.clicked.connect(() => {
            this.startScan();
        });
        box_dev.row_selected.connect((row) => {
            if(row == null) {
                return;
            }
            int index = row.get_index();
            this.stack_ap.set_visible_child(this.scroll_aps[index]);
        });
        ListBoxRow first = box_dev.get_row_at_index(0);
        box_dev.select_row(first);
        first.activate();
    }

    public void destroyData() {
        if(this.scroll_aps != null) {
            for(int iii = 0; iii < this.scroll_aps.length; iii++) {
                List<weak Widget> _ws = this.scroll_aps[iii].get_children();
                foreach(Widget _w in _ws) {
                    this.scroll_aps[iii].remove(_w);
                }
            }
        }
        if(this.box_main != null) {
            this.box_main.remove(this.stack_ap);
        }
        if(this.scroll_dev != null) {
            this.scroll_dev.remove(this.vp_dev);
        }
        this.scroll_aps = null;
        this.box_aps = null;
        this.vp_aps = null;
        this.device_uis = null;
    }

    public MainUi() {
        this.init();
    }

    public void addDeviceUi(WifiUtility.WifiDevice _dev) {
        Box box_ap_ = new Box(Gtk.Orientation.VERTICAL, 0);
        box_ap_.hexpand = true;
        box_ap_.vexpand = true;
        box_ap_.name = "ap_list";
        Viewport vp_dev = new Viewport(null, null);
        ScrolledWindow _scroll_dev = new ScrolledWindow(null, null);
        _scroll_dev.set_min_content_width(400);
        _scroll_dev.set_min_content_height(250);
        vp_dev.add(box_ap_);
        _scroll_dev.add(vp_dev);
        this.scroll_aps.add(_scroll_dev);
        this.vp_aps.add(vp_dev);
        this.box_aps.add(box_ap_);
        this.stack_ap.add(_scroll_dev);
        DeviceUi dev_ui = new DeviceUi(_dev);
        dev_ui.index = this.scroll_aps.length - 1;
        this.device_uis.add(dev_ui);
        this.box_dev.add(dev_ui);
        _dev.added = true;
    }

    public void addAccessPoints(GenericArray<NM.AccessPoint> _aps, WifiUtility.WifiDevice _device) {
        stdout.printf("\n\nhere\n\n");        
        GenericArray<NM.AccessPoint> _own_aps = _aps;
        if(_device.added && _device.index < scroll_aps.length - 1) {
            Box _box_ap = box_aps[_device.index + 1];
            if(_box_ap != null) {
                List<weak Widget> _ws = _box_ap.get_children();
                foreach(Widget _w in _ws) {
                        _box_ap.remove(_w);
                }
            }
            Box _box_all = this.box_aps[0];
            if(_box_all != null ) {
                List<weak Widget> _wss = _box_all.get_children();
                foreach(Widget _w in _wss) {
                    ApApplet _ap = (ApApplet) _w;
                    if(_ap.getDevice().index == _device.index) {
                        _box_all.remove(_w);

                    }
                }
            }

            //NEW METHOD: MATCH NM.AccessPoint TO NM.Connection

            if(this.remote_connections == null) {
                Helper.w("[mainui.vala] Object (remote_connections == null) true, proper init required");
                return;
            }
            //fast match and removal
            GenericArray<int> _matched_indexs = new GenericArray<int>();

            for(int iii = 0; iii < this.remote_connections.length; iii++) {
                NM.Connection _ap_connection = (NM.Connection) this.remote_connections[iii];
                for(int jjj = 0; jjj < _aps.length; jjj++) {
                    NM.AccessPoint _ap = _aps[jjj];
                    bool _matched = _ap.connection_valid(_ap_connection);
                    if(_matched) {
                        _matched_indexs.remove_fast(jjj);
                        _matched_indexs.add(jjj);
                        Helper.i("[mainui.vala] ap: " + _ap.get_path() +  " matched with: " + _ap_connection.get_path()); 
                        //  NM.SettingIP4Config _ip4_config = _ap_connection.get_setting_ip4_config();
                        //  NM.IP4Address a1 = _ip4_config.get_address(0);
                        //  NM.IP4Address a2 = a1.dup();
                        //  ApApplet applet_all = new ApApplet(_device, _ap, _matched, _ap_connection, a1);
                        //  ApApplet _applet = new ApApplet(_device, _ap, _matched, _ap_connection, a2);
                        // 
                        ApApplet applet_all = new ApApplet(_device, _ap, _matched, _ap_connection);
                        ApApplet _applet = new ApApplet(_device, _ap, _matched, _ap_connection); 
                        _box_ap.add(_applet);
                        _box_all.add(applet_all);
                    }
                }
            }

            for(int iii = 0; iii < _aps.length; iii++) {
                if(!_matched_indexs.remove_fast(iii)) {
                    NM.AccessPoint _ap = _aps[iii];
                    Helper.i("[mainui.vala] unmatched ap: " + _ap.get_path());                        
                    ApApplet _applet = new ApApplet(_device, _ap, false, new NM.Connection());
                    ApApplet applet_all = new ApApplet(_device, _ap, false, new NM.Connection());
                    _box_ap.add(_applet);
                    _box_all.add(applet_all);
                }
            }


            //END NEW METHOD


            //OLD METHOD: MATCH NM.Connection TO NM.AccessPoint

            //  for(int iii = 0; iii < _aps.length; iii++) {
            //      if(this.remote_connections == null) {
            //          Helper.w("[mainui.vala] Object (remote_connections == null) true, proper init required");
            //          return;
            //      }
            //      NM.AccessPoint _ap = _aps[iii];
            //      NM.Connection _ap_connection = null;
            //      bool _matched = false;
            //      for(int jjj = 0; jjj < this.remote_connections.length; jjj++) {
            //          NM.Connection _connection = (NM.Connection)this.remote_connections[jjj];
            //          if(_ap.connection_valid(_connection)) {
            //              _matched = true;
            //              _ap_connection = _connection;
            //              Helper.i("[mainui.vala] ap: " + _ap.get_path() +  " matched with: " + _connection.get_path());
            //              break;
            //          }
            //          //DO NOT DELETE

            //          //  NM.SettingWireless _setting = this.remote_connections[jjj].get_setting_wireless();
            //          //  string _s1 = NM.Utils.ssid_to_utf8(_setting.get_ssid());
            //          //  string _s2 = NM.Utils.ssid_to_utf8(_ap.get_ssid());
            //          //  bool a = (_s1 == _s2);
            //          //  NM.SettingWirelessSecurity _setting_security = this.remote_connections[jjj].get_setting_wireless_security();
            //          //  bool _connection_is_wpa = (_setting_security.key_mgmt == "wpa-psk");
            //          //  bool _connection_is_wep = (_setting_security.key_mgmt == "open" || _setting_security.key_mgmt == "ieee8021x");
            //          //  bool _ap_is_wpa1 = (_ap.wpa_flags != 0);
            //          //  bool _ap_is_wpa2 = (_ap.rsn_flags != 0);

            //          //DO NOT DELETE
            //      }
            //      if(_ap_connection == null) {
            //          _ap_connection = new NM.Connection();
            //          Helper.i("[mainui.vala] unmatched ap: " + _ap.get_path());
            //      }
            //      ApApplet _applet = new ApApplet(_device, _ap, _matched, _ap_connection);
            //      ApApplet applet_all = new ApApplet(_device, _ap, _matched, _ap_connection);
            //      _box_ap.add(_applet);
            //      _box_all.add(applet_all);
            //  }

            //END OLD METHOD

        }
    }

    public void updateSavedSettings(GenericArray<NM.RemoteConnection> _connections) {
        this.remote_connections = _connections;
        Helper.i("[mainui.vala] remote_settings size : " + this.remote_connections.length.to_string());
        for(int iii = 0; iii < this.remote_connections.length; iii++) {
            NM.RemoteConnection _c = this.remote_connections[iii];
            NM.SettingWireless _s = _c.get_setting_wireless();
            string _setting_ = _s.to_string();
            Helper.i("[mainui.vala] saved network: " + _setting_);
        }
    }
}