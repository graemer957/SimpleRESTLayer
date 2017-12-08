//
//  ViewController.swift
//  Demo
//
//  Created by Graeme Read on 11/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    let API = APIController()
    
    // MARK: - IBActions
    @IBAction func findIPAddress() {
        API.getIP { response in
            switch response {
            case .success(let response):
                print("Your IP address is : \(response.model.address)")
            case .failure(let error):
                let message = error.message != nil ? " (\(error.message!))" : ""
                print("An error occured" + message)
            }
        }
    }
}
