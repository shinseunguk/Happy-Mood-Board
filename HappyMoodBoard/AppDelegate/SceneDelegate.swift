//
//  SceneDelegate.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 11/15/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        handleAutoLogin() ? autoLogin(true) : autoLogin(false)
        
        /*
        만료된 액세스 토큰 갱신 테스트용
        let expiredAccessToken = "eyJhbGciOiJIUzI1NiJ9.eyJtZW1iZXJJZCI6MjQsImlhdCI6MTcwNTUzOTE2NywiZXhwIjoxNzA1NjI1NTY3fQ.XyUKMrZ1Hd5boaaC04UcW3zHEoqKfZNJ_XBH8Y8hwj8"
        let refreshToken = "eyJhbGciOiJIUzI1NiJ9.eyJtZW1iZXJJZCI6MjQsImlhdCI6MTcwNTUzOTE2NywiZXhwIjoxNzEwNzIzMTY3fQ.NwdKleV9XjuLigXu4xXiXv5WeNI2GJoVE8hw_d3OqFE"
        UserDefaults.standard.setValue(expiredAccessToken, forKey: AuthInterceptor.Key.accessToken.rawValue)
        UserDefaults.standard.setValue(refreshToken, forKey: AuthInterceptor.Key.refreshToken.rawValue)
         autoLogin(true) // 개발용 로그인
         */
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func autoLogin(_ handler: Bool) {
        
        if handler {
            let imageInsets: UIEdgeInsets = .init(top: 13, left: 0, bottom: 0, right: 0)
            
            // home
            let homeViewController = HomeViewController()
            homeViewController.tabBarItem.image = .init(named: "tabbar.home")
            homeViewController.tabBarItem.selectedImage = .init(named: "tabbar.home.selected")
            homeViewController.tabBarItem.imageInsets = imageInsets
            let homeNavigationController = UINavigationController(rootViewController: homeViewController)
            
            // register
            let registerViewController = UIViewController()
            registerViewController.tabBarItem.image = .init(named: "tabbar.register")
            registerViewController.tabBarItem.imageInsets = imageInsets
            
            // list
            let listViewController = MyTabViewController()
            listViewController.tabBarItem.image = .init(named: "tabbar.list")
            listViewController.tabBarItem.selectedImage = .init(named: "tabbar.list.selected")
            listViewController.tabBarItem.imageInsets = imageInsets
            let listNavigationController = UINavigationController(rootViewController: listViewController)
            
            // tab
            let tabBarController = TabBarController()
            tabBarController.viewControllers = [
                homeNavigationController,
                registerViewController,
                listNavigationController
            ]
            window?.rootViewController = tabBarController
            window?.backgroundColor = .primary100
            window?.makeKeyAndVisible()
        } else {
            let rootViewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = true
            window?.rootViewController = navigationController
            window?.backgroundColor = .primary100
            window?.makeKeyAndVisible()
        }
    }
    
    /// 자동로그인 분기 함수
    /// - Returns: AccessToken, RefreshToken이 UserDefaults에 존재하면 True, 그렇지 않다면 false
    func handleAutoLogin() -> Bool {
        guard let _ = UserDefaults.standard.string(forKey: "accessToken"),
              let _ = UserDefaults.standard.string(forKey: "refreshToken") else {
                  return false
              }
        return true
    }
}
