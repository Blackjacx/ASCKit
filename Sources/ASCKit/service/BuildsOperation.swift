//
//  BuildsOperation.swift
//  ASCKit
//
//  Created by Stefan Herold on 05.03.21.
//

import Foundation
import Engine

public final class BuildsOperation: AsyncResultOperation<[Build], NetworkError> {

    public enum SubCommand {
        case expire(ids: [String])
    }

    let network = Network.shared

    private let subcommand: SubCommand

    public init(_ subcommand: SubCommand) {
        self.subcommand = subcommand
    }

    public override func main() {

        switch subcommand {
        case let .expire(ids):
            let filters: [Filter]
            if ids.isEmpty {
                filters = [Filter(key: Build.FilterKey.expired, value: "false")]
            } else {
                filters = ids.map { Filter(key: Build.FilterKey.id, value: $0) }
            }
            #warning("This doesn't load all builds due to paging limit")
            let list = ListOperation<PageableModel<Build>>(filters: filters)
            list.executeSync()
            guard let receivedBuilds = try? list.result.get() else {
                finish(with: list.result.map { $0.data })
                return
            }
            let builds = receivedBuilds.data

            guard !builds.isEmpty else {
                #warning("inform the user via PROPER error when no builds have been found")
                finish(with: .failure(NetworkError.noData(error: nil)))
                return
            }

            let results: [Result<Build, NetworkError>] = builds
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
