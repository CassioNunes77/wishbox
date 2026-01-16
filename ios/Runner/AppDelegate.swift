import Flutter
import UIKit
import Foundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Log para debug
    print("=== AppDelegate: didFinishLaunchingWithOptions ===")
    
    // Configurar tratamento de exceções ANTES de qualquer coisa
    NSSetUncaughtExceptionHandler { exception in
      print("=== Uncaught Exception ===")
      print("Name: \(exception.name)")
      print("Reason: \(exception.reason ?? "Unknown")")
      print("Stack: \(exception.callStackSymbols.joined(separator: "\n"))")
      print("===========================")
      // Tentar salvar em arquivo para debug posterior
      if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let logPath = documentsPath.appendingPathComponent("crash_log.txt")
        let crashInfo = """
        Crash: \(exception.name)
        Reason: \(exception.reason ?? "Unknown")
        Stack:
        \(exception.callStackSymbols.joined(separator: "\n"))
        """
        do {
          try crashInfo.write(to: logPath, atomically: true, encoding: .utf8)
          print("=== Crash log saved to: \(logPath.path) ===")
        } catch {
          print("=== Could not write crash log: \(error) ===")
        }
      }
    }
    
    // Garantir que a window está configurada ANTES de registrar plugins
    if window == nil {
      window = UIWindow(frame: UIScreen.main.bounds)
    }
    
    // Registrar plugins do Flutter com tratamento de erro
    do {
      GeneratedPluginRegistrant.register(with: self)
      print("=== Plugins registered successfully ===")
    } catch {
      print("=== Error registering plugins: \(error) ===")
      // Continuar mesmo com erro
    }
    
    // Chamar super com tratamento de erro
    var result = false
    do {
      result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
      print("=== AppDelegate: didFinishLaunchingWithOptions completed: \(result) ===")
    } catch {
      print("=== Error in super.application: \(error) ===")
      result = true // Tentar continuar mesmo com erro
    }
    
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
