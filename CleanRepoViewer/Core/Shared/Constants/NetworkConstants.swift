//
//  NetworkConstants.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

enum HTTPHeader {
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let githubApiVersion = "X-GitHub-Api-Version"
    static let requestId = "X-Request-Id"
}

enum HTTPHeaderValue {
    static let applicationJSON = "application/json"
    static let githubJSON = "application/vnd.github+json"
}

enum HTTPStatusCode {
    static let ok = 200
    static let created = 201
    static let unauthorized = 401
    static let forbidden = 403
    static let notFound = 404
    static let tooManyRequests = 429
}
