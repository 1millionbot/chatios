//
//  Bundle.swift
//  OneMillionBot
//
//  Created by Adrián R on 1/6/21.
//
import class Foundation.Bundle

private class BundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    
    static var current: Bundle = {
        let resourceBundle: Bundle
        #if SWIFT_PACKAGE
           resourceBundle = Bundle.module
        #else
            resourceBundle = Bundle(for: BundleFinder.self)
        #endif
        
        return resourceBundle
    }()
}
