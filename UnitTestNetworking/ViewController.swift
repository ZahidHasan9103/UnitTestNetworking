//
//  ViewController.swift
//  UnitTestNetworking
//
//  Created by ZEUS on 1/7/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private(set) weak var button: UIButton!
    private var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonTapped(_ sender: Any) {
        searchForBook(terms: "out from boneville")
    }
    
    private func searchForBook(terms: String){
        guard let encodedTerms = terms.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?" +
                            "media=ebook&term=\(encodedTerms)") else {return}
        let request = URLRequest(url: url)
        dataTask = URLSession.shared.dataTask(
            with: request,
            completionHandler: {
            [weak self] (data, response, error) in
            guard let self = self else {return}
            
            let decoded = String(data: data ?? Data(), encoding: .utf8)
            print("response: \(String(describing: response))")
            print("data: \(String(describing: data))")
            print("error: \(String(describing: error))")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.dataTask = nil
                self.button.isEnabled = true
            }
            
        })
        
        button.isEnabled = false
        dataTask?.resume()
    }
    
}

