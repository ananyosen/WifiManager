/* main */
using WifiUtility;

class Activity : Gtk.Window { 
    
    MainUi main_ui = null;
    NM.RemoteSettings remote_settings = null;
    WifiUtility.Manager manager = null;
    GenericArray<WifiUtility.WifiDevice> devices = null;

    ulong connections_read_handler = 0;

    private void initWireless() {
        if(this.connections_read_handler !=0 && this.remote_settings != null) {
            this.remote_settings.disconnect(this.connections_read_handler);
        } 
        else {
            this.connections_read_handler = 0;
        }
        if(this.main_ui != null) {
            this.main_ui.destroyData();
        }
        else {
            this.main_ui = new MainUi();
        }
        this.main_ui.init();
        if(this.manager == null) {
            this.manager = new WifiUtility.Manager();
        }
        if(this.manager.devices_changed_handler == 0) {
            this.manager.devices_changed_handler = manager.devicesChanged.connect(() => {
                this.initWireless();
            });
        }
        this.manager.initDevices();
        this.devices = manager.getDevices();
        if(this.devices.length == 0) {
            //show error and close
        }
        this.devices.foreach((_wd) => {
            _wd.stateChanged.connect((_wifidevice, _old_state, _new_state, _reason) => {
                this.refreshActiveConnections();
                Helper.i(
                    "device state changed for: " + _wifidevice.getProduct() 
                    + "\n old state: " + _old_state.to_string() 
                    + ", new state: " + _new_state.to_string() 
                    + ", reason: " + _reason.to_string());
                    this.main_ui.wifi_on = this.manager.wifiEnabled;
            });
            this.main_ui.addDeviceUi(_wd);
        });
        this.scanForNetworksCallback();
        this.scanForNetworks();
    }

    private void scanForNetworksCallback() {
         if(this.devices == null) {
            return;
        }
        this.devices.foreach((_wd) => {
            _wd.scanDone.connect((_wdev) => {
                GenericArray<NM.AccessPoint> _aps = new GenericArray<NM.AccessPoint>();
                _wdev.getScannedAPs(ref _aps);
                this.main_ui.addAccessPoints(_aps, _wdev);
            });
        });
    }

    private void scanForNetworks() {
        if(this.devices == null) {
            return;
        }
        this.devices.foreach((_wd) => {
            _wd.scan();
        });
    }

    private void refreshActiveConnections() {
        if(this.manager != null) {
            this.manager.reloadActiveConnections();
            if(this.main_ui != null) {
                this.main_ui.updateActiveConnections(this.manager.getActiveConnections());
            }
        }
        this.scanForNetworks();
    }

    private void reloadConnections() {
        this.refreshActiveConnections();
        if(this.manager != null && this.remote_settings != null) {
            this.manager.readSavedNetworks(this.remote_settings);
        }
        this.main_ui.updateSavedSettings(manager.getRemoteConnections());
    }

    private void stylise() {
        string css_string = 
            "#bad_ip{background-color:#e79e9e}
            #good_ip{background-color:#8ff291}
            #remove_dns{color:#ff3333}
            #ap_list{background-color:#ffffff;border:1px solid #ccc;border-radius:3px}
            #ap_applet{border-bottom:1px solid #ccc}
            #applet_ip_container{border-top:1px dashed #ccc}
            #dev_list{border-radius:3px}";
        Gtk.CssProvider css_provider = new Gtk.CssProvider();
        try {
            css_provider.load_from_data(css_string, css_string.length);
        }
        catch(GLib.Error e) {
            Helper.e("parse error in css");
        }
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), 
            css_provider,     
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    public Activity() {
        this.title = "Wifi Utility";
        this.name = "main_window";

        this.key_release_event.connect((evt) => {
            if(evt.keyval == Gdk.Key.Escape) {
                this.close();
                Gtk.main_quit();
            }
            return false;
        }); 
        this.destroy.connect(() => {
            Gtk.main_quit();
        });

        this.main_ui = new MainUi();
        this.add(main_ui);
        this.remote_settings = new NM.RemoteSettings(null);

        this.initWireless();

       this.remote_settings.new_connection.connect(this.reloadConnections);
        this.connections_read_handler = this.remote_settings.connections_read.connect((_rm_sett) => {
            this.reloadConnections();
            this.scanForNetworks();
        });

        this.manager.connectionsChanged.connect(this.reloadConnections);
        this.main_ui.wifi_on = this.manager.wifiEnabled;
        this.main_ui.wifiSwitchToggled.connect(() => {
            this.manager.wifiEnabled = this.main_ui.wifi_on;
        });
        this.main_ui.startScan.connect(this.scanForNetworks);

        this.stylise();
    }

    public static int main(string[] args) {
        Gtk.init(ref args);
        Activity window = new Activity();
        window.show_all();
        Gtk.main();
        return 0;
    }
}