//
//  APIEndpoint.swift
//  CleanRepoViewer
//
//  Created by Miksa on 23.12.25.
//

import Foundation

enum APIEndpoint {
    case squareRepositories(page: Int, perPage: Int)

    var path: String {
        switch self {
        case .squareRepositories:
            return "/orgs/square/repos"
        }
    }

    var url: URL? {
        var components = URLComponents(string: APIConstants.baseURL)
        components?.path = path

        switch self {
        case .squareRepositories(let page, let perPage):
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
            ]
        }

        return components?.url
    }
}
