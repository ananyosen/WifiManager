/*
* testing ground
 */

using Gtk;
using WifiUtility;

public void mainWindowDestroyed() {
    Gtk.main_quit();
}

int main(string[] args) {
    Gtk.init(ref args);

    Builder builder = new Builder();
    builder.add_from_file("window.ui");
    Window main_window = builder.get_object("window_main") as Window;
    main_window.key_release_event.connect((evt) => {
        if(evt.keyval == Gdk.Key.Escape) {
            main_window.close();
            Gtk.main_quit();
        }
        return true;
    });
    main_window.resize(600,600);
    Switch wifi_switch = builder.get_object("switch_wifi") as Switch;
    ScrolledWindow scroll_ap = builder.get_object("scroll_ap") as ScrolledWindow;
    ScrolledWindow scroll_dev = builder.get_object("scroll_dev") as ScrolledWindow;
    Button button_scan = builder.get_object("button_scan") as Button;
    scroll_ap.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
    Manager manager = new Manager();
    manager.initDevices();
    GenericArray<WifiDevice> devices = manager.getDevices();
    if(devices.length == 0) {
        //do something and return
    }
    Viewport vp_dev = new Viewport(null, null);
    Viewport vp_ap = new Viewport(null, null);
    Box box_dev = new Box(Gtk.Orientation.VERTICAL, 0);
    Box box_ap = new Box(Gtk.Orientation.VERTICAL, 0);
    vp_dev.add(box_dev);
    scroll_dev.add(vp_dev);
    vp_ap.add(box_ap);
    scroll_ap.add(vp_ap);
    Label all_dev = new Label("All Networks");
    box_dev.add(all_dev);
    for(int iii = 0; iii < devices.length; iii++) {
        box_dev.add(new Label(devices[iii].getProduct()));
        devices[iii].scan();
        devices[iii].scanDone.connect((_dev) => {
            int index = _dev.index;
            if(box_ap != null) {
                List<Widget> children = box_ap.get_children();
                foreach(Widget _ap in children) {
                    box_ap.remove(_ap);
                }
            }
            GenericArray<NM.AccessPoint> aps = new GenericArray<NM.AccessPoint>();
            _dev.getScannedAPs(ref aps);
            stdout.printf("\n length %d\n", aps.length);
            for(int jjj = 0; jjj < aps.length; jjj++) {
                NM.AccessPoint ap = aps[jjj];
                ApApplet applet = new ApApplet(_dev, ap);
                box_ap.add(applet);
            }
        });
        
    }
    wifi_switch.active = manager.wifiEnabled;
    wifi_switch.state_flags_changed.connect(() => {
        manager.wifiEnabled = wifi_switch.active;
    });
    button_scan.clicked.connect(()=>{
        stdout.printf("\n\n scan started \n\n");
        for(int iii = 0; iii < devices.length; iii++) {
            devices[iii].scan();
        }        
    });
    //  if(manager.num_of_devices > 0) {
    //      stdout.printf("product:  %s\n\n", manager.getDevices()[0].getProduct());
    //  }
    //   builder.connect_signals (null);
    main_window.destroy.connect(mainWindowDestroyed);
    main_window.show_all();
    Gtk.main();
    return 0;
}

