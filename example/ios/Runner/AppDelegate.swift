import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MethodChannel
        demoMethodChannel1()
        demoMethodChannel2()

        // MessageChannel
        demoBasicMessageChannel1()
        demoBasicMessageChannel2()
        demoBasicMessageChannel3()
        demoBasicMessageChannel4()

        // EventChannel
        demoEventChannel()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: MethodChannel
    func demoMethodChannel1() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.flutter/method1", binaryMessenger: controller.binaryMessenger)

        methodChannel.setMethodCallHandler { (call, result) in
            if call.method == "getDeviceInfoString" {
                if let atgs = call.arguments as? [String: Any], let type = atgs["type"] as? String {
                    if type == "MODEL" {
                        result(UIDevice.current.name)
                        // var json = [String: Any]()
                        // result(json) // StandarMethodCodec
                    } else {
                        result("unknow")
                    }
                } else {
                    result(FlutterError.init(code: "ERROR", message: "type can not null", details: nil))
                }
            }
            result(FlutterMethodNotImplemented)
        }
    }

    func demoMethodChannel2() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.flutter/method2", binaryMessenger: controller.binaryMessenger, codec: FlutterJSONMethodCodec.sharedInstance())

        methodChannel.setMethodCallHandler { (call, result) in
            if call.method == "getDeviceInfo" {
                if let atgs = call.arguments as? [String: Any], let type = atgs["type"] as? String {
                    if type == "MODEL" {
                        var json = [String: Any]()
                        json["name"] = UIDevice.current.name
                        json["batteryLevel"] = UIDevice.current.batteryLevel
                        json["systemVersion"] = UIDevice.current.systemVersion
                        json["systemName"] = UIDevice.current.systemName
                        json["modelName"] = UIDevice.current.model
                        result(json)
                    } else {
                        result(nil)
                    }
                } else {
                    result(FlutterError.init(code: "ERROR", message: "type can not null", details: nil))
                }
            }
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: BasicMessageChannel
    func demoBasicMessageChannel1() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let messageChannel = FlutterBasicMessageChannel(name: "StringCodec", binaryMessenger: controller.binaryMessenger, codec: FlutterStringCodec.sharedInstance())

        messageChannel.setMessageHandler { (message, reply) in
            messageChannel.sendMessage("Hello \(String(describing: message!)) from native code")
            reply(nil)
        }
    }

    func demoBasicMessageChannel2() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let messageChannel = FlutterBasicMessageChannel(name: "JSONMessageCodec", binaryMessenger: controller.binaryMessenger, codec: FlutterJSONMessageCodec.sharedInstance())

        messageChannel.setMessageHandler { (_, reply) in
            var json = [String: Any]()
            json["name"] = UIDevice.current.name
            json["batteryLevel"] = UIDevice.current.batteryLevel
            json["systemVersion"] = UIDevice.current.systemVersion
            json["systemName"] = UIDevice.current.systemName
            json["modelName"] = UIDevice.current.model
            messageChannel.sendMessage(json)
            reply(nil)
        }
    }

    func demoBasicMessageChannel3() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let messageChannel = FlutterBasicMessageChannel(name: "BinaryCodec", binaryMessenger: controller.binaryMessenger, codec: FlutterBinaryCodec.sharedInstance())

        messageChannel.setMessageHandler { (message, reply) in

            guard let _ = Float64.init(String.init(data: message! as! Data, encoding: .utf8)!) else {
                reply("Can not Convert".data(using: .utf8))
                return
            }

            reply("123.456".data(using: .utf8))

        }
    }

    func demoBasicMessageChannel4() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let messageChannel = FlutterBasicMessageChannel(name: "StandardMessageCodec", binaryMessenger: controller.binaryMessenger, codec: FlutterStandardMessageCodec.sharedInstance())

        messageChannel.setMessageHandler { (message, reply) in
            guard var list = message as? [Int] else {
                reply("Can not Convert")
                return
            }
            for i in 0..<list.count {
                list[i] *= 10
            }
            reply(list)
        }
    }

    // MARK: EventChannel
    func demoEventChannel() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let event = FlutterEventChannel(name: "stream", binaryMessenger: controller.binaryMessenger)

        event.setStreamHandler(SwiftStreamHandler())
    }
}

// https://stackoverflow.com/a/59759074/6284714
// https://stackoverflow.com/a/26823723/6284714
// https://stackoverflow.com/a/38696111/6284714
class SwiftStreamHandler: NSObject, FlutterStreamHandler {
    var count: Int = 0
    var timer: Timer?
    var eventSink: FlutterEventSink?

    @objc func onTick() {
        self.count += 1
        if let event = self.eventSink {
            event(String(self.count))
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.timer?.invalidate()
        self.timer = nil
        return nil
    }

}
