//
//  SceneDelegate.swift
//  GalleryApp
//
//  Created by admin on 3.04.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        
        let favoriteRepository = FavoritesRepositoryImpl(container: persistentContainer)
        let apiClient = APIClient()
        let photoRepository = PhotoRepositoryImpl(apiClient: apiClient, favoriteRepository: favoriteRepository)
        
        let fetchPhotosUseCase = FetchPhotosUseCaseImpl(repository: photoRepository)
        let getFavoritesUseCase = GetFavoritesUseCaseImpl(repository: favoriteRepository)
        let toggleFavoriteUseCase = ToggleFavoriteUseCaseImpl(repository: favoriteRepository)
        
        let galleryViewModel = GalleryViewModel(
            fetchPhotosUseCase: fetchPhotosUseCase,
            getFavoritesUseCase: getFavoritesUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
        
        let galleryViewController = GalleryViewController(viewModel: galleryViewModel)
        
        galleryViewController.onPhotoSelected = { photo, allPhotos in
            let detailViewModel = DetailViewModel(
                photo: photo,
                allPhotos: allPhotos,
                toggleFavoriteUseCase: toggleFavoriteUseCase
            )
            let detailViewController = DetailViewController(viewModel: detailViewModel)
            galleryViewController.navigationController?.pushViewController(detailViewController, animated: true)
        }
        let favoriteViewModel = FavoritesViewModel(favoriteRepository: favoriteRepository, toggleFavoriteUseCase: toggleFavoriteUseCase)
        let favoriteViewController = FavoritesViewController(viewModel: favoriteViewModel)
        
        favoriteViewController.onPhotoSelected = { photo, allPhotos in
            let detailViewModel = DetailViewModel(
                photo: photo,
                allPhotos: allPhotos,
                toggleFavoriteUseCase: toggleFavoriteUseCase
            )
            let detailViewController = DetailViewController(viewModel: detailViewModel)
            favoriteViewController.navigationController?.pushViewController(detailViewController, animated: true)
        }
        
        let galleryNav = UINavigationController(rootViewController: galleryViewController)
        let favoritesNav = UINavigationController(rootViewController: favoriteViewController)
       
        galleryNav.tabBarItem.image = UIImage(systemName: "photo")
        favoritesNav.tabBarItem.image = UIImage(systemName: "heart")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [galleryNav, favoritesNav]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
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
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

