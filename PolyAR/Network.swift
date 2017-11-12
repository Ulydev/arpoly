//
//  Network.swift
//  PolyAR
//
//  Created by Ulysse on 11/11/2017.
//  Copyright © 2017 Ulysse. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Network {
    static let baseUrl = "https://plan.epfl.ch/prod/wsgi/search?query="
    
    func search(query: NSString, callback: @escaping((_ json: JSON) -> ())) {
        
        let escapedQuery = query.replacingOccurrences(of: " ", with: "%20")
        let url = "\(Network.baseUrl)\(escapedQuery)"
        print("Fetching \(url)")
        
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let json = JSON(responseData.result.value!)
                callback(json)
            } else {
                callback(JSON.null)
            }
        }
    }
}
