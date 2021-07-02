import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    PlatformPlugin.register(with: self.registrar(forPlugin: "com.bhtri.platform_channels.PlatformPlugin")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
