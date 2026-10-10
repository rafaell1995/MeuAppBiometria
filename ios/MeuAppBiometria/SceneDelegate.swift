import UIKit
import React

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("🟢 [SceneDelegate] willConnectTo chamado")
        
        guard let windowScene = scene as? UIWindowScene else {
            print("🔴 [SceneDelegate] Falhou: não é UIWindowScene")
            return
        }
        print("🟢 [SceneDelegate] windowScene OK")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("🔴 [SceneDelegate] Falhou: delegate não é AppDelegate")
            return
        }
        print("🟢 [SceneDelegate] appDelegate OK")
        
        guard let factory = appDelegate.reactNativeFactory else {
            print("🔴 [SceneDelegate] Falhou: reactNativeFactory é nil")
            return
        }
        print("🟢 [SceneDelegate] factory OK")

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appDelegate.window = window

        factory.startReactNative(
            withModuleName: "MeuAppBiometria",
            in: window,
            launchOptions: nil
        )

        window.makeKeyAndVisible()
        print("🟢 [SceneDelegate] janela visível")
    }
}