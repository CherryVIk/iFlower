//
//  FlowerLogic.swift
//  iFlower
//
//  Created by Victoria Boichenko on 24.08.2020.
//  Copyright © 2020 Victoria Boichenko. All rights reserved.
//

import Foundation

protocol FlowerManagerDelegate {
    func didUpdateFlowerData(model: FlowerModel)
    func didFailWith(_ error: String)
}

struct FlowerManager{
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    var delegate: FlowerManagerDelegate?
    
    func fetchData(flowerName: String){
        
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize": "500"
        ]
        
        let urlString = self.createURL(parameters)
        self.performRequest(urlString)
        
    }
    
    func  createURL(_ parameters: [String:String]) -> String {
        var urlString = wikipediaURl + "?"
        for item in parameters {
            if item != parameters.first! {
                urlString += "&"
            }
            urlString += item.key
            if item.value != "" {
                urlString += "=" + item.value
            }
            
        }
        print(urlString)
        return urlString
    }
    
    func performRequest(_ urlString: String) {
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){ (data, response, err) in
                if let error = err {
                    print(error)
                    self.delegate?.didFailWith(error.localizedDescription)
                } else {
                    if let safeData = data {
                        if let flowerModel = self.parseJSON(safeData) {
                            self.delegate?.didUpdateFlowerData(model: flowerModel)
                        } else {
                             self.delegate?.didFailWith("Failed to get flowerModel")
                            print("Failed to get flowerModel")
                        }
                        
                    }else{
                        self.delegate?.didFailWith("Failed to get safe data")
                        print("Failed to get safe data")
                    }
                }
            }
            task.resume()
        }else{
              self.delegate?.didFailWith("Failed to get to url")
        }
        
    }
    
    func parseJSON(_ safeData: Data) -> FlowerModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FlowerData.self, from: safeData)
            let id = decodedData.query.pageids[0]
            print(id)
            let flowerDescription = (decodedData.query.pages[id]?.extract)!
            print(flowerDescription)
            return  FlowerModel(description: flowerDescription)
            
        } catch {
            self.delegate?.didFailWith("Failed to decode data")
            print("Failed to decode data")
           
        }
         return nil
    }
    
    
}
