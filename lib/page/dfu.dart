import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class Dfu extends StatefulWidget {

  @override
  _DfuState createState() => _DfuState();
}

class _DfuState extends State<Dfu> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  List<ScanResult> scanResults = <ScanResult>[];
  bool dfuRunning = false;
  int? dfuRunningInx;
  String pathString = "";

  Future<void> doDfu(String deviceId, String file) async {
    stopScan();
    dfuRunning = true;
    try {
      final s = await NordicDfu().startDfu(
        deviceId,
        file,
        // onErrorHandle: (string) {
        //   debugPrint('deviceAddress: $string');
        // },
        onProgressChanged: (
            deviceAddress,
            percent,
            speed,
            avgSpeed,
            currentPart,
            partsTotal,
            ) {
          debugPrint('deviceAddress: $deviceAddress, percent: $percent');
        },
      );
      debugPrint(s);
      dfuRunning = false;
    } catch (e) {
      dfuRunning = false;
      debugPrint(e.toString());
    }
  }

  Future<void> startScan() async {
    // You can request multiple permissions at once.

    if (!Platform.isMacOS) {
      await [
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.bluetooth,
      ].request();
    }

    scanSubscription?.cancel();
    setState(() {
      scanResults.clear();
      scanSubscription = flutterBlue.scan().listen(
            (scanResult) {
          if (scanResults.firstWhereOrNull(
                (ele) => ele.device.id == scanResult.device.id,
          ) !=
              null) {
            return;
          }
          setState(() {
            /// add result to results if not added
            scanResults.add(scanResult);
          });
        },
      );
    });
  }

  void stopScan() {
    flutterBlue.stopScan();
    scanSubscription?.cancel();
    scanSubscription = null;
    setState(() => scanSubscription = null);
  }

  @override
  Widget build(BuildContext context) {
    final isScanning = scanSubscription != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: <Widget>[
          if (isScanning)
            IconButton(
              icon: const Icon(Icons.pause_circle_filled),
              onPressed: dfuRunning ? null : stopScan,
            )
          else
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: dfuRunning ? null : startScan,
            )
        ],
      ),
      body: buildForm(context),
    );
  }

  Widget buildForm(BuildContext context) {
    return Scrollbar(
        child:Column(
          children: <Widget>[
            Text("固件包:" + pathString, style: TextStyle(color: Colors.grey, fontSize: 20),),
            ElevatedButton(
              style: TextButton.styleFrom(
                // primary: Theme.of(context).primaryColor,
                // primary: Colors.redAccent,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(10.0)),
              child: Text("打开",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['zip'],    //筛选文件类型
                );
                //这就用完了，下面就赋值了
                if (result != null) {
                  PlatformFile file = result.files.first;
                  pathString = file.path!;                  //取数据，有name，path，size等等，这就取个文件地址
                  setState(() {                     //刷新界面显示数据,否则下面的text不更新

                  });
                } else {
                  // User canceled the picker
                }
              },
            ),
            Expanded(
              child:ListView.separated(
                padding: const EdgeInsets.all(8),
                itemBuilder: _deviceItemBuilder,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                itemCount: scanResults.length,
              ),
            ),
          ]
        ),
    );
  }

    Widget _deviceItemBuilder(BuildContext context, int index) {
    final result = scanResults[index];
    return DeviceItem(
      isRunningItem: dfuRunningInx == index,
      scanResult: result,
      onPress: dfuRunning
          ? () async {
        await NordicDfu().abortDfu();
        setState(() {
          dfuRunningInx = null;
        });
      }
          : () async {
        setState(() {
          dfuRunningInx = index;
        });
        await doDfu(result.device.id.id, pathString);
        setState(() {
          dfuRunningInx = null;
        });
      },
    );
  }
}

// class ProgressListenerListener extends DfuProgressListenerAdapter {
//   @override
//   void onProgressChanged(
//     String? deviceAddress,
//     int? percent,
//     double? speed,
//     double? avgSpeed,
//     int? currentPart,
//     int? partsTotal,
//   ) {
//     super.onProgressChanged(
//       deviceAddress,
//       percent,
//       speed,
//       avgSpeed,
//       currentPart,
//       partsTotal,
//     );
//     debugPrint('deviceAddress: $deviceAddress, percent: $percent');
//   }
// }

class DeviceItem extends StatelessWidget {
  final ScanResult scanResult;

  final VoidCallback? onPress;

  final bool? isRunningItem;

  const DeviceItem({
    required this.scanResult,
    this.onPress,
    this.isRunningItem,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var name = 'Unknown';
    if (scanResult.device.name.isNotEmpty) {
      name = scanResult.device.name;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.bluetooth),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name),
                  Text(scanResult.device.id.id),
                  Text('RSSI: ${scanResult.rssi}'),
                ],
              ),
            ),
            TextButton(
              onPressed: onPress,
              child: isRunningItem!
                  ? const Text('Abort Dfu')
                  : const Text('Start Dfu'),
            )
          ],
        ),
      ),
    );
  }
}