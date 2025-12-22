//
//  BaseDataSource.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

protocol BaseDataSource {
    var networkService: NetworkService { get }
}

// we get tid out of boilerplate in our Alomafire requests
extension BaseDataSource {

    func performRequest<T: Decodable>(
        _ endpoint: APIEndpoint
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        do {
            let value = try await networkService.session
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
            return .unknown(error)
        }

        if case .responseSerializationFailed(let reason) = afError {
            if case .decodingFailed(let decodingError) = reason {
                return .decodingError(decodingError)
            }
        }

        if case .responseValidationFailed(let reason) = afError {
            if case .unacceptableStatusCode(let statusCode) = reason {
                return mapStatusCode(statusCode)
            }
        }

        return .unknown(error)
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
            return .unknown(
                AFError.responseValidationFailed(
                    reason: .unacceptableStatusCode(code: statusCode)
                )
            )
        }
    }
}
