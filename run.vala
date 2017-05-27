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
    Window main_window = new Window();
    main_window.set_title("Wifi Utility");
    main_window.key_release_event.connect((evt) => {
        if(evt.keyval == Gdk.Key.Escape) {
            main_window.close();
            Gtk.main_quit();
        }
        return false;
    });
    main_window.name = "main_window";
    MainUi main_ui = new MainUi();
    main_window.add(main_ui);
    Manager manager = new Manager();
    manager.initDevices();
    GenericArray<WifiDevice> devices = manager.getDevices();
    if(devices.length == 0) {
        //do something and return
    }
    for(int iii = 0; iii < devices.length; iii++) {
        WifiDevice _dev = devices[iii];
        main_ui.addDeviceUi(_dev);
    }
    //  for(int iii = 0; iii < devices.length; iii++) {
    //      box_dev.add(new Label(devices[iii].getProduct()));
    //      devices[iii].scan();
    //      devices[iii].scanDone.connect((_dev) => {
    //          int index = _dev.index;
    //          if(box_ap != null) {
    //              List<Widget> children = box_ap.get_children();
    //              foreach(Widget _ap in children) {
    //                  box_ap.remove(_ap);
    //              }
    //          }
    //          GenericArray<NM.AccessPoint> aps = new GenericArray<NM.AccessPoint>();
    //          _dev.getScannedAPs(ref aps);
    //          stdout.printf("\n length %d\n", aps.length);
    //          for(int jjj = 0; jjj < aps.length; jjj++) {
    //              NM.AccessPoint ap = aps[jjj];
    //              ApApplet applet = new ApApplet(_dev, ap);
    //              box_ap.add(applet);
    //          }
    //      });
        
    //  }
    main_ui.wifi_on = manager.wifiEnabled;
    main_ui.wifiSwitchToggled.connect(() => {
        manager.wifiEnabled = main_ui.wifi_on;
    });
    main_ui.startScan.connect(()=>{
        stdout.printf("\n\n scan started \n\n");
        for(int iii = 0; iii < devices.length; iii++) {
            devices[iii].scan();
        }        
    });


        Gtk.CssProvider css_provider = new Gtk.CssProvider();
        string css = "#bad_ip{background-color: #e79e9e;}
         #good_ip{background-color:#8ff291;}
         #remove_dns{color: #ff3333;}
         #ap_applet{background-color: #efefef; box-shadow: 3px 0 3px 3px #cccccc;}
         #main_window{}";
        try {
            css_provider.load_from_data(css);
        }
        catch(GLib.Error err) {
            Helper.log("ERROR LOADING CSS AT config.vala");
        }
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), 
            css_provider,     
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    //  if(manager.num_of_devices > 0) {
    //      stdout.printf("product:  %s\n\n", manager.getDevices()[0].getProduct());
    //  }
    //   builder.connect_signals (null);
    main_window.destroy.connect(mainWindowDestroyed);
    main_window.show_all();
    int _w = 0, _h = 0;
    main_window.get_size(out _w, out _h);
    main_window.resize(_w,400);
    Gtk.main();
    return 0;
}

