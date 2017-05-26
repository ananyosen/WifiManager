

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
    [GtkChild]
    private Button button_save_connect;
    [GtkChild]
    private Button button_add_dns;
    
    public signal void closeUnsaved();

    private NM.AccessPoint access_point = null;
    private NM.Connection nm_connection = null;
    private GenericArray<DnsUi> dns_list = null;
    
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

    private void extraDnsChangedCB(DnsUi ui) {
        string text = ui.get_text();
        bool valid = validateIP(text);
        ui.name = (valid)?"good":"bad";
    }

    private void extraDnsRemovedCB(DnsUi ui) {
        ui.disconnect(ui.handler_change);
        ui.disconnect(ui.handler_remove);
        this.dns_list.remove(ui);
        this.box_dns.remove(ui);
    }

    public ConfigIP(NM.AccessPoint _ap, NM.Connection _connection) {

        this.access_point = _ap;
        this.nm_connection = _connection;
        this.radio_static.join_group(radio_dhcp);
        this.radio_dhcp.toggled.connect(handle_toggle);
        this.radio_static.toggled.connect(handle_toggle);
        this.box_ip.set_sensitive(false); //fix TODO
        this.box_dns.set_sensitive(false); //fix TODO
        this.dns_list = new GenericArray<DnsUi>();
        this.button_cancel.clicked.connect(() => {
            closeUnsaved();
        });
        this.button_add_dns.clicked.connect(() => {
            DnsUi dns_ui = new DnsUi(dns_list.length);
            dns_ui.handler_change = dns_ui.uiChanged.connect(extraDnsChangedCB);
            dns_ui.handler_remove = dns_ui.removeClicked.connect(extraDnsRemovedCB);
            this.dns_list.add(dns_ui);
            this.box_dns.add(dns_ui);
        });
        this.entry_ip.changed.connect(ipChangedCB);
        this.entry_subnet.changed.connect(ipChangedCB);
        this.entry_gateway.changed.connect(ipChangedCB);
        this.entry_dns1.changed.connect(ipChangedCB);
        this.entry_dns2.changed.connect(ipChangedCB);
        //  this.button_cancel.name = "button1";
        Gtk.CssProvider css_provider = new Gtk.CssProvider();
        string css = "#bad{background-color: #e79e9e;} #good{background-color:#8ff291;}
         #remove{color: #ff3333;}";
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