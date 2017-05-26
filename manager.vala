/** 
 * management functions
 * dependencies ['libnm-glib', 'libnm-util'] 
 * members [initDevices, readSavedNetworks]
 **/

//IP4Address()
//SettingIP4Config.add_address(IP4Address)
 //Connection.add_setting

 using NM;

namespace WifiUtility { 

    public class Manager : GLib.Object { 
        private NM.Client client = null;
        private GenericArray<WifiDevice> wifi_devices = null;
        private GenericArray<RemoteConnection> remote_connections = null;
        public bool wifiEnabled {
            get {return this.client.wireless_get_enabled();}
            set {this.client.wireless_set_enabled(value);}
        }
        public uint num_of_devices {
            get {return wifi_devices.length;}
        }
        
        public Manager() {
            this.client = new NM.Client();
            this.wifi_devices = new GenericArray<WifiDevice>();
            this.remote_connections = new GenericArray<RemoteConnection>();
        }

        public signal void networksRead();

        public bool initDevices() {
            bool _foundWifi = false;
            GenericArray<NM.Device> devices = this.client.get_devices();
            for (int iii = 0; iii < devices.length; iii++) {
                if(devices[iii].get_device_type() == NM.DeviceType.WIFI) {
                    WifiDevice _dev = new WifiDevice((DeviceWifi) devices[iii]);
                    _dev.index = this.wifi_devices.length;
                    this.wifi_devices.add(_dev);
                    _foundWifi = true;
                }
            }
            return _foundWifi;
        }

        private void readSavedNetworksCB(NM.RemoteSettings _remote_settings) {
            SList<RemoteConnection> _remote_connections = _remote_settings.list_connections();
            for(int iii = 0; iii < _remote_connections.length(); iii++) {
                RemoteConnection _remote_connection = _remote_connections.nth_data(iii);
                if(_remote_connection.is_type("802-11-wireless")) {
                    this.remote_connections.add(_remote_connection);
                }
            }
        }

        public void readSavedNetworks(ref NM.RemoteSettings _remote_settings) {
            if(_remote_settings == null) {
                _remote_settings = new NM.RemoteSettings(null);
            }
            _remote_settings.connections_read.connect(this.readSavedNetworksCB);
        }

        public GenericArray<WifiDevice> getDevices() {
            return wifi_devices;
        }
    }
}