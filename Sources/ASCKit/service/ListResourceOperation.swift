//
//  ListResourceOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 09.02.21.
//

import Foundation
import Engine

public final class ListResourceOperation<S: Codable>: AsyncResultOperation<[S], Network.Error> {

    #warning("make global singletom from network")
    let network = Network()

    let filters: [Filter]
    let limit: UInt

    public init(filters: [Filter] = [], limit: UInt = ASCKit.Constants.pagingLimit) {
        self.filters = filters
        self.limit = limit
    }

    public override func main() {
        let resource: AscResource!

        switch S.self {
        case is Group.Type:             resource = AscResource.listBetaGroups(filters: filters, limit: limit)
        case is App.Type:               resource = AscResource.listApps(filters: filters, limit: limit)
        case is Build.Type:             resource = AscResource.listBuilds(filters: filters, limit: limit)
        case is BetaTester.Type:        resource = AscResource.listBetaTester(filters: filters, limit: limit)
        default: preconditionFailure("Missing implementation resource type \(S.self)")
        }
        network.request(resource: resource) { [weak self] (result: RequestResult<[S]>) in
            self?.finish(with: result)
        }
    }
}
