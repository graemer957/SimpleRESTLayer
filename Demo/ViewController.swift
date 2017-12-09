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
            self?.handle(response) { ip in
                print("Your IP address is : \(ip.address)")
            }
        }
    }
    
    @IBAction func bounceHeaders() {
        API.getHeaders { [weak self] response in
            self?.handle(response) { headers in
                print("Response headers from httpbin.org:")
                headers.forEach { key, value in
                    print("\t\(key): \(value)")
                }
            }
        }
    }
    
    @IBAction func sendJSONRequest() {
        let headers = Headers(dictionary: [
            "hello": "world",
            "parameter 2": "😉"
            ])
        
        do {
            try API.postJSON(headers) { [weak self] response in
                self?.handle(response) { json in
                    print("You send the following JSON to httpbin.org: \(json.string)")
                }
            }
        } catch {
            print("Unable to send JSON due to error: \(error)")
        }
    }
    
    @IBAction func sendFormURLEncodedRequest() {
        let parameters = [
            "hello": "world",
            "parameter 2": "😉"
        ]
        
        API.postFormURLEncoded(parameters) { [weak self] response in
            self?.handle(response) { form in
                print("You send the following parameters to httpbin.org using Form URL encoding:")
                form.parameters.forEach { key, value in
                    print("\t\(key): \(value)")
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func handle<T>(_ response: Response<T>, completion: (T) -> Void) {
        switch response {
        case .success(let response):
            completion(response.model)
        case .failure(let error):
            let message = error.message != nil ? " (\(error.message!))" : ""
            print("An error occured" + message)
        }
    }
}
