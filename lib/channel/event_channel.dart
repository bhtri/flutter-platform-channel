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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
