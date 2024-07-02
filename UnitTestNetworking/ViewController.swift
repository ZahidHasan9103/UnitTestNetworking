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
    
    var session: UrlSessionProtocol = URLSession.shared
   
    var handleResults: ([SearchResult]) -> Void = {print($0)}
    
    private (set) var results: [SearchResult] = []{
        didSet{
            handleResults(results)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonTapped(_ sender: Any) {
        searchForBook(terms: "out from boneville")
    }
    
    private func showError(_ message: String){
        let title = "Network Problem"
        print("\(title): \(message)")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true)
    }
    
    private func searchForBook(terms: String){
        guard let encodedTerms = terms.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?" +
                            "media=ebook&term=\(encodedTerms)") else {return}
        let request = URLRequest(url: url)
        dataTask = session.dataTask(
            with: request,
            completionHandler: {
            [weak self] (data, response, error) in
            guard let self = self else {return}
            
                var decoded: Search?
                var errorMessage: String?
                
                if let error = error{
                    errorMessage = error.localizedDescription
                } else if let response = response as? HTTPURLResponse, response.statusCode != 200{
                    errorMessage = "Response: " + HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                }else if let data = data{
                    do{
                        decoded = try JSONDecoder().decode(Search.self, from: data)
                    }catch{
                        errorMessage = error.localizedDescription
                    }
                }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                
                if let decoded = decoded{
                    self.results = decoded.results
                }
                
                if let errorMessage = errorMessage{
                    self.showError(errorMessage)
                }
                
                self.dataTask = nil
                self.button.isEnabled = true
            }
            
        })
        
        button.isEnabled = false
        dataTask?.resume()
    }
    
}

protocol UrlSessionProtocol{
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: UrlSessionProtocol{
    
}
