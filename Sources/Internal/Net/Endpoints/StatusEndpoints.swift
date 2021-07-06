//
//  StatusEndpoints.swift
//  OneMillionBot
//
//  Created by Adrián R on 19/5/21.
//

import Foundation

extension APIEndpoint where Input == Void, Output == StatusDTO {
    static func getStatus(botId: String, convId: String) -> Self {
        return Self(
            path: "live/status/\(botId)/\(convId)",
            input: (),
            method: .GET,
            encoder: { _ in Result.success(.init()) },
            decoder: { data in
                let decoder = JSONDecoder()
                
                return Result {
                    try decoder.decode(StatusWrapperDTO.self, from: data)
                }
                .flatMap { wrapper in
                    guard let data = wrapper.data.data(using: .utf8) else {
                        return .failure(StatusDecodingFailed())
                    }
                    
                    return Result {
                        try decoder.decode(StatusDTO.self, from: data)
                    }
                }
            }
        )
    }
}

extension APIEndpoint where Input == RequestStatusDTO, Output == Void {
    static func sendStatus(_ status: RequestStatusDTO) -> Self {
        return Self(
            path: "live/status",
            input: status,
            method: .POST
        )
    }
}
