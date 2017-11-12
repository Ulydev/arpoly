//
//  CoordinatesConverter.swift
//  PolyAR
//
//  Created by Ulysse on 11/11/2017.
//  Copyright © 2017 Ulysse. All rights reserved.
//

import Foundation

class CoordinatesConverter {
    static func CHtoWGS (y: Double, x: Double) -> [Double] {
        return [
            CHtoWGSlng(y: y, x: x),
            CHtoWGSlat(y: y, x: x)
        ]
    }
    
    static func CHtoWGSlat (y: Double, x: Double) -> Double {
        // Converts military to civil and to unit = 1000km
        // Auxiliary values (% Bern)
        let y_aux = (y - 600000)/1000000
        let x_aux = (x - 200000)/1000000
        
        // Process lat
        var lat = 16.9023892 +
            3.238272 * x_aux -
            0.270978 * pow(y_aux, 2) -
            0.002528 * pow(x_aux, 2) -
            0.0447     * pow(y_aux, 2) * x_aux -
            0.0140     * pow(x_aux, 3)
        
        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lat = lat * 100 / 36
        
        return lat
    }
    
    static func CHtoWGSlng (y: Double, x: Double) -> Double {
        // Converts military to civil and    to unit = 1000km
        // Auxiliary values (% Bern)
        let y_aux = (y - 600000)/1000000
        let x_aux = (x - 200000)/1000000
        
        // Process lng
        var lng = 2.6779094 +
            4.728982 * y_aux +
            0.791484 * y_aux * x_aux +
            0.1306     * y_aux * pow(x_aux, 2) -
            0.0436     * pow(y_aux, 3)
        
        // Unit 10000" to 1 " and converts seconds to degrees (dec)
        lng = lng * 100 / 36
    
        return lng;
    }
}
