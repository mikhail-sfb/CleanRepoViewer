//
//  SceneDelegate.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // For the 1 featured app Swinject or Needle are overkill
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let dataSource = OrgReposDataSource()
        let repository = OrgReposRepositoryImplementation(
            dataSource: dataSource
        )
        let useCase = FetchRepositoriesUseCase(repository: repository)
        let viewModel = OrgReposViewModel(fetchRepositoriesUseCase: useCase)
        let viewController = OrgReposViewController(viewModel: viewModel)

        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
