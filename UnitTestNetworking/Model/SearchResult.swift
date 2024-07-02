//
//  SearchResult.swift
//  UnitTestNetworking
//
//  Created by ZEUS on 2/7/24.
//

import Foundation

struct Search: Decodable{
    let results: [SearchResult]
}

struct SearchResult: Decodable, Equatable{
    let artistName: String
    let trackName: String
    let averageUserRating: Float
    let genres: [String]
}
