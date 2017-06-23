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

        private ulong device_added_handler = 0;
        private ulong device_removed_handler = 0;
        
        public bool wifiEnabled {
            get {return this.client.wireless_get_enabled();}
            set {this.client.wireless_set_enabled(value);}
        }
        public uint num_of_devices {
            get {return wifi_devices.length;}
        }

        public ulong devices_changed_handler;
        
        public Manager() {
            this.client = new NM.Client();
            this.device_added_handler = this.client.device_added.connect((_client, _device) => {
                if(_device.get_device_type() == NM.DeviceType.WIFI) {
                    devicesChanged();
                }
            });
            this.device_removed_handler = this.client.device_removed.connect((_client, _device) => {
                if(_device.get_device_type() == NM.DeviceType.WIFI) {
                    devicesChanged();
                }
            });
            this.remote_connections = new GenericArray<RemoteConnection>();
            this.devices_changed_handler = 0;
        }

        public signal void networksRead();
        public signal void connectionsChanged();
        public signal void devicesChanged();

        public bool initDevices() {
            bool _foundWifi = false;
            this.wifi_devices = new GenericArray<WifiDevice>();
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

        public void readSavedNetworks(NM.RemoteSettings _remote_settings) {
            this.remote_connections = new GenericArray<NM.RemoteConnection>();
            SList<weak NM.RemoteConnection> _remote_connections = _remote_settings.list_connections();
            for(int iii = 0; iii < _remote_connections.length(); iii++) {
                RemoteConnection _remote_connection = _remote_connections.nth_data(iii);
                if(_remote_connection.is_type("802-11-wireless")) {
                    _remote_connection.removed.connect((_src) => {
                        //  stdout.printf("\n\nmanager: connections removed\n\n");
                        this.remote_connections.remove_fast(_src);
                        this.connectionsChanged();
                    });
                    this.remote_connections.add(_remote_connection);
                }
            }
            _remote_connections = null;
            networksRead();
        }

        public void destroy() {
            //TODO
        }

        //  public void readSavedNetworks(NM.RemoteSettings _remote_settings) {

        //      NM.RemoteSettings __remote_settings = _remote_settings;
        //      if(__remote_settings == null) {
        //          __remote_settings = new NM.RemoteSettings(null);
        //      }
        //      __remote_settings.connections_read.connect(this.readSavedNetworksCB);
        //  }

        public GenericArray<RemoteConnection> getRemoteConnections() {
            return this.remote_connections;
        }

        public GenericArray<WifiDevice> getDevices() {
            return wifi_devices;
        }
    }
}