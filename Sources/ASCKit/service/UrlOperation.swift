//
//  UrlOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

/// Operation for reading given urls. Query parameters like limit or filters should already be added.
public final class UrlOperation<P: Pageable>: AsyncResultOperation<P, Network.Error> {

    #warning("make global singleton from network")
    let network = Network()

    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public override func main() {
        let endpoint = AscGenericEndpoint.url(url, type: P.ModelType.self)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<P>) in
            self?.finish(with: result)
        }
    }
}
