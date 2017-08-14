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
                self.showAlert(title: "IP Address", message: "Your IP address is : \(response.0.address)")
            case .failure(let error):
                let message = error.message != nil ? " (\(error.message!))" : ""
                self.showAlert(title: "Error", message: "An error occured" + message)
            }
        }
    }
    
    // MARK: - Private methods
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alertController.addAction(okButton)
        present(alertController, animated: true)
    }
}
