import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<BluetoothDevice>(
              value: selectedDevice,
              hint: const Text('Select thermal printer'),
              onChanged: (device) {
                setState(() {
                  selectedDevice = device;
                });
              },
              items: devices
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name!),
                      ))
                  .toList(),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printer.connect(selectedDevice!);
                },
                child: const Text('Connect')),
            ElevatedButton(
                onPressed: () {
                  printer.disconnect();
                },
                child: const Text('Disconnect')),
            ElevatedButton(
              onPressed: () async {
                if ((await printer.isConnected)!) {
                  var response = await http.get(Uri.parse(
                      "https://braincore.id/static/images/braincore.png"));
                  Uint8List bytesNetwork = response.bodyBytes;
                  Uint8List imageBytesFromNetwork = bytesNetwork.buffer
                      .asUint8List(bytesNetwork.offsetInBytes,
                          bytesNetwork.lengthInBytes);
                  printer.printNewLine();
                  printer.printCustom('Thermal Printer Demo', 0, 1);
                  printer.printQRcode('https://megalogic.id', 200, 200, 1);
                  printer.printCustom('by megalogic.id', 0, 1);
                  printer.printNewLine();
                  printer.printNewLine();
                  printer.printImageBytes(imageBytesFromNetwork);
                  printer.printNewLine();
                  printer.printNewLine();
                }
              },
              child: const Text('Print'),
            )
          ],
        ),
      ),
    );
  }
}
