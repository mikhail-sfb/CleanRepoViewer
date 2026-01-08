//
//  UseCase.swift
//  CleanRepoViewer
//
//  Created by Miksa on 22.12.25.
//

import Foundation

// Just generalised the way of how we create UseCases
protocol UseCase {
    associatedtype Input
    associatedtype Output

    func execute(input: Input) async throws -> Output
}

struct NoParams {
    init() {}
}
