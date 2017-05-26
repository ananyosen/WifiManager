using Gtk;

[GtkTemplate (ui = "/home/dexter/projects/vala/four/dns.ui")]
class DnsUi : Box { 
    [GtkChild]
    private Entry entry_dns;
    [GtkChild]
    private Button button_remove_this;
    
    public int index = -1;
    public ulong handler_change = 1;
    public ulong handler_remove = 2;
    public string name {
        get {return this.entry_dns.name;}
        set {this.entry_dns.name = value;}
    }
    public signal void uiChanged();
    public signal void removeClicked();
    
    public DnsUi(int _index) {
        this.index = _index;
        this.entry_dns.changed.connect((_src) => {
            this.uiChanged();
        });
        this.button_remove_this.clicked.connect(() => {
            removeClicked();
        });
        this.button_remove_this.name = "remove";
    }


    public string get_text() {
        return this.entry_dns.get_text();
    }
}