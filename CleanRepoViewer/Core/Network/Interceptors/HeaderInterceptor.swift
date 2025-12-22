//
//  HeaderInterceptor.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

final class HeaderInterceptor: RequestInterceptor {

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest

        request.setValue(
            HTTPHeaderValue.githubJSON,
            forHTTPHeaderField: HTTPHeader.accept
        )
        request.setValue(
            NetworkConfiguration.githubApiVersion,
            forHTTPHeaderField: HTTPHeader.githubApiVersion
        )
        request.setValue(
            UUID().uuidString,
            forHTTPHeaderField: HTTPHeader.requestId
        )

        if let token = Configuration.githubToken {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: HTTPHeader.authorization
            )
        }

        completion(.success(request))
    }
}
