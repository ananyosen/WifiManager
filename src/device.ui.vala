
using Gtk;

[GtkTemplate (ui = "/home/dexter/projects/vala/four/device.ui")]
class DeviceUi : Gtk.Box { 

    [GtkChild]
    private Label label_manufacturer;
    [GtkChild]
    private Label label_product;
    //  [GtkChild]
    //  private Button button_info;

    private uint max_length = 25;

    public int index = -1;

    //  public signal void clickedOnDevice();

    private WifiUtility.WifiDevice device;
    public DeviceUi(WifiUtility.WifiDevice _device) {
        this.device = _device;
        this.label_manufacturer.label = Helper.reduceString(_device.getVendor(), this.max_length);
        this.label_product.label = Helper.reduceString(_device.getProduct(), this.max_length);
        //  this.button_press_event.connect((evt) => {
        //      clickedOnDevice();
        //      return false;
        //  });
        //  button_info.clicked.connect(() => {

        //  });

    }
}