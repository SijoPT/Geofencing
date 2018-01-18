//
//  NavigationHandler.swift
//  Geofencing
//
//  Created by Sijo on 04/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import UIKit

class NavigationHandler: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        if isLoggedIn() {
            // If User Logged in
            let mapController = MapViewController()
            viewControllers = [mapController]
            
        } else {
            perform(#selector(showLoginViewController), with: nil, afterDelay: 0.01)
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.isLoggedIn()
    }
    
    @objc func showLoginViewController() {
        present(returnViewController(userContlrStrBrdId), animated: true, completion: {})
    }
}
