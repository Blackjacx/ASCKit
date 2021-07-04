//
//  PagedItemLoader.swift
//  Connector
//
//  Created by Stefan Herold on 20.04.21.
//

import Foundation
import Combine
import Engine

public final class PagedItemLoader<Item: IdentifiableModel>: ObservableObject {

    private (set) public var items: [Item] = []
    private (set) public var pageableItems: PageableModel<Item>?

    private let filters: [Filter]
    private let limit: UInt?

    private var network = Network.shared
    private var canLoadMorePages = true


    /// Initializer with the possibility to specify a pagaing limit.
    /// - Parameter limit: The maximum size of one page of items. Specify `nil` if you want to load all items at once.
    public init(filters: [Filter] = [], limit: UInt? = Constants.defaultPageSize) {
        self.filters = filters
        self.limit = limit
    }

    /// - throws: NetworkError
    public func loadMoreIfNeeded(currentItem: Item? = nil) async throws {
        guard let item = currentItem else {
            try await loadMoreContent()
            return
        }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            try await loadMoreContent()
        }
    }

    private func loadMoreContent() async throws {
        guard canLoadMorePages else {
            return
        }

        let pageableResult = try await ASCService.list(previousPageable: pageableItems,
                                                       filters: filters,
                                                       limit: limit)

        items += pageableResult.data
        pageableItems = pageableResult
        canLoadMorePages = pageableResult.totalCount > items.count
    }
}
