

using Gtk;

[GtkTemplate (ui = "F:/Skydrive/Project/github/Wifi-Utility/config.ui" )]class ConfigIP : Box { 
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
    private NM.SettingIP4Config setting_ip4_config= null;
    private NM.IP4Address default_ip4 = null;
    private bool is_dhcp4;
    
    private void handle_toggle() {
        bool _enabled = this.radio_static.get_active();
        this.box_ip.set_sensitive(_enabled);
        this.box_dns.set_sensitive(_enabled);
    }

    private bool validateIP4(string text) {
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
        bool valid = validateIP4(text);
        entry.name = (valid)?"good_ip":"bad_ip";
    }

    private void extraDnsChangedCB(DnsUi ui) {
        string text = ui.text;
        bool valid = validateIP4(text);
        ui.name = (valid)?"good_ip":"bad_ip";
    }

    private void extraDnsRemovedCB(DnsUi ui) {
        ui.disconnect(ui.handler_change);
        ui.disconnect(ui.handler_remove);
        this.dns_list.remove(ui);
        this.box_dns.remove(ui);
    }

    public ConfigIP(NM.AccessPoint _ap, NM.Connection _connection, bool _is_dhcp4) {

        this.access_point = _ap;
        this.nm_connection = _connection;
        this.radio_static.join_group(radio_dhcp);
        this.radio_dhcp.toggled.connect(handle_toggle);
        this.radio_static.toggled.connect(handle_toggle);
        this.is_dhcp4 = _is_dhcp4;
        this.dns_list = new GenericArray<DnsUi>();        
        if(this.is_dhcp4) {
            this.radio_dhcp.active = true;
        }
        else {
            this.radio_static.active = true;
        }
        this.box_ip.set_sensitive(!this.is_dhcp4); //fix TODO: DONE
        this.box_dns.set_sensitive(!this.is_dhcp4); //fix TODO: DONE
        if(!this.is_dhcp4) {
            this.setting_ip4_config = this.nm_connection.get_setting_ip4_config();
            if(this.setting_ip4_config.get_num_addresses() > 0) {
                this.default_ip4 = this.setting_ip4_config.get_address(0); //TODO : think about alternate addresses
                uint32 _ip4 = this.default_ip4.get_address();
                uint32 _gateway = this.default_ip4.get_gateway();
                uint32 _netmask_prefix = this.default_ip4.get_prefix();
                uint32 _netmask = NM.Utils.ip4_prefix_to_netmask(_netmask_prefix);
                this.entry_ip.text = Helper.networkIntToIp4Dotted(_ip4);
                this.entry_gateway.text = Helper.networkIntToIp4Dotted(_gateway);
                this.entry_subnet.text = Helper.networkIntToIp4Dotted(_netmask);
            }
            uint _num_dns = this.setting_ip4_config.get_num_dns();
            if(_num_dns > 0) {
                this.entry_dns1.text = Helper.networkIntToIp4Dotted(this.setting_ip4_config.get_dns(0));
                if(_num_dns > 1) {
                    this.entry_dns2.text = Helper.networkIntToIp4Dotted(this.setting_ip4_config.get_dns(1));
                }
                for(int kkk = 2; kkk < _num_dns; kkk++) {
                    DnsUi dns_ui = new DnsUi(dns_list.length);
                    dns_ui.handler_change = dns_ui.uiChanged.connect(extraDnsChangedCB);
                    dns_ui.handler_remove = dns_ui.removeClicked.connect(extraDnsRemovedCB);
                    dns_ui.text = Helper.networkIntToIp4Dotted(this.setting_ip4_config.get_dns(kkk));
                    this.dns_list.add(dns_ui);
                    this.box_dns.add(dns_ui);
                }
            }
        }
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
    }
}