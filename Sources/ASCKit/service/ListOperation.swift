//
//  ListOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

/// Lists all instances of the given model
public final class ListOperation<M: Model>: AsyncResultOperation<[M], Network.Error> {

    #warning("make global singletom from network")
    let network = Network()

    let filters: [Filter]
    let limit: UInt?

    public init(filters: [Filter] = [], limit: UInt? = nil) {
        self.filters = filters
        self.limit = limit
    }

    public override func main() {
        let endpoint = AscGenericEndpoint.list(type: M.self, filters: filters, limit: limit)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<[M]>) in
            self?.finish(with: result)
        }
    }
}
