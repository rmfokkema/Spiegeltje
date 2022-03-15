	  //
	  //  AppDelegate.swift
	  //  Spiegeltje
	  //
	  //  Created by René Fokkema on 22/02/2022.
	  //

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	  var window: UIWindow?
	  var vc: ViewController!

	  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
			 guard let _ = (scene as? UIWindowScene) else { return }

			 vc = window?.rootViewController as? ViewController
	  }

	  func sceneWillResignActive(_ scene: UIScene) { vc.blur(true, animated: true) }

	  func sceneDidDisconnect(_ scene: UIScene) {}

	  func sceneDidBecomeActive(_ scene: UIScene) {
			 vc.blur(false, animated: true)

			 vc.checkSettings()
	  }

	  func sceneWillEnterForeground(_ scene: UIScene) {}

	  func sceneDidEnterBackground(_ scene: UIScene) { vc.blur(true, animated: false) }
}

