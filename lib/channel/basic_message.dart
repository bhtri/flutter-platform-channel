import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoBasicMessage extends StatefulWidget {
  @override
  _DemoBasicMessageState createState() => _DemoBasicMessageState();
}

class _DemoBasicMessageState extends State<DemoBasicMessage> {
  // Communication between dart & native code is through BasicMessageChannel
  static const BasicMessageChannel<String> stringPlatform =
      BasicMessageChannel(_stringCodecChannel, StringCodec());
  static const BasicMessageChannel<dynamic> jsonPlatform =
      BasicMessageChannel(_jSONMessageCodecChannel, JSONMessageCodec());
  static const BasicMessageChannel<ByteData> binaryPlatform =
      BasicMessageChannel(_binaryCodecChannel, BinaryCodec());
  static const BasicMessageChannel<dynamic> standardPlatform =
      BasicMessageChannel(_standardMessageCodecChannel, StandardMessageCodec());

  static const String _stringCodecChannel = 'StringCodec';
  static const String _jSONMessageCodecChannel = 'JSONMessageCodec';
  static const String _binaryCodecChannel = 'BinaryCodec';
  static const String _standardMessageCodecChannel = 'StandardMessageCodec';

  String _message1 = 'empty';
  String _message2 = 'empty';
  String _message3 = 'empty';
  String _message4 = 'empty';

  @override
  void initState() {
    super.initState();

    stringPlatform.setMessageHandler(_handleStringPlatformBack);
    jsonPlatform.setMessageHandler(_handleJsonPlatformBack);
  }

  Future<String> _handleStringPlatformBack(String response) async {
    setState(() {
      _message1 = response;
    });
    return '';
  }

  Future<dynamic> _handleJsonPlatformBack(dynamic response) async {
    setState(() {
      _message2 = response.toString(); // response['']
    });
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo BasicMessage'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_message1),
              ElevatedButton.icon(
                onPressed: () {
                  //call Native StringCodec
                  print('callNativeStringCodec');
                  stringPlatform.send('Edison');
                },
                icon: Icon(Icons.add),
                label: Text('StringCodec'),
              ),
              SizedBox(height: 20),
              Text(_message2),
              ElevatedButton.icon(
                onPressed: () {
                  //call Native JSONMessageCodec
                  print('callNativeJSONMessageCodec');
                  jsonPlatform.send('Robert Lewandowski');
                },
                icon: Icon(Icons.add),
                label: Text('JSONMessageCodec'),
              ),
              SizedBox(height: 20),
              Text(_message3),
              ElevatedButton.icon(
                onPressed: () async {
                  //call Native BinaryCodec
                  print('callNativeBinaryCodec');
                  final WriteBuffer buffer = WriteBuffer()..putFloat64(1.12345);
                  final ByteData message = buffer.done();

                  ByteData result = await binaryPlatform.send(message);
                  setState(() {
                    _message3 = 'Received ${result.getFloat64(0)}';
                  });
                },
                icon: Icon(Icons.add),
                label: Text('BinaryCodec'),
              ),
              SizedBox(height: 20),
              Text(_message4),
              ElevatedButton.icon(
                onPressed: () async {
                  //call Native StandardMessageCodec
                  print('callNativeStandardMessageCodec');
                  var list = await standardPlatform.send([1, 2, 3, 4, 5]);
                  setState(() {
                    _message4 = list.toString();
                  });
                },
                icon: Icon(Icons.add),
                label: Text('StandardMessageCodec'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
