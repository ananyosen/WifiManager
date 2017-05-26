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

    //   private int deviceID = -1;
    //   private int apID = -1; 
    private WifiUtility.WifiDevice device = null;
    private NM.AccessPoint access_point = null;
    private Gtk.Window config_window = null;
    private ConfigIP config_ip = null;
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

     public ApApplet(WifiUtility.WifiDevice _device, NM.AccessPoint _ap) {
        this.device = _device;
        this.access_point = _ap;
        this.mac = _ap.bssid;
        this.ssid = NM.Utils.ssid_to_utf8(_ap.get_ssid());
        this.freq = _ap.frequency.to_string();
        this.strength = (int)_ap.strength;
        this.channel = (NM.Utils.wifi_freq_to_channel(_ap.frequency)).to_string();

        button_connect.clicked.connect(() => {
             connectClicked();
         });
        button_mod_connect.clicked.connect(() => {
            if(this.config_window != null) {
                this.config_window.present();
                return;
            }
            this.config_window = new Gtk.Window();
            this.config_ip = new ConfigIP(this.access_point, new NM.Connection());
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
                return true;
            });
            this.config_window.show_all();
             modConnectClicked();
         });
     }
     public signal void connectClicked();
     public signal void modConnectClicked();
 }