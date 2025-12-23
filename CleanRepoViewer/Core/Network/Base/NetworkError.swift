//
//  NetworkError.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

// All possible errors, from our client side, to API troubles
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
    case decodingError(String)
    case serverError(statusCode: Int)
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
