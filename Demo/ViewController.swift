//
//  ViewController.swift
//  Demo
//
//  Created by Graeme Read on 11/03/2017.
//  Copyright © 2017 Optimised Labs Ltd. All rights reserved.
//

import UIKit
import SimpleRESTLayer

class ViewController: UIViewController {
    // MARK: - Properties
    let API = APIController()
    
    // MARK: - IBActions
    @IBAction func findIPAddress() {
        API.getIP { [weak self] result in
            self?.handle(result) { ip in
                print("Your IP address is : \(ip.address)")
            }
        }
    }
    
    @IBAction func bounceHeaders() {
        API.getHeaders { [weak self] result in
            self?.handle(result) { headers in
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
            try API.postJSON(headers) { [weak self] result in
                self?.handle(result) { json in
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
        
        API.postFormURLEncoded(parameters) { [weak self] result in
            self?.handle(result) { form in
                print("You send the following parameters to httpbin.org using Form URL encoding:")
                form.parameters.forEach { key, value in
                    print("\t\(key): \(value)")
                }
            }
        }
    }
    
    @IBAction func getData() {
        API.getData(bytes: 957) { [weak self] result in
            self?.handle(result) { data in
                print("httpbin.org returned \(data.count) bytes of data")
            }
        }
    }
    
    @IBAction func getSpecificHTTPStatus() {
        API.getStatus(status: 202) { [weak self] response in
            self?.handle(response) { _ = $0 }
        }
    }
    
    // MARK: - Private methods
    private func handle<Model>(_ result: Result<Model>, completion: (Model) -> Void) {
        do {
            let (response, model) = try result.unwrap()
            print(response)
            completion(model)
        } catch {
            print("An error occured: \(error)")
        }
    }
}
