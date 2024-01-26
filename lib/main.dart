import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plugin/charger_status.dart';


// void main() {
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Hello World!'),
//         ),
//       ),
//     );
//   }
// }



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ChargerStatus.instance.registerHeadlessDispatcher(callbackDispatcher);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _batteryLevel = 'Unknown';
  String _chargerStatus = "Unknown";
  final _chargerStatusPlugin = ChargerStatus.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String batteryLevel;
    String chargerStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      batteryLevel = await _chargerStatusPlugin.getBatteryLevel() ?? 'Unknown platform version';
      chargerStatus = await _chargerStatusPlugin.getChargerStatus() ?? "Unable to get charger status";
    } on PlatformException {
      batteryLevel = 'Failed to get platform version.';
      chargerStatus = "Failed to get charger status";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _batteryLevel = batteryLevel;
      _chargerStatus = chargerStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Running on xd: $_batteryLevel\n'), Text(_chargerStatus)],
          ),
        ),
      ),
    );
  }
}


@pragma('vm:entry-point')
void callbackDispatcher() async {
  print("callbacksDispatcher called");
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  ChargerStatus.instance.listenToEvents().listen((event) {
    print("onNewEvent: $event");
  });

  ChargerStatus.instance.startPowerChangesListener();
  // await _listenToGeoLocations();
}
