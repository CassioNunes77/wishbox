import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Log para debug
    print("=== AppDelegate: didFinishLaunchingWithOptions ===")
    
    // Registrar plugins do Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    // Configurar tratamento de exceções não capturadas
    NSSetUncaughtExceptionHandler { exception in
      print("=== Uncaught Exception ===")
      print("Name: \(exception.name)")
      print("Reason: \(exception.reason ?? "Unknown")")
      print("Stack: \(exception.callStackSymbols.joined(separator: "\n"))")
      print("===========================")
    }
    
    // Garantir que a window está configurada
    if window == nil {
      window = UIWindow(frame: UIScreen.main.bounds)
    }
    
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("=== AppDelegate: didFinishLaunchingWithOptions completed: \(result) ===")
    return result
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    print("=== AppDelegate: applicationDidBecomeActive ===")
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    print("=== AppDelegate: applicationWillEnterForeground ===")
  }
}
