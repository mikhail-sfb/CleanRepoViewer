//
//  NetworkService.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Alamofire
import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    
    let session: Session
    
    private init() {
        let interceptors = Interceptor(
            adapters: [HeaderInterceptor()],
            retriers: [RetryPolicy()]
        )
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConfiguration.timeout
        
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
}
