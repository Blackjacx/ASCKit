//
//  DeleteOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

/// Lists all instances of the given model
public final class DeleteOperation<M: Model>: AsyncResultOperation<EmptyResponse, Network.Error> {

    #warning("make global singletom from network")
    let network = Network()

    let id: String

    public init(id: String) {
        self.id = id
    }

    public override func main() {
        let endpoint = AscGenericEndpoint.delete(type: M.self, id: id)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<EmptyResponse>) in
            self?.finish(with: result)
        }
    }
}
