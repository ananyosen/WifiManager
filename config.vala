

using Gtk;

[GtkTemplate (ui = "/home/dexter/projects/vala/four/config.ui")]
class ConfigIP : Box { 
    [GtkChild]
    private Button button_cancel;
    [GtkChild]
    private RadioButton radio_dhcp;
    [GtkChild]
    private RadioButton radio_static;
    [GtkChild]
    private Box box_ip;
    [GtkChild]
    private Box box_dns;
    [GtkChild]
    private Entry entry_ip;
    [GtkChild]
    private Entry entry_subnet;
    [GtkChild]
    private Entry entry_gateway;
    [GtkChild]
    private Entry entry_dns1;
    [GtkChild]
    private Entry entry_dns2;
    
    public signal void closeUnsaved();

    private NM.AccessPoint access_point = null;
    private NM.Connection nm_connection = null;
    private GenericArray<Gtk.Widget> dns_list = null;
    
    private void handle_toggle() {
        bool _enabled = this.radio_static.get_active();
        this.box_ip.set_sensitive(_enabled);
        this.box_dns.set_sensitive(_enabled);
    }

    private bool validateIP(string text) {
        string[] parts = text.split(".");
        if(parts.length != 4) {
            return false;
        }
        foreach(string part in parts) {
            int p = int.parse(part);
            if(p > 255 || p < 0 || part.length < 1) {
                return false;
            }
        }
        return true;
    }

    private void ipChangedCB(Gtk.Editable _editable) {
        Gtk.Entry entry = (Gtk.Entry) _editable;
        string text = entry.get_text();
        bool valid = validateIP(text);
        entry.name = (valid)?"good":"bad";
    }

    public ConfigIP(NM.AccessPoint _ap, NM.Connection _connection) {

        this.access_point = _ap;
        this.nm_connection = _connection;
        this.radio_static.join_group(radio_dhcp);
        this.radio_dhcp.toggled.connect(handle_toggle);
        this.radio_static.toggled.connect(handle_toggle);
        this.box_ip.set_sensitive(false);
        this.box_dns.set_sensitive(false);
        this.button_cancel.clicked.connect(() => {
            closeUnsaved();
        });
        this.entry_ip.changed.connect(ipChangedCB);
        this.entry_subnet.changed.connect(ipChangedCB);
        this.entry_gateway.changed.connect(ipChangedCB);
        this.entry_dns1.changed.connect(ipChangedCB);
        this.entry_dns2.changed.connect(ipChangedCB);
        //  this.button_cancel.name = "button1";
        Gtk.CssProvider css_provider = new Gtk.CssProvider();
        string css = "#bad{background-color: #e79e9e;} #good{background-color:#8ff291;}";
        try {
            css_provider.load_from_data(css);
        }
        catch(GLib.Error err) {
            stdout.printf("\n ERROR LOADING CSS AT config.vala \n\n");
        }
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), 
            css_provider,     
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

    }
}