//
//  ListOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

/// Lists instances of the given model.
///
/// Supports 2 modi:
/// 1. Load all instances of the given model.
/// 2. Load only the first page and succeeding ones using additional requests.
public final class ListOperation<P: Pageable>: AsyncResultOperation<P, Network.Error> {

    #warning("make global singletom from network")
    let network = Network()

    let filters: [Filter]
    let limit: UInt?

    public init(filters: [Filter] = [], limit: UInt? = nil) {
        self.filters = filters
        self.limit = limit
    }

    public override func main() {
        let endpoint = AscGenericEndpoint.list(type: P.ModelType.self, filters: filters, limit: limit)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<P>) in
            self?.finish(with: result)
        }
    }
}
