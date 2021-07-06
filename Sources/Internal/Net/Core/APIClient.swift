//
//  Client.swift
//  OneMillionBotAPI
//
//  Created by Adrián Rubio on 20/01/2021.
//

import Foundation
import Combine

protocol URLSessionable {
    func dataTaskPublisher<Input: Encodable, Output: Decodable>(
        rootURL: URL,
        headers: [String: String],
        endpoint: APIEndpoint<Input, Output>
    ) -> AnyPublisher<Output, Error>
    
    func dataTaskPublisher<Output: Decodable>(
        rootURL: URL,
        headers: [String: String],
        endpoint: APIEndpoint<Void, Output>
    ) -> AnyPublisher<Output, Error>
}

final class APIClient {
    let session: URLSessionable
    
    var globalHeaders: [String: String] {
        return [
            "Authorization": OneMillionBot.instance.apiKey,
            "Content-Type": "application/json"
        ]
    }
    
    init(session: URLSessionable) {
        self.session = session
    }
    
    func request<Input: Encodable, Output: Decodable>(
        rootURL: URL = OneMillionBot.instance.apiEnv.url,
        endpoint: APIEndpoint<Input, Output>
    ) -> AnyPublisher<Output, Error> {
        return session.dataTaskPublisher(
            rootURL: rootURL,
            headers: globalHeaders,
            endpoint: endpoint
        )
    }
    
    func request<Output: Decodable>(
        rootURL: URL = OneMillionBot.instance.apiEnv.url ,
        endpoint: APIEndpoint<Void, Output>
    ) -> AnyPublisher<Output, Error> {
        return session.dataTaskPublisher(
            rootURL: rootURL,
            headers: globalHeaders,
            endpoint: endpoint
        )
    }
    
    func request<Input: Encodable>(
        rootURL: URL = OneMillionBot.instance.apiEnv.url,
        endpoint: APIEndpoint<Input, Void>
    ) -> AnyPublisher<Void, Error> {
        return session
            .dataTaskPublisher(
                rootURL: rootURL,
                headers: globalHeaders,
                endpoint: endpoint.returnsNothing
            )
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: Live implementation

extension URLSession: URLSessionable {
    func dataTaskPublisher<Output>(
        rootURL: URL,
        headers: [String : String],
        endpoint: APIEndpoint<Void, Output>
    ) -> AnyPublisher<Output, Error> where Output : Decodable {
        endpoint.request(rootURL, headers: headers).flatMap {
            self.taskPubliser(for: $0, endpoint: endpoint)
        }.eraseToAnyPublisher()
    }
    
    func dataTaskPublisher<Input: Encodable, Output: Decodable>(
        rootURL: URL,
        headers: [String: String],
        endpoint: APIEndpoint<Input, Output>
    ) -> AnyPublisher<Output, Error> {
        endpoint.request(rootURL, headers: headers).flatMap {
            self.taskPubliser(for: $0, endpoint: endpoint)
        }.eraseToAnyPublisher()
    }
    
    private func taskPubliser<A: Decodable, Input>(
        for req: URLRequest,
        endpoint: APIEndpoint<Input, A>
    ) -> AnyPublisher<A, Error> {
        return self.dataTaskPublisher(for: req).tryMap() {
            guard let httpResponse = $0.response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
                String(data: $0.data, encoding: .utf8).map(Env.log)
                throw URLError(.badServerResponse)
            }
            
            return $0.data
        }
        .flatMap { data in
            return endpoint.decoder(data).publisher
        }
        .eraseToAnyPublisher()
    }
}

// MARK: Offline implementation

struct TestSession: URLSessionable {
    func dataTaskPublisher<Input, Output: Decodable>(
        rootURL: URL = OneMillionBot.instance.apiEnv.url,
        headers: [String: String],
        endpoint: APIEndpoint<Input, Output>
    ) -> AnyPublisher<Output, Error> {
        return endpoint
            .localResponse()
            .publisher
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: ServiceLocator

extension APIClient {
    public static var live: APIClient {
        APIClient(session: URLSession(configuration: .default))
    }
    
    public static var test: APIClient {
        return APIClient(session: TestSession())
    }
}
