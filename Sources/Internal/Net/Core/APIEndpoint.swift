//
//  Endpoint.swift
//  OneMillionBotAPI
//
//  Created by Adrián Rubio on 20/01/2021.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case GET
    case POST
}

extension HTTPMethod {
    /// This http method will require parameters in the url
    var urlParameters: Bool {
        return self == .GET
    }
}

private let jsonDecoder = JSONDecoder()
private let jsonEncoder = JSONEncoder()

/// An endpoint describes how an http request can be made.

public struct APIEndpoint<Input, Output> {
    init(
        path: String,
        input: Input,
        method: HTTPMethod = .GET,
        encoder: @escaping (Input) -> Result<Data, Error>,
        decoder: @escaping (Data) -> Result<Output, Error>,
        localResponse: @escaping () -> Result<Output, Error> = { .failure(APIError.noLocalData) }
    ) {
        self.input = input
        self.method = method
        self.path = path
        self.encoder = encoder
        self.decoder = decoder
        self.localResponse = localResponse
    }
    
    let input: Input
    let method: HTTPMethod
    let path: String
    let encoder: (Input) -> Result<Data, Error>
    let decoder: (Data) -> Result<Output, Error>
    let localResponse: () -> Result<Output, Error>
}

extension APIEndpoint where Input == Void, Output: Decodable {
    init(
        path: String,
        method: HTTPMethod = .GET,
        decoder: JSONDecoder = jsonDecoder,
        localResponse: @escaping () -> Result<Output, Error> = { .failure(APIError.noLocalData) }
    ) {
        self.init(
            path: path,
            input: (),
            method: method,
            encoder: { _ in Result.success(.init()) },
            decoder: { data in Result { try decoder.decode(Output.self, from: data) } },
            localResponse: localResponse
        )
    }
}

extension APIEndpoint where Input: Encodable, Output: Decodable {
    init(
        path: String,
        input: Input,
        method: HTTPMethod = .GET,
        encoder: JSONEncoder = jsonEncoder,
        decoder: JSONDecoder = jsonDecoder,
        localResponse: @escaping () -> Result<Output, Error> = { .failure(APIError.noLocalData) }
    ) {
        self.init(
            path: path,
            input: input,
            method: method,
            encoder: { input in
                Result { try encoder.encode(input) }
            },
            decoder: { data in
                Result { try decoder.decode(Output.self, from: data) }
            },
            localResponse: localResponse
        )
    }
    
    func request(_ rootUrl: URL, headers: [String: String]) -> AnyPublisher<URLRequest, Error> {
        let url: Result<URL, Error>
        if method.urlParameters {
            url = rootUrl
                .appendingPathComponent(path)
                .appendingURLParams(input)
        } else {
            url = Result.success(rootUrl.appendingPathComponent(path))
        }
        
        return url
            .map { URLRequest(url: $0) }
            .flatMap {
                var copy = $0
                copy.httpMethod = method.rawValue
                headers.forEach {
                    copy.addValue($0.value, forHTTPHeaderField: $0.key)
                }
                
                if !method.urlParameters {
                    do {
                        copy.httpBody = try encoder(input).get()
                    } catch {
                        return .failure(error)
                    }
                }
                
                return .success(copy)
            }
            .publisher
            .eraseToAnyPublisher()
    }
}

extension APIEndpoint where Input == Void {
    func request(_ rootUrl: URL, headers: [String: String]) -> AnyPublisher<URLRequest, Error> {
        let url = rootUrl.appendingPathComponent(path)
        var r = URLRequest(url: url)
        headers.forEach {
            r.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        r.httpMethod = method.rawValue
        
        return Just(r)
            .eraseToAnyError()
            .eraseToAnyPublisher()
    }
}

extension APIEndpoint where Output == Void, Input: Encodable {
    init(
        path: String,
        input: Input,
        method: HTTPMethod = .GET,
        encoder: JSONEncoder = jsonEncoder,
        localResponse: @escaping () -> Result<Output, Error> = { .failure(APIError.noLocalData) }
    ) {
        self.init(
            path: path,
            input: input,
            method: method,
            encoder: { input in
                Result { try encoder.encode(input) }
            },
            decoder: { _ in Result.success(()) },
            localResponse: localResponse
        )
    }
    
    var returnsNothing: APIEndpoint<Input, Nothing> {
        return .init(
            path: path,
            input: input,
            method: method,
            encoder: encoder,
            decoder: { _ in Result.success(Nothing(dontLook: "")) },
            localResponse: {
                return localResponse().map { _ in Nothing(dontLook: "")
                }
            }
        )
    }
}
