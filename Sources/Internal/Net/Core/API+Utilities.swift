//
//  Utilities.swift
//  OneMillionBotAPI
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation
import Combine

extension URL {
    func appendingURLParams<Param: Encodable>(_ param: Param) -> Result<URL, Error> {
        return Result {
             try JSONEncoder().encode(param)
         }.flatMap { data in
             Result { try JSONSerialization.jsonObject(with: data) }
         }.flatMap { any -> Result<[String: String], Error> in
             if let dict = any as? [String: String] {
                 return .success(dict)
             } else {
                return .failure(APIError.invalidInputData)
             }
         }.flatMap { dict in
            var strCopy = self.absoluteString
            strCopy.append("?")

            for (k, v) in dict {
                strCopy.append("\(k)=\(v)")
            }
            
            if let url = URL(string: strCopy) {
                return .success(url)
            } else {
                return .failure(APIError.invalidInputData)
            }
         }
    }
}

extension Publisher {
    func eraseToAnyError() -> AnyPublisher<Output, Error> {
        mapError { $0 as Error }.eraseToAnyPublisher()
    }
}

func safe(_ string: String) -> URL {
    URL(string: string)!
}
