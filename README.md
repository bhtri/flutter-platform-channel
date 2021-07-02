# flutter_platform_channel

A sample app which demonstrates how to use `MethodChannel`, `EventChannel`, `BasicMessageChannel` and `MessageCodec` in Flutter (Java & Swift).

## Screenshot
- MethodChannel
![](preview/method.png)

- MessageChannel
![](preview/message.png)

- EventChannel
![](preview/event.png)

# 備忘録

@nasustの[記事](https://nasust.com/flutter/e7db909a-ce82-4d34-af61-a5c95aa3f78e)から備忘録としてもの

Flutterで開発しているとAndroid,iOS固有のAPIが提供されていない場合があります。その場合はFlutter Pubでプラグインを検索しますが、それでも無い場合があります。

これを解決するには自分でAndroid,iOSの必要な機能を開発する必要があります。今回はその開発方法を解説します。

## DartからAndroid,iOSのAPIを実行する
詳しくは[ここ](https://flutter.dev/docs/development/platform-integration/platform-channels)

DartでAndroid,iOSのAPIを実行するには、MethodChannelを使用します。MethodChannelはAndroid,iOSのコードを呼び出すAPIがあります。
```
class _MyHomePageState extends State<MyHomePage> {
  static const METHOD_CHANNEL_NAME = "com.nasust.platform_channels/method";
  static const METHOD_CHANNEL = const MethodChannel(METHOD_CHANNEL_NAME);
}
```
`MethodChannel`は、Android,iOSの機能を呼び出すAPIがあります。コンストラクターで指定する文字列はアドレスのようなものです。Android,iOS側で同じ文字列を指定する事で結びつける事ができます。

  1. Android,iOSの機能を呼び出すには以下の様に使用します。

```
void _callPlatformMethod() async {
    try {
      final value = await METHOD_CHANNEL.invokeMethod("helloWorld");
      logger.info('Platform Method Result: ' + value);
    } catch (e) {
      logger.warning(e.toString());
    }
}
```
`invokeMethod`は、Android,iOS側で定義されたhelloWorldメソッドを呼び出します。 invokeMethodの戻り値がFuture<T>なので、awaitかthenで結果を取得できます。

  2. Android側のコードは以下の通りです。

```
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        PlatformPlugin.registerWith(this.registrarFor("com.nasust.platform_channels.PlatformPlugin"))
    }
}

class PlatformPlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val METHOD_CHANNEL = "com.nasust.platform_channels/method"
    }

    fun registerWith(registrar: PluginRegistry.Registrar) {
        val channel = MethodChannel(registrar.messenger(), METHOD_CHANNEL)
        val instance = PlatformPlugin(registrar.activity()!!)

        channel.setMethodCallHandler(instance)
    }

    override fun onMethodCall(call: MethodCall?, result: MethodChannel.Result?) {
        when (call!!.method) {
            "helloWorld" -> {
                result?.success("Hello World Method Android")
            }
            else -> {
                result?.notImplemented()
            }
        }
    }
```

Android側では`val channel = MethodChannel(registrar.messenger(), METHOD_CHANNEL)`と`channel.setMethodCallHandler(instance)`で、Dartの`invokeMethod`のハンドラーを設定しています。instanceはMethodChannel.MethodCallHandlerを実装したオブジェクトです。

  2. iOS側のコードは以下の通りです。
```
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    PlatformPlugin.register(with: self.registrar(forPlugin: "com.nasust.platform_channels.PlatformPlugin"))
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

public class PlatformPlugin: NSObject, FlutterPlugin {

    private static let METHOD_CHANNEL = "com.nasust.platform_channels/method"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: registrar.messenger())

        let instance = PlatformPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "helloWorld" {
            result("Hello World Method iOS")
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
```

iOS側では`let channel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: registrar.messenger())`と`registrar.addMethodCallDelegate(instance, channel: channel)`で、Dartの`invokeMethod`のハンドラーを設定しています。instanceはFlutterPluginのhandleメソッドをオーバーライドの実装したオブジェクトです。

DartのMethodChannelとAndroidのMethodChannelで指定する名前を同じにする事で、呼び出しと呼び出されるの関係を設定する事ができます。

## Flutter Pluginの機能で実装している理由

Flutter Pluginの形でAndroid,iOSの機能を実装している理由は拡張性、メンテナンス性を上げる為です。

Flutter PlugInは通常、Pluginテンプレートで開発しますが、Androidの`FlutterActivity.registrarFor`またはiOSの`FlutterAppDelegate.register`で直接Pluginのコードを指定する事が出来ます。

公式のMethodChannelのサンプルの様に他のサイトの解説では無名クラスでの実装が多いです。しかし、ある程度の規模になるとメンテナンス性が悪くなります。そこでFlutter Pluginの機能を利用してクラス分けする事によりメンテナンス性を上げる事が出来ます。また、Pluginという単位でロジックを分ける事が出来るので拡張性も上げられます。

Pluginテンプレートでプロジェクト別に開発して、アプリのプロジェクトのpubspec.yamlでファイルパスを指定しても同じ事が出来ますが、個人的には、こちらの方が開発しやすいです。

  1. AndroidのコードでPluginを設定する
```
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        PlatformPlugin.registerWith(this.registrarFor("com.nasust.platform_channels.PlatformPlugin"))
    }
}
```
  2. iOSのコードでPluginを設定する
```
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    PlatformPlugin.register(with: self.registrar(forPlugin: "com.nasust.platform_channels.PlatformPlugin"))
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Android,iOS側からイベントを送信する
Android,iOS側からイベントを送信したい場合は、`EventChannel`を使用します。

Dartの以下のコードでイベントを受信出来ます。
```
static const EVENT_CHANNEL_NAME = "com.nasust.platform_channels/event";
static const EVENT_CHANNEL = const EventChannel(EVENT_CHANNEL_NAME);

@override
void initState() {
    super.initState();
    EVENT_CHANNEL.receiveBroadcastStream().listen(_eventListener);
}

void _eventListener(dynamic obj) {
    logger.info('Platform Event Result: ' + obj);
}
```
MethodChannelの様に名前で送信、受信の関係を結び付けます。 Android,iOSからイベントを送信されると`EVENT_CHANNEL.receiveBroadcastStream().listen();`で指定された_eventListenerメソッドが呼び出されます。

  1. Android側は以下のコードです。
```
class PlatformPlugin(private val context: Context) : EventChannel.StreamHandler{
    companion object {
        private const val EVENT_CHANNEL = "com.nasust.platform_channels/event"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val eventChannel = EventChannel(registrar.messenger(), EVENT_CHANNEL)
            val instance = PlatformPlugin(registrar.activity()!!)

            eventChannel.setStreamHandler(instance)
        }
    }

    var mEventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        mEventSink = events
    }

    override fun onCancel(arguments: Any?) {

    }
```
`val eventChannel = EventChannel(registrar.messenger(), EVENT_CHANNEL)`と`eventChannel.setStreamHandler(instance)`でEventChannelを設定しています。instanceはEventChannel.StreamHandlerを実装したオブジェクトです。

イベントを送信する場合はonListenのeventsを保持して、その後、任意のタイミングで`events.success("Hello World")`などでイベントを送信します。

  2. iOS側は以下のコードです。
```
public class PlatformPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private static let EVENT_CHANNEL = "com.nasust.platform_channels/event"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let stream = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())

        let instance = PlatformPlugin()
        stream.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
