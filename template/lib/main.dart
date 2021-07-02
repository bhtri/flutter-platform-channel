import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Platform Template',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: MyHomePage(title: 'Flutter Platform '),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const METHOD_CHANNEL_NAME = 'com.bhtri.platform_channels/method';
  static const EVENT_CHANNEL_NAME = 'com.bhtri.platform_channels/event';

  static const METHOD_CHANNEL = MethodChannel(METHOD_CHANNEL_NAME);
  static const EVENT_CHANNEL = EventChannel(EVENT_CHANNEL_NAME);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _eventListenner(dynamic obj) {
    debugPrint('Platform Event Result: ');
    debugPrint(obj);
  }

  void _callPlatformMethod() async {
    try {
      final value = await METHOD_CHANNEL.invokeMethod('helloWorld');
      debugPrint('Platform Method Result: ');
      debugPrint(value);
    } catch (e) {
      debugPrint(e);
    }
  }

  bool _isListen = false;
  void _callPlatformEvent() async {
    setState(() {
      _isListen = true;
    });

    EVENT_CHANNEL.receiveBroadcastStream().listen(
      _eventListenner,
      onDone: () {
        debugPrint('onDone');
        setState(() {
          _isListen = false;
        });
      },
      onError: (err) {
        debugPrint('onError');
        debugPrint(err);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _callPlatformMethod,
              child: Text('Call Platform Method'),
            ),
            ElevatedButton(
              onPressed: _isListen == false ? _callPlatformEvent : null,
              child: Text(
                  _isListen == false ? 'Call Platform Event' : 'Listenning'),
            ),
          ],
        ),
      ),
    );
  }
}
