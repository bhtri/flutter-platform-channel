import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoMethodChannel extends StatefulWidget {
  @override
  _DemoMethodChannelState createState() => _DemoMethodChannelState();
}

class _DemoMethodChannelState extends State<DemoMethodChannel> {
  // Communication between dart & native code is through MethodChannel
  static const defaultPlatform = MethodChannel('com.flutter/method1');
  static const platform =
      MethodChannel('com.flutter/method2', JSONMethodCodec());

  String _deviceInfo1 = '???';
  String _deviceInfo2 = '???';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo MethodChannel'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_deviceInfo1),
              ElevatedButton.icon(
                onPressed: () {
                  _standardMethodCodec('model');
                },
                icon: Icon(Icons.add),
                label: Text('StandardMethodCodec'),
              ),
              SizedBox(height: 20),
              Text(_deviceInfo2),
              ElevatedButton.icon(
                onPressed: () {
                  _jsonMethodCodec('model');
                },
                icon: Icon(Icons.add),
                label: Text('JSONMethodCodec'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _standardMethodCodec(String model) async {
    try {
      String result =
          await defaultPlatform.invokeMethod('getDeviceInfoString', {
        'type': 'MODEL',
      });

      if (result != null) {
        _deviceInfo1 = result;
      } else {
        _deviceInfo1 = 'can not get device info';
      }
    } on PlatformException catch (e) {
      _deviceInfo1 = e.message;
    }

    setState(() {});
  }

  _jsonMethodCodec(String model) async {
    try {
      Map<String, dynamic> result =
          await platform.invokeMethod('getDeviceInfo', {
        'type': 'MODEL',
      });

      if (result != null) {
        _deviceInfo2 = result.toString(); //result['model']
      } else {
        _deviceInfo2 = 'can not get device info';
      }
    } on PlatformException catch (e) {
      _deviceInfo2 = e.message;
    }

    setState(() {});
  }
}
