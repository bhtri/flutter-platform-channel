import Foundation
import Flutter

public class PlatformPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private static let METHOD_CHANNEL = "com.bhtri.platform_channels/method"
    private static let EVENT_CHANNEL = "com.bhtri.platform_channels/event"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: registrar.messenger())
        let stream = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: registrar.messenger())

        let instance = PlatformPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        stream.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Native IOS")
        switch call.method {
        case "helloWorld":
            result("Helle World Method from IOS")
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private var eventSink: FlutterEventSink?
    private var count: Int = -1

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        self.count = 0

        events("================== Event from IOS ==================")

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.count += 1
            let randomNumber = Int.random(in: 99...99999)

            // https://swift.hiros-dot.net/?p=856
            let dt = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))

            let result = "\(dateFormatter.string(from: dt)) ### \(randomNumber)"

            if let sink = self.eventSink {
                sink(result)

                if self.count == 20 {
                    // sink(FlutterEndOfEventStream) // https://stackoverflow.com/a/59759074/6284714
                    _ = self.onCancel(withArguments: nil)
                    timer.invalidate()
                }
            }

        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let sink = self.eventSink {
            sink("====================================================")
            sink(FlutterEndOfEventStream)
        }

        self.eventSink = nil
        return nil
    }

    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return true
    }
}
