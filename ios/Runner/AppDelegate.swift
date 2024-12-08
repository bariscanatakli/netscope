import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "com.example.traceroute/traceroute"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let tracerouteChannel = FlutterMethodChannel(name: CHANNEL,
                                                    binaryMessenger: controller.binaryMessenger)
        tracerouteChannel.setMethodCallHandler { (call, result) in
            if call.method == "getTraceroute" {
                if let ip = call.arguments as? String {
                    do {
                        let tracerouteResult = try self.runTraceroute(ip: ip)
                        result(tracerouteResult)
                    } catch {
                        result(FlutterError(code: "UNAVAILABLE", message: "Traceroute not available", details: nil))
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func runTraceroute(ip: String) throws -> String {
        let task = Process()
        task.launchPath = "/usr/sbin/traceroute"
        task.arguments = [ip]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output
        } else {
            throw NSError(domain: "TracerouteError", code: 1, userInfo: nil)
        }
    }
}
