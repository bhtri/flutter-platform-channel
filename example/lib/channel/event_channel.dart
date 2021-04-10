import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoEventChannel extends StatefulWidget {
  @override
  _DemoEventChannelState createState() => _DemoEventChannelState();
}

class _DemoEventChannelState extends State<DemoEventChannel> {
  // Communication between dart & native code is through BasicMessageChannel (stream)
  // side native code continuity push event to flutter (update screen)
  static const stream = const EventChannel('stream');

  String _message = 'empty';

  @override
  void initState() {
    super.initState();

    stream.receiveBroadcastStream().listen((data) {
      setState(() {
        _message = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo EventChannel'),
      ),
      body: Center(
        child: Container(
          child: Text(
            _message,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
