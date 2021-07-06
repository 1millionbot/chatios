//
//  DiskStorage.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 21/01/2021.
//

import Foundation
import KeychainAccess

// MARK: Disk storage keys

private let prefix = "_OneMillionBotUserDefaults_"
let LANGUAGE = "language"
let POLICY_ACCEPTED = "policyAccepted"
let USER = "user"
let CONVERSATION = "conversationId"

struct DiskStorage {
    fileprivate let write: (String, Data?) -> Void
    fileprivate let read: (String) -> Data?
}

extension DiskStorage {
    
    /// Wrapper around KeychainAccess. Stores data in the Keychain.
    
    static var live: DiskStorage {
        let keychain = Keychain(service: "com.1mb.ios_sdk")
        
        return DiskStorage(
            write: { key, object in
                if let object = object {
                    keychain[data: key] = object
                } else {
                    do {
                        try keychain.remove(key)
                    } catch {
                        Env.log(error.dumped)
                    }
                }
            },
            read: { key in
                return keychain[data: key]
            }
        )
    }
    
    static func test(dict: Reference<[String: Data]>) -> DiskStorage {
        return DiskStorage(
            write: { key, value in dict.value[key] = value },
            read: { dict.value[$0] }
        )
    }
}

fileprivate struct Wrapped<A: Codable>: Codable {
    let of: A
}

extension DiskStorage {
    func write<Input: Codable>(_ input: Input, for key: String) {
        let newkey = "\(prefix)\(key)"
        let i: Wrapped<Input> = Wrapped(of: input)

        (try? JSONEncoder().encode(i)).map {
            self.write(newkey, $0)
        }
    }
    
    func read<Output: Codable>(_ key: String) -> Output? {
        let newkey = "\(prefix)\(key)"

        return read(newkey).flatMap {
            try? JSONDecoder().decode(Wrapped<Output>.self, from: $0)
        }.map { $0.of }
    }
    
    func delete(_ key: String) -> Void {
        let newkey = "\(prefix)\(key)"
        write(newkey, nil)
    }
}

extension DiskStorage {
    static var firstLaunch: Bool {
        let key = "\(prefix)firstLaunch"
        let defaults = UserDefaults.standard
        let isFirst = defaults.object(forKey: key) as? Bool
        
        if let firstLaunch = isFirst {
            return firstLaunch
        } else {
            defaults.set(false, forKey: key)
            return true
        }
    }
    
    func cleanPreviousSetupIfNeeded() {
        if DiskStorage.firstLaunch {
            delete(LANGUAGE)
            delete(USER)
            delete(POLICY_ACCEPTED)
            delete(CONVERSATION)
        }
    }
}