```
`let stream = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())`と`stream.setStreamHandler(instance)`で設定しています。instanceはFlutterStreamHandlerを実装したオブジェクトです。

イベントを送信する場合はonListenのeventsを保持して、その後、任意のタイミングで`events("Hello World")`などでイベントを送信します。

## AndroidのonActivityResultとiOSのURL schemeを受信する
アプリ連携、特にOAuth認証したい場合は、AndroidのFlutterActivityのonActivityResultやiOSのFlutterAppDelegateのURL schemeでハンドリングしてします。

この処理をクラス分けしたい場合はFlutter Pluginの機能を使用します。

  1. Android側は以下のコードです。
```
class PlatformPlugin(private val context: Context) : PluginRegistry.ActivityResultListener {
    companion object {
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val instance = PlatformPlugin(registrar.activity()!!)
            registrar.addActivityResultListener(instance)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

        return false
    }
```
`registrar.addActivityResultListener()`でPluginRegistry.ActivityResultListenerの実装したオブジェクトを渡す事で、FlutterActivity.onActivityResultが呼ばれたらActivityResultListener.onActivityResultも呼び出されます。

  2. iOS側は以下のコードです。
```
public class PlatformPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {    
        registrar.addApplicationDelegate(instance)
    }

    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }
```
`registrar.addApplicationDelegate()`で、FlutterPluginのapplicationをオーバーライドしたオブジェクトを渡す事で、FlutterAppDelegate.applicationが呼ばれたらFlutterPlugin.applicationも呼び出されます。

## サンプルプロジェクト
@nasustの[サンプルプロジェクト](/https://github.com/nasust/flutter_sample/tree/master/platform_channels)、ありがとうございます