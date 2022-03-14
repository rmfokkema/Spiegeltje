	  //
	  //  AppDelegate.swift
	  //  Spiegeltje
	  //
	  //  Created by René Fokkema on 22/02/2022.
	  //

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	  var window: UIWindow?
	  var rootVC: ViewController!

	  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
			 guard let _ = (scene as? UIWindowScene) else { return }

			 rootVC = window?.rootViewController as? ViewController
	  }

	  func sceneDidDisconnect(_ scene: UIScene) {}

	  func sceneDidBecomeActive(_ scene: UIScene) {
			 rootVC.blur(false)
			 rootVC.checkSelfieSetting()
	  }

	  func sceneWillEnterForeground(_ scene: UIScene) {}

	  func sceneDidEnterBackground(_ scene: UIScene) {
			 rootVC.blur(true)
	  }
}

