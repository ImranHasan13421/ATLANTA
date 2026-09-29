import 'package:flutter_test/flutter_test.dart';
import 'package:atlanta/core/services/ota_update_service.dart';
import 'package:atlanta/core/services/weather_service.dart';
import 'package:atlanta/core/services/native_device_service.dart';
import 'package:atlanta/features/devices/devices_screen.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OTA Update System Tests', () {
    test('Version comparison correctly identifies newer versions', () {
      final ota = OtaUpdateService.instance;

      expect(ota.isNewerVersion('v1.2.1', 'v1.2.0'), true);
      expect(ota.isNewerVersion('v2.0.0', 'v1.9.9'), true);
      expect(ota.isNewerVersion('1.3.0', '1.2.0'), true);
      expect(ota.isNewerVersion('v1.2.0', 'v1.2.0'), false);
      expect(ota.isNewerVersion('v1.1.9', 'v1.2.0'), false);
      expect(ota.isNewerVersion('v1.0.0', 'v2.0.0'), false);
    });

    test('OTA update service singleton state inspection', () {
      final ota = OtaUpdateService.instance;
      expect(ota.currentVersion, '1.2.0');
      expect(ota.isDownloading, false);
      expect(ota.downloadProgress, 0.0);
    });
  });

  group('Weather Service Tests', () {
    test('Default weather model properties are valid', () {
      final weather = WeatherService.instance.currentWeather;
      expect(weather.cityName.isNotEmpty, true);
      expect(weather.temperature, isA<double>());
      expect(weather.formattedTemp.endsWith('°C'), true);
      expect(weather.condition.isNotEmpty, true);
      expect(weather.icon, isA<IconData>());
    });

    test('WeatherData fromJson parsing test', () {
      final data = WeatherData.fromJson({
        'cityName': 'Tokyo',
        'country': 'JP',
        'temperature': 22.4,
        'feelsLike': 23.0,
        'humidity': 65,
        'windSpeed': 12.0,
        'condition': 'Partly Cloudy',
        'iconCode': Icons.cloud_queue_rounded.codePoint,
      });

      expect(data.cityName, 'Tokyo');
      expect(data.country, 'JP');
      expect(data.temperature, 22.4);
      expect(data.formattedTemp, '22°C');
      expect(data.condition, 'Partly Cloudy');
      expect(data.icon.codePoint, Icons.cloud_queue_rounded.codePoint);
    });
  });

  group('Native Hardware Service & Telemetry Tests', () {
    test('StorageMetrics formatting calculates MB and GB properly', () {
      const storage = StorageMetrics(
        totalBytes: 128 * 1024 * 1024 * 1024, // 128 GB
        usedBytes: 64 * 1024 * 1024 * 1024,  // 64 GB
        freeBytes: 64 * 1024 * 1024 * 1024,  // 64 GB
        percentUsed: 50.0,
      );

      expect(storage.percentUsed, 50.0);
      expect(storage.formattedTotal, '128.0 GB');
      expect(storage.formattedUsed, '64.0 GB');
      expect(storage.formattedFree, '64.0 GB');
    });

    test('NetworkMetrics initializes correctly', () {
      const net = NetworkMetrics(
        isConnected: true,
        type: 'wifi',
        networkName: 'CyberNet_Mesh',
        signalStrengthPercent: 88,
      );

      expect(net.isConnected, true);
      expect(net.type, 'wifi');
      expect(net.networkName, 'CyberNet_Mesh');
      expect(net.signalStrengthPercent, 88);
    });
  });

  group('LauncherAppSlot Tests for Apps Menu', () {
    test('Serialization and deserialization of quick launch slots', () {
      final slot = LauncherAppSlot(
        index: 0,
        name: 'Browser',
        query: 'open browser',
        icon: Icons.language_rounded,
        color: Colors.lightBlueAccent,
      );

      final json = slot.toJson();
      expect(json['index'], 0);
      expect(json['name'], 'Browser');
      expect(json['query'], 'open browser');

      final reconstructed = LauncherAppSlot.fromJson(json);
      expect(reconstructed.index, slot.index);
      expect(reconstructed.name, slot.name);
      expect(reconstructed.query, slot.query);
      expect(reconstructed.icon.codePoint, slot.icon.codePoint);
      expect(reconstructed.color.toARGB32(), slot.color.toARGB32());
    });
  });
}
