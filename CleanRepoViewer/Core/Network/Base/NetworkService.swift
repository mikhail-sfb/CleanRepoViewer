//
//  NetworkService.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

final class NetworkService: NetworkServicing {

    static let shared: NetworkServicing = NetworkService()

    private let session: Session

    private init() {
        let interceptors = Interceptor(
            adapters: [HeaderInterceptor()],
            retriers: [RetryPolicy()]
        )

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConfiguration.timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        var eventMonitors: [EventMonitor] = []
        #if DEBUG
            eventMonitors.append(LoggingInterceptor())
        #endif

        self.session = Session(
            configuration: configuration,
            interceptor: interceptors,
            eventMonitors: eventMonitors
        )
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        do {
            let value =
                try await session
                .request(url)
                .validate(statusCode: 200..<300)
                .serializingDecodable(T.self)
                .value

            return value
        } catch {
            throw mapAFError(error)
        }
    }

    private func mapAFError(_ error: Error) -> NetworkError {
        guard let afError = error as? AFError else {
            return .unknown(error.localizedDescription)
        }

        if case .responseSerializationFailed(let reason) = afError {
            if case .decodingFailed(let decodingError) = reason {
                return .decodingError(decodingError.localizedDescription)
            }
        }

        if case .responseValidationFailed(let reason) = afError {
            if case .unacceptableStatusCode(let statusCode) = reason {
                return mapStatusCode(statusCode)
            }
        }

        return .unknown(error.localizedDescription)
    }

    private func mapStatusCode(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case HTTPStatusCode.unauthorized:
            return .unauthorized
        case HTTPStatusCode.forbidden:
            return .forbidden
        case HTTPStatusCode.notFound:
            return .notFound
        case HTTPStatusCode.tooManyRequests:
            return .rateLimitExceeded
        case 500...599:
            return .serverError(statusCode: statusCode)
        default:
            return .unknown("HTTP \(statusCode)")
        }
    }
}
