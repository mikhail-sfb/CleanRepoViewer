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

    // HTTP
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
    case serverError(statusCode: Int)

    // Client-side
    case noInternetConnection
    case cannotReachServer
    case timedOut

    // Data/decoding
    case decodingError(String)

    // Fallback (keep technical details for logs, not for UI)
    case unknown(String)

    var userMessage: String {
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
        case .serverError(let statusCode):
            return "Server error (\(statusCode)). Please try again later"

        case .noInternetConnection:
            return
                "No internet connection. Please check your network and try again"
        case .cannotReachServer:
            return "Cannot reach the server. Please try again later"
        case .timedOut:
            return "The request timed out. Please try again"

        case .decodingError:
            return "We couldn't process the server response. Please try again"

        case .unknown:
            return "Something went wrong. Please try again"
        }
    }

    var localizedDescription: String {
        return userMessage
    }

    static func from(urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet:
            return .noInternetConnection
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return .cannotReachServer
        case .timedOut:
            return .timedOut
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
}
