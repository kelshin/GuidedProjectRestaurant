//
//  Order.swift
//  guidedProjectRestaurant
//
//  Created by Kelbin David on 2022-01-30.
//

import Foundation

struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []){
        self.menuItems = menuItems
    }
}
