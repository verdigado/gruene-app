import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MfaSetupLinkPlugin") {
      MfaSetupLinkPlugin.register(with: registrar)
    }
  }
}

/// Hands MFA setup links (`de.gruene.wkapp.mfa://setup?url=<activation token url>`) to Flutter.
///
/// Handled here instead of by Flutter's deep linking, so the route does not change: the link is tapped in the login sheet
/// of the app, which stays open and continues the login once the app has registered as authenticator.
class MfaSetupLinkPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private let channel: FlutterMethodChannel

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "de.gruene.wkapp/mfa_setup_link", binaryMessenger: registrar.messenger())
    let instance = MfaSetupLinkPlugin(channel: channel)
    // Keeps the instance alive, as scene delegates are only referenced weakly
    registrar.publish(instance)
    registrar.addSceneDelegate(instance)
  }

  // Explicit selector, as an optional protocol method with a mismatching Swift name would silently never be called
  @objc(scene:openURLContexts:)
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = URLContexts.map(\.url).first(where: { $0.scheme == "de.gruene.wkapp.mfa" }) else {
      return false
    }
    channel.invokeMethod("onLink", arguments: url.absoluteString)
    return true
  }
}
