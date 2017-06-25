

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
    public signal void closeAndConnect();

    private NM.AccessPoint access_point = null;
    private NM.Connection nm_connection = null;
    private GenericArray<DnsUi> dns_list = null;
    private NM.SettingIP4Config setting_ip4_config= null;
    private NM.IP4Address default_ip4 = null;
    private bool was_dhcp4;
    private bool is_dhcp4;
    private bool is_ip4_valid;
    
    private void handle_toggle() {
        bool _enabled = this.radio_static.get_active();
        this.is_dhcp4 = !_enabled;
        this.box_ip.set_sensitive(_enabled);
        this.box_dns.set_sensitive(_enabled);
        this.button_save_connect.set_sensitive((isIP4ConfigValid() && _enabled) || !_enabled);
    }

    private bool isIP4ConfigValid() {
        //  if(_editable == null || (_editable != null && this.ipChanged((Gtk.Entry)_editable)))
        //  {
            bool valid = true;
            valid =  this.ipChanged(this.entry_ip) && valid;
            valid =  this.ipChanged(this.entry_gateway) && valid;
            valid =  this.ipChanged(this.entry_subnet) && valid;
            valid =  this.ipChanged(this.entry_dns1) && valid;
            valid =  this.ipChanged(this.entry_dns2) && valid;
            if(this.dns_list != null) {
                for(int lll = 0; lll < dns_list.length; lll++) {
                    valid =  extraDnsChangedCB(dns_list[lll]) && valid;
                }
            }
            return valid;
        //  }
        //  else {
        //      return false;
        //  }
        return true;
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

    private void id10tDNS(DnsUi _ed) {
        this.extraDnsChangedCB(_ed);
        this.button_save_connect.set_sensitive(this.isIP4ConfigValid());
    }

    private void id10tIP(Gtk.Editable _ed) {
        this.button_save_connect.set_sensitive(this.isIP4ConfigValid());
    }

    private bool ipChanged(Gtk.Entry _entry) {
        //  Gtk.Entry entry = (Gtk.Entry) _editable;
        string text = _entry.get_text();
        bool valid = this.validateIP4(text);
        _entry.name = (valid)?"good_ip":"bad_ip";
        return valid;
    }

    private bool extraDnsChangedCB(DnsUi ui) {
        string text = ui.text;
        bool valid = validateIP4(text);
        ui.name = (valid)?"good_ip":"bad_ip";
        return valid;
    }

    private void extraDnsRemovedCB(DnsUi ui) {
        ui.disconnect(ui.handler_change);
        ui.disconnect(ui.handler_remove);
        this.dns_list.remove(ui);
        this.box_dns.remove(ui);
        this.button_save_connect.set_sensitive(isIP4ConfigValid());
    }

    public ConfigIP(NM.AccessPoint _ap, NM.Connection _connection, bool _was_dhcp4) {

        this.access_point = _ap;
        this.nm_connection = _connection;
        this.radio_static.join_group(radio_dhcp);
        this.radio_dhcp.toggled.connect(handle_toggle);
        this.radio_static.toggled.connect(handle_toggle);
        this.was_dhcp4 = _was_dhcp4;
        this.is_dhcp4 = this.was_dhcp4;
        this.dns_list = new GenericArray<DnsUi>();        
        if(this.was_dhcp4) {
            this.radio_dhcp.active = true;
        }
        else {
            this.radio_static.active = true;
        }
        this.box_ip.set_sensitive(!this.was_dhcp4); //fix TODO: DONE
        this.box_dns.set_sensitive(!this.was_dhcp4); //fix TODO: DONE
        if(!this.was_dhcp4) {
            this.setting_ip4_config = this.nm_connection.get_setting_ip4_config();
            if(this.setting_ip4_config.get_num_addresses() > 0) {
                //Doing something that the doc explicitly mentions shouldn't be done, oh well
                GenericArray<Array<string>> _data_all =  Helper.parseSettingString(this.setting_ip4_config.to_string());
                Array<string> _data = _data_all[0];
                uint32 _netmask_prefix = int.parse(_data.data[1]);
                uint32 _netmask = NM.Utils.ip4_prefix_to_netmask(_netmask_prefix);
                //  this.label_ip_type.label = "Static";
                this.entry_ip.text = _data.data[0];
                this.entry_gateway.text = _data.data[2];
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
                    dns_ui.handler_change = dns_ui.uiChanged.connect(id10tDNS);
                    dns_ui.handler_remove = dns_ui.removeClicked.connect(extraDnsRemovedCB);
                    dns_ui.text = Helper.networkIntToIp4Dotted(this.setting_ip4_config.get_dns(kkk));
                    this.dns_list.add(dns_ui);
                    this.box_dns.add(dns_ui);
                }
            }
        }
        this.button_cancel.clicked.connect(() => {
            this.closeUnsaved();
        });
        this.button_add_dns.clicked.connect(() => {
            DnsUi dns_ui = new DnsUi(dns_list.length);
            dns_ui.handler_change = dns_ui.uiChanged.connect(id10tDNS);
            dns_ui.handler_remove = dns_ui.removeClicked.connect(extraDnsRemovedCB);
            this.dns_list.add(dns_ui);
            this.box_dns.add(dns_ui);
            this.button_save_connect.set_sensitive(isIP4ConfigValid());
        });
        this.button_save_connect.clicked.connect(() => {
            uint32 _ip = Helper.ip4DottedToNetworkInt(entry_ip.get_text());
            uint32 _subnet = Helper.ip4DottedToNetworkInt(entry_subnet.get_text());
            uint32 _gateway = Helper.ip4DottedToNetworkInt(entry_gateway.get_text());
            uint32 _dns1 = Helper.ip4DottedToNetworkInt(entry_dns1.get_text());
            uint32 _dns2 = Helper.ip4DottedToNetworkInt(entry_dns2.get_text());
            if(this.setting_ip4_config == null) {
                this.setting_ip4_config = new NM.SettingIP4Config();
            }
            else {
                this.setting_ip4_config.clear_addresses();
                this.setting_ip4_config.clear_dns();
            }
            this.setting_ip4_config.method = (this.is_dhcp4)? "auto":"manual";
            if(!this.is_dhcp4) {
                NM.IP4Address _addr = new NM.IP4Address();
                _addr.set_address(_ip);
                _addr.set_prefix(NM.Utils.ip4_netmask_to_prefix(_subnet));
                _addr.set_gateway(_gateway);
                this.setting_ip4_config.add_address(_addr);
                this.setting_ip4_config.add_dns(_dns1);
                this.setting_ip4_config.add_dns(_dns2);
                for(int kkk = 0; (this.dns_list != null) && kkk < dns_list.length; kkk++) {
                    this.setting_ip4_config.add_dns(Helper.ip4DottedToNetworkInt(dns_list[kkk].text));
                }
            }
            this.nm_connection.add_setting(this.setting_ip4_config);
            this.closeAndConnect();
        });
        this.entry_ip.changed.connect(id10tIP);
        this.entry_subnet.changed.connect(id10tIP);
        this.entry_gateway.changed.connect(id10tIP);
        this.entry_dns1.changed.connect(id10tIP);
        this.entry_dns2.changed.connect(id10tIP);
        this.is_ip4_valid = isIP4ConfigValid();
        this.button_save_connect.set_sensitive(this.is_ip4_valid);
        
        //  this.button_cancel.name = "button1";
    }
}