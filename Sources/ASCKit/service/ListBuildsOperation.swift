//
//  ListBuildsOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 05.02.21.
//

import Foundation
import Engine

public final class ListBuildsOperation: AsyncResultOperation<[Build], Network.Error> {

    #warning("make global singletom from network")
    let network = Network()

    let filters: [Filter]
    let limit: UInt

    public init(filters: [Filter] = [], limit: UInt = ASCKit.Constants.pagingLimit) {
        self.filters = filters
        self.limit = limit
    }

    public override func main() {
        let resource = AscResource.listBuilds(filters: filters, limit: limit)
        network.request(resource: resource) { [weak self] (result: RequestResult<[Build]>) in
            self?.finish(with: result)
        }
    }
}
