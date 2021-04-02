import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DemoBasicMessage extends StatefulWidget {
  @override
  _DemoBasicMessageState createState() => _DemoBasicMessageState();
}

class _DemoBasicMessageState extends State<DemoBasicMessage> {
  // Communication between dart & native code is through BasicMessageChannel
  static const BasicMessageChannel<String> stringPlatform = BasicMessageChannel('name', StringCodec());

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
