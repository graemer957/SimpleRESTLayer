//
//  ViewController.swift
//  Demo
//
//  Created by Graeme Read on 11/03/2017.
//  Copyright © 2017 Graeme Read. All rights reserved.
//

import UIKit
import SimpleRESTLayer

class ViewController: UIViewController {
    // MARK: - Properties
    let API = APIController()
    
    // MARK: - IBActions
    @IBAction func findIPAddress() {
        API.getIP { [weak self] response in
            switch response {
            case .success(let response):
                self?.handle(ip: response.model)
            case .failure(let error):
                self?.handle(error)
            }
        }
    }
    
    @IBAction func bounceHeaders() {
        API.getHeaders { [weak self] response in
            switch response {
            case .success(let response):
                self?.handle(headers: response.model)
            case .failure(let error):
                self?.handle(error)
            }
        }
    }
    
    // MARK: - Private methods
    private func handle(ip: IP) {
        print("Your IP address is : \(ip.address)")
    }
    
    private func handle(headers: [String: String]) {
        print("Response headers from httpbin.org:")
        headers.forEach { key, value in
            print("\t\(key): \(value)")
        }
    }
    
    private func handle(_ error: ResponseError) {
        let message = error.message != nil ? " (\(error.message!))" : ""
        print("An error occured" + message)
    }
}
