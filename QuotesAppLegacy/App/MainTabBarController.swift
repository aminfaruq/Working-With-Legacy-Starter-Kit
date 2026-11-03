//
//  MainTabBarController.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        // Tab 1: Quotes list screen
        let quotesVC = QuotesViewController()
        let quotesNav = UINavigationController(rootViewController: quotesVC)
        quotesNav.tabBarItem = UITabBarItem(
            title: "Quotes",
            image: UIImage(systemName: "quote.bubble"),
            selectedImage: UIImage(systemName: "quote.bubble.fill")
        )
        
        // Tab 2: Empty User screen ready for new feature development
        let userVC = UserViewController()
        let userNav = UINavigationController(rootViewController: userVC)
        userNav.tabBarItem = UITabBarItem(
            title: "User",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        self.viewControllers = [quotesNav, userNav]
    }
}
