//
//  BuildsOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 05.03.21.
//

import Foundation
import Engine

public final class BuildsOperation: AsyncResultOperation<[Build], Network.Error> {

    public enum SubCommand {
        case list(filters: [Filter], limit: UInt? = nil)
        case expire(ids: [String])
    }

    #warning("make global singletom from network")
    let network = Network()

    private let subcommand: SubCommand  

    public init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    public override func main() {

        switch subcommand {
        case let .list(filters, limit):
            let op = ListOperation<Build>(filters: filters, limit: limit)
            op.executeSync()
            finish(with: op.result)

        case let .expire(ids):
            let filters: [Filter]
            if ids.isEmpty {
                filters = [Filter(key: Build.FilterKey.expired, value: "false")]
            } else {
                filters = ids.map { Filter(key: Build.FilterKey.id, value: $0) }
            }
            let list = ListOperation<Build>(filters: filters)
            list.executeSync()
            guard let receivedBuilds = try? list.result.get() else {
                finish(with: list.result)
                return
            }
            let builds = receivedBuilds

            guard !builds.isEmpty else {
                #warning("inform the user via PROPER error when no builds have been found")
                finish(with: .failure(Network.Error.noData(error: nil)))
                return
            }

            let results: [Result<Build, Network.Error>] = builds
                .map { AscEndpoint.expireBuild($0) }
                .map { network.syncRequest(endpoint: $0) }

            #warning("In case of error attach successful builds to the error that reports which have failed (maybe in a dictionary).")

            do {
                let expiredBuilds = try results.map { try $0.get() }
                finish(with: .success(expiredBuilds))
            } catch {
                finish(with: .failure(.generic(error: error)))
            }
        }
    }
}
