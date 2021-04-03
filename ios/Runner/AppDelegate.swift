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
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // MARK: MethodChannel
    func demoMethodChannel1() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.flutter/method1", binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { (call, result) in
            if call.method == "getDeviceInfoString" {
                if let atgs = call.arguments as? Dictionary<String, Any>, let type = atgs["type"] as? String {
                    if type == "MODEL" {
                        result(UIDevice.current.name)
                        //var json = [String: Any]()
                        //result(json) // StandarMethodCodec
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
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.flutter/method2", binaryMessenger: controller.binaryMessenger, codec: FlutterJSONMethodCodec.sharedInstance())
        
        methodChannel.setMethodCallHandler { (call, result) in
            if call.method == "getDeviceInfo" {
                if let atgs = call.arguments as? Dictionary<String, Any>, let type = atgs["type"] as? String {
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
}
