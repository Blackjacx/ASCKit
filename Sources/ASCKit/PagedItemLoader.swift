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

    @Published public var isLoading: Bool = false
    public var error: NetworkError?

    private (set) public var items: [Item] = []
    private (set) public var pageableItems: PageableModel<Item>?

    private let filters: [Filter]
    private let limit: UInt?

    private var network = Network.shared
    private var subscribers = Set<AnyCancellable>()
    private var canLoadMorePages = true


    /// Initializer with the possibility to specify a pagaing limit.
    /// - Parameter limit: The maximum size of one page of items. Specify `nil` if you want to load all items at once.
    public init(filters: [Filter] = [], limit: UInt? = Constants.defaultPageSize) {
        self.filters = filters
        self.limit = limit
    }

    public func loadMoreIfNeeded(currentItem: Item? = nil) {
        guard let item = currentItem else {
            loadMoreContent()
            return
        }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            loadMoreContent()
        }
    }

    private func loadMoreContent() {
        guard !isLoading && canLoadMorePages else {
            return
        }
        isLoading = true

        ASCService.list(previousPageable: pageableItems, filters: filters, limit: limit)
            .sink(receiveCompletion: { result in
                defer { self.isLoading = false } // publish new loading state
                guard case let .failure(error) = result else { return } // only handle error case
                self.error = error
            }, receiveValue: { [weak self] (pageableResult: PageableModel<Item>) in
                guard let self = self else { return }
                self.items += pageableResult.data
                self.pageableItems = pageableResult
                self.canLoadMorePages = pageableResult.totalCount > self.items.count
            })
            .store(in: &subscribers)
    }
}
