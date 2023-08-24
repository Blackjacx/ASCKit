//
//  PageableModel.swift
//  ASCKit
//
//  Created by Stefan Herold on 11.02.21.
//

import Foundation

public struct PageableModel<M: Model>: Pageable {

    public typealias ModelType = M
    public var data: [ModelType]

    public var totalCount: UInt { meta.paging.total }
    public var limit: UInt { meta.paging.limit }
    public var nextUrl: URL? { links.next }

    var meta: PagingInformation
    var links: PagedDocumentLinks

    public init(data: [PageableModel<M>.ModelType] = []) {
        self.data = data
        self.meta = PagingInformation(paging: .init(total: 0, limit: 0))
        self.links = PagedDocumentLinks(self: URL(string: "")!, next: URL(string: "")!)
    }
}

public struct PagedDocumentLinks: Model {
    /// (Required) The link that produced the current document.
    var `self`: URL
    /// The link to the next page of documents (nil for the last page)
    var next: URL?
    /// The link to the first page (always nil except for the last page)
    var first: URL?
}

struct PagingInformation: Model {

    struct Paging: Model {
        /// (Required) The total number of resources matching your request.
        var total: UInt
        /// (Required) The maximum number of resources to return per page, from 0 to 200.
        var limit: UInt
    }

    /// The paging information details.
    var paging: Paging
}
