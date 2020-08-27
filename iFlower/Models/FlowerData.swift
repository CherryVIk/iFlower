//
//  FlowerData.swift
//  iFlower
//
//  Created by Victoria Boichenko on 24.08.2020.
//  Copyright © 2020 Victoria Boichenko. All rights reserved.
//

import Foundation

class FlowerData: Codable {
    let query : Query
}

class Query: Codable {
    let pageids: [String]
    let pages: [String : Pages]
}

class Pages: Codable {
    let extract: String
}
