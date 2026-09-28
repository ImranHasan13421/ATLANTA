import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'activity_service.dart';

enum DeviceType { light, thermostat, lock, audio, mainframe, camera, sensor }

class AtlantaDevice {
  final String id;
  String name;
  DeviceType type;
  String room;
  bool isOn;
  double value; // brightness (0-100), temp (60-85), volume (0-100)
  int batteryLevel;
  String statusText;

  AtlantaDevice({
    String? id,
    required this.name,
    required this.type,
    required this.room,
    this.isOn = false,
    this.value = 50,
    this.batteryLevel = 98,
    this.statusText = 'Online',
  }) : id = id ?? const Uuid().v4();
}

class DeviceService extends ChangeNotifier {
  static final DeviceService instance = DeviceService._internal();

  DeviceService._internal() {
    _seedDefaultDevices();
  }

  final List<AtlantaDevice> _devices = [];

  List<AtlantaDevice> get devices => List.unmodifiable(_devices);
  int get onlineCount => _devices.where((d) => d.statusText == 'Online').length;
  int get activeCount => _devices.where((d) => d.isOn).length;

  void _seedDefaultDevices() {
    _devices.addAll([
      AtlantaDevice(
        name: 'Living Room Lights',
        type: DeviceType.light,
        room: 'Living Room',
        isOn: true,
        value: 80,
        statusText: 'Online',
      ),
      AtlantaDevice(
        name: 'Studio Mainframe Core',
        type: DeviceType.mainframe,
        room: 'Lab / Studio',
        isOn: true,
        value: 99.4,
        statusText: 'Online',
      ),
      AtlantaDevice(
        name: 'HVAC Climate Control',
        type: DeviceType.thermostat,
        room: 'Central',
        isOn: true,
        value: 71,
        statusText: 'Online',
      ),
      AtlantaDevice(
        name: 'Perimeter Smart Lock',
        type: DeviceType.lock,
        room: 'Front Gate',
        isOn: true, // locked
        value: 100,
        statusText: 'Online',
      ),
      AtlantaDevice(
        name: 'Surround Acoustic Array',
        type: DeviceType.audio,
        room: 'Lab / Studio',
        isOn: false,
        value: 40,
        statusText: 'Standby',
      ),
      AtlantaDevice(
        name: 'External Optical Sensor',
        type: DeviceType.camera,
        room: 'Perimeter',
        isOn: true,
        value: 100,
        statusText: 'Online',
      ),
    ]);
  }

  bool toggleDevice(String id) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index].isOn = !_devices[index].isOn;
      ActivityService.instance.log(
        title: 'Device state toggled',
        description: '${_devices[index].name}: ${_devices[index].isOn ? "ACTIVATED" : "DEACTIVATED"}',
        type: ActivityType.device,
      );
      notifyListeners();
      return _devices[index].isOn;
    }
    return false;
  }

  void setDeviceValue(String id, double val) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index].value = val;
      notifyListeners();
    }
  }

  AtlantaDevice? findDeviceByName(String query) {
    final q = query.toLowerCase();
    for (final d in _devices) {
      if (d.name.toLowerCase().contains(q) || d.room.toLowerCase().contains(q)) {
        return d;
      }
    }
    return null;
  }
}
