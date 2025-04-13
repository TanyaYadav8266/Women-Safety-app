import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BluetoothMeshService {
  static final BluetoothMeshService _instance = BluetoothMeshService._internal();
  factory BluetoothMeshService() => _instance;
  BluetoothMeshService._internal();

  static const String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String characteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  
  late BluetoothDevice? _connectedDevice;
  late BluetoothCharacteristic? _messageCharacteristic;
  late Database _database;

  Future<void> initialize() async {
    await _initDatabase();
    await _setupBluetooth();
  }

  Future<void> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'ble_messages.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            timestamp INTEGER,
            is_delivered INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> _setupBluetooth() async {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _startScanning();
      }
    });

    if (await FlutterBluePlus.isAvailable == false) {
      print("Bluetooth not supported");
      return;
    }

    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _startScanning() async {
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.advertisementData.serviceUuids.contains(serviceUuid)) {
          await _connectToDevice(result.device);
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withServices: [Guid(serviceUuid)],
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    await device.connect(autoConnect: false);
    
    final services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid == Guid(serviceUuid)) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid == Guid(characteristicUuid)) {
            _messageCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((data) {
              _handleIncomingMessage(String.fromCharCodes(data));
            });
            break;
          }
        }
      }
    }
  }

  Future<void> sendEmergencyMessage(String message) async {
    // Store message locally first
    await _database.insert('messages', {
      'content': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Try to send via Bluetooth if connected
    if (_messageCharacteristic != null) {
      try {
        await _messageCharacteristic!.write(message.codeUnits);
        await _database.rawUpdate(
          'UPDATE messages SET is_delivered = 1 WHERE content = ?',
          [message],
        );
      } catch (e) {
        print("Failed to send via Bluetooth: $e");
      }
    }
  }

  void _handleIncomingMessage(String message) async {
    await _database.insert('messages', {
      'content': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'is_delivered': 1, // Mark as delivered since we received it
    });
    
    // Handle the emergency message (show notification, etc.)
    _processEmergencyMessage(message);
  }

  void _processEmergencyMessage(String message) {
    // Implement your emergency message handling here
    print("Received emergency message: $message");
  }

  Future<List<Map<String, dynamic>>> getUndeliveredMessages() async {
    return await _database.query(
      'messages',
      where: 'is_delivered = 0',
    );
  }

  Future<void> retryUndeliveredMessages() async {
    final messages = await getUndeliveredMessages();
    for (var message in messages) {
      await sendEmergencyMessage(message['content'] as String);
    }
  }
}