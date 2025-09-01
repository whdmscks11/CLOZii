import UIKit
import Flutter

// ✅추가 
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  
	  // ✅추가 
    GMSServices.provideAPIKey("AIzaSyDgrIuXiYkGyUyVaukA7mXwCvPUaE--uFM")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}