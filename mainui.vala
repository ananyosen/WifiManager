
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
        scroll_all.set_min_content_width(350);
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
        for(int iii = 0; iii < scroll_aps.length; iii++) {
            List<Widget> _ws = scroll_aps[iii].get_children();
            foreach(Widget _w in _ws) {
                scroll_aps[iii].remove(_w);
            }
        }
        this.box_main.remove(this.stack_ap);
        this.scroll_dev.remove(this.vp_dev);
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
        _scroll_dev.set_min_content_width(350);
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
        if(_device.added && _device.index < scroll_aps.length - 1) {
            Box _box_ap = box_aps[_device.index + 1];
            if(_box_ap != null) {
                List<Widget> _ws = _box_ap.get_children();
                foreach(Widget _w in _ws) {
                        _box_ap.remove(_w);
                }
            }
            Box _box_all = this.box_aps[0];
            if(_box_all != null ) {
                List<Widget> _wss = _box_all.get_children();
                foreach(Widget _w in _wss) {
                    ApApplet _ap = (ApApplet) _w;
                    if(_ap.getDevice().index == _device.index) {
                        _box_all.remove(_w);

                    }
                }
            }
            for(int iii = 0; iii < _aps.length; iii++) {
                ApApplet _applet = new ApApplet(_device, _aps[iii]);
                ApApplet applet_all = new ApApplet(_device, _aps[iii]);
                _box_ap.add(_applet);
                _box_all.add(applet_all);
                //  stdout.printf("\n ap added index: %d\n", iii);
            }
        }
    }

    public void updateSavedSettings(GenericArray<NM.RemoteConnection> _connections) {
        this.remote_connections = _connections;
    }
}