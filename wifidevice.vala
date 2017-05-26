/** 
* core WiFi Deice APIs
* dependencies ['libnm-glib', 'libnm-util']
* members [scan, disconnect, getMAC, getProduct, getScannedAPs, getRawDevice]
* signals [scanStarted, scanDone, wifiDisconnected]
**/

using NM;

/**
 *A wrapper around the networkmanager wifi device api to make handling easier 
**/
namespace WifiUtility { 
    
    public class WifiDevice : GLib.Object { 
        private NM.DeviceWifi device = null;
        private string product;
        private string MAC;
        private bool scanning = false;
        private GenericArray<NM.AccessPoint> access_points = null;
        public int index = -1;
        public WifiDevice(NM.DeviceWifi _device) {
            this.device = _device;
            this.product = this.device.get_product();
            this.MAC = this.device.get_hw_address();
        }

        public signal void scanDone();

        public signal void scanStarted();

        private void onWifiScan(DeviceWifi _device, GLib.Error err) {
            this.scanning = false;
            access_points = this.device.get_access_points();
            //TODO: log error
            scanDone();
        }

        public void scan() {
            scanning = true;
            try {
                scanStarted();
                this.device.request_scan_simple(onWifiScan);
            }
            catch(Error err) {
                //TODO log the error
                scanning = false;
                scanDone();
            }
        }

        public signal void wifiDisconnected();

        private void onWifiDisconnect(Device _device, GLib.Error err) {
            //disconnected
            wifiDisconnected();
        }

        public bool disconnect(bool autoconnect = false) {
            try {
                NM.Device _device = (Device) this.device;
                _device.disconnect(onWifiDisconnect);
                _device.set_autoconnect(autoconnect);
                return true;			
            } 
            catch (Error err) {
                //whaaaat? log
                //TODO: log//DONE
                return false;
            }

        }

        public string getProduct() {
            return this.product;
        }

        public string getMAC() {
            return this.MAC;
        }

        public NM.DeviceWifi getRawDevice() {
            return this.device;
        }

        public void getScannedAPs(ref GenericArray<AccessPoint> _access_points) {
            if(access_points != null) {
                _access_points = this.access_points;
            }
        }
    }
}