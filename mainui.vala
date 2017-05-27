
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
        vp_all.add(box_all);
        scroll_all.add(vp_all);
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
        this.box_main.add(this.stack_ap);
        this.box_dev = new ListBox();
        this.vp_dev.add(this.box_dev);
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

    public MainUi() {
        this.init();
    }

    public void addDeviceUi(WifiUtility.WifiDevice _dev) {
        Box box_dev = new Box(Gtk.Orientation.VERTICAL, 0);
        Viewport vp_dev = new Viewport(null, null);
        ScrolledWindow scroll_dev = new ScrolledWindow(null, null);
        vp_dev.add(box_dev);
        scroll_dev.add(vp_dev);
        this.scroll_aps.add(scroll_dev);
        this.vp_aps.add(vp_dev);
        this.box_aps.add(box_dev);
        this.stack_ap.add(scroll_dev);
        DeviceUi dev_ui = new DeviceUi(_dev);
        dev_ui.index = this.scroll_aps.length - 1;
        this.device_uis.add(dev_ui);
        this.box_dev.add(dev_ui);
        //  this.dev_children = this.box_dev.get_children();
        //  dev_ui.clickedOnDevice.connect((_src) => {
        //      foreach(Widget _w in this.dev_children) {
        //          _w.name = "dev_applet";
        //      }
        //      _src.name = "dev_applet_selected";
        //  });
    }
}