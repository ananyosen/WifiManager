
using Gtk;

[GtkTemplate (ui="/home/dexter/projects/vala/four/main.ui")]
class MainUi : Gtk.Box { 
    [GtkChild]
    private Switch switch_wifi;
    [GtkChild]
    private Button button_scan;
    [GtkChild]
    private ScrolledWindow scroll_ap;
    [GtkChild]
    private ScrolledWindow scroll_dev;

    private Viewport vp_ap = null;
    private Viewport vp_dev = null;
    private Box box_dev = null;
    private Box box_ap = null;
    public MainUi() {
        this.vp_dev = new Viewport(null, null);
        this.vp_ap = new Viewport(null, null);
        this.box_dev = new Box(Gtk.Orientation.VERTICAL, 0);
        this.box_ap = new Box(Gtk.Orientation.VERTICAL, 0);
        this.vp_dev.add(this.box_dev);
        this.scroll_dev.add(this.vp_dev);
        this.vp_ap.add(this.box_ap);
        this.scroll_ap.add(this.vp_ap);
    
    }
}