//
//  ASCKitTests.swift
//  ASCKit
//
//  Created by Stefan Herold on 19.11.20.
//

import Foundation
import Quick
import Nimble
@testable import Engine

final class ASCKitTests: QuickSpec {

    override func spec() {

        describe("ASCKit") {

            beforeEach {
            }

            it("behaves like xyz") {
                expect("Hello Quick/Nimble!") == "Hello Quick/Nimble!"


                let queue = OperationQueue()
                let unfurlOperation = UnfurlURLChainedOperation(shortURL: URL(string: "https://bit.ly/33UDb5L")!)
                let fetchTitleOperation = FetchTitleChainedOperation()
                fetchTitleOperation.addDependency(unfurlOperation)
                queue.addOperations([unfurlOperation, fetchTitleOperation], waitUntilFinished: true)
                print("Operation finished with: \(fetchTitleOperation.result!)")
                // Prints: Operation finished with: success("A weekly Swift Blog on Xcode and iOS Development - SwiftLee")
            }
        }
    }
}


final class UnfurlURLOperation: AsyncResultOperation<URL, UnfurlURLOperation.Error> {

    enum Error: Swift.Error {
        case canceled
        case missingRedirectURL
        case underlying(error: Swift.Error)
    }

    private let shortURL: URL
    private var dataTask: URLSessionTask?

    init(shortURL: URL) {
        self.shortURL = shortURL
    }

    override func main() {
        var request = URLRequest(url: shortURL)
        request.httpMethod = "HEAD"

        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (_, response, error) in
            if let error = error {
                self?.finish(with: .failure(Error.underlying(error: error)))
                return
            }

            guard let longURL = response?.url else {
                self?.finish(with: .failure(Error.missingRedirectURL))
                return
            }

            self?.finish(with: .success(longURL))
        })
        dataTask?.resume()
    }

    override func cancel() {
        dataTask?.cancel()
        cancel(with: .canceled)
    }
}

final class UnfurlURLChainedOperation: ChainedAsyncResultOperation<Any, URL, UnfurlURLOperation.Error> {

    private let shortURL: URL

    init(shortURL: URL) {
        self.shortURL = shortURL
    }

    override func main() {
        let op = UnfurlURLOperation(shortURL: shortURL)
        op.executeSync()
        finish(with: op.result)
    }
}

public final class FetchTitleChainedOperation: ChainedAsyncResultOperation<URL, String, FetchTitleChainedOperation.Error> {
    public enum Error: Swift.Error {
        case canceled
        case dataParsingFailed
        case missingInputURL
        case missingPageTitle
        case underlying(error: Swift.Error)
    }

    private var dataTask: URLSessionTask?

    override final public func main() {
        guard let input = input else { return finish(with: .failure(.missingInputURL)) }

        var request = URLRequest(url: input)
        request.httpMethod = "GET"

        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            do {
                if let error = error {
                    throw error
                }

                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    throw Error.dataParsingFailed
                }

                guard let pageTitle = self?.pageTitle(for: html) else {
                    throw Error.missingPageTitle
                }

                self?.finish(with: .success(pageTitle))
            } catch {
                if let error = error as? Error {
                    self?.finish(with: .failure(error))
                }
                self?.finish(with: .failure(.underlying(error: error)))
            }
        })
        dataTask?.resume()
    }

    private func pageTitle(for html: String) -> String? {
        guard let rangeFrom = html.range(of: "<title>")?.upperBound else { return nil }
        guard let rangeTo = html[rangeFrom...].range(of: "</title>")?.lowerBound else { return nil }
        return String(html[rangeFrom..<rangeTo])
    }

    override final public func cancel() {
        dataTask?.cancel()
        cancel(with: .canceled)
    }
}
