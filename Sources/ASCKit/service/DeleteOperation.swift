//
//  DeleteOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

/// Lists all instances of the given model
public final class DeleteOperation<M: IdentifiableModel>: AsyncResultOperation<EmptyResponse, Network.Error> {

    #warning("make global singleton from network")
    let network = Network()

    let model: M

    public init(model: M) {
        self.model = model
    }

    public override func main() {
        let endpoint = AscGenericEndpoint.delete(type: M.self, id: model.id)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<EmptyResponse>) in
            defer { self?.finish(with: result) }
            guard let self = self else { return }
            guard case .success = result else { return }
            print("Successfully removed \(M.self).\(self.model.id)")
        }
    }
}
