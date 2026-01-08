//
//  LoggingInterceptor.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

#if DEBUG
    /// The only reasonable place where we could got an exception - outer world (network layer)
    /// Instead of a full logging service, this simple interceptor logs requests/responses.
    final class LoggingInterceptor: EventMonitor {

        func requestDidFinish(_ request: Request) {
            guard let urlRequest = request.request else { return }

            print(
                "Request: \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "")"
            )

            if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
                print("Headers: \(headers)")
            }

            if let body = urlRequest.httpBody,
                let bodyString = String(data: body, encoding: .utf8)
            {
                print("Body: \(bodyString)")
            }
        }

        func request<Value>(
            _ request: DataRequest,
            didParseResponse response: DataResponse<Value, AFError>
        ) {
            guard let urlRequest = request.request else { return }

            let statusCode = response.response?.statusCode ?? 0
            print(
                "Response: \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "") [\(statusCode)]"
            )

            if let data = response.data {
                logResponseData(data)
            }

            if let error = response.error {
                print("Error: \(error.localizedDescription)")
            }
        }

        private func logResponseData(_ data: Data) {
            guard
                let jsonObject = try? JSONSerialization.jsonObject(with: data),
                let jsonArray = jsonObject as? [[String: Any]]
            else {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(jsonString)")
                }
                return
            }

            let itemCount = jsonArray.count
            let itemsToShow = min(3, itemCount)
            let limitedArray = Array(jsonArray.prefix(itemsToShow))

            if let limitedData = try? JSONSerialization.data(
                withJSONObject: limitedArray,
                options: .prettyPrinted
            ),
                let prettyString = String(data: limitedData, encoding: .utf8)
            {
                print(
                    "Response Data: [\(itemCount) items, showing first \(itemsToShow)]"
                )
                print(prettyString)
            }
        }
    }
#endif
