//
//  RegisterBundleIdOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 18.11.20.
//

import Foundation
import Engine

public final class RegisterBundleIdOperation: AsyncResultOperation<BundleId, NetworkError> {

    let network = Network.shared

    let attributes: BundleId.Attributes

    public init(identifier: String, name: String, platform: BundleId.Platform, seedId: String? = nil) {
        self.attributes = BundleId.Attributes(identifier: identifier, name: name, platform: platform, seedId: seedId)
    }

    public override func main() {
        let endpoint = AscEndpoint.registerBundleId(attributes: attributes)
        network.request(endpoint: endpoint) { [weak self] (result: RequestResult<BundleId>) in
            self?.finish(with: result)
        }
    }
}
