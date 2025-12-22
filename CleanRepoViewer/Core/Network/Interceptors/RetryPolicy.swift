//
//  RetryPolicy.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

final class RetryPolicy: RequestInterceptor {

    private let retryLimit = NetworkConfiguration.retryLimit
    private let retryableHTTPMethods: Set<HTTPMethod> = [.get]

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }

        guard let httpMethod = request.request?.method,
            retryableHTTPMethods.contains(httpMethod)
        else {
            completion(.doNotRetry)
            return
        }

        let delay = pow(2.0, Double(request.retryCount))
        completion(.retryWithDelay(delay))
    }
}
