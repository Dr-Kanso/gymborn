import UIKit
import Flutter
// Add this import
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add this line before GeneratedPluginRegistrant call
    GMSServices.provideAPIKey("AIzaSyDSp-kK4SSbLKk8EzRnZbp-WoEh8Vc36MI")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
