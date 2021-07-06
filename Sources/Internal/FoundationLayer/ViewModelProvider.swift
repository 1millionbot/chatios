//
//  ViewModelProvider.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 11/02/2021.
//

import Foundation
import SwiftUI
import Combine

final class SwiftUIViewModelProvider {
    private var viewModels: [String: AnyObject] = [:]
    
    static let shared: SwiftUIViewModelProvider = .init()
    
    private init() {}
    
    func provide<A: AnyObject>(_ initializer: () -> A) -> A {
        let type = "\(A.self)"
        let viewModel = viewModels[type] as? A
            ?? initializer()
        
        storeIfNecessary(viewModel, type: type)
        
        return viewModel
    }
    
    func release<A: AnyObject>(_ type: A.Type) {
        viewModels["\(A.self)"] = nil
    }
    
    func refresh<A: AnyObject>(_ initializer: () -> A) -> A? {
        if viewModels["\(A.self)"] == nil { return nil }
        release(A.self)
        return provide(initializer)
    }
    
    func release() {
        viewModels = [:]
    }
    
    private func storeIfNecessary<A: AnyObject>(_ a: A, type: String) {
        if viewModels[type] == nil {
            viewModels[type] = a
        }
    }
}

@dynamicMemberLookup
final class ViewModel<A>: ObservableObject where A: ObservableObject   {
    var cancellable: AnyCancellable?
    weak var vm: A?
    
    var value: A {
        get {
            let viewModel = SwiftUIViewModelProvider.shared
                .provide(provider)
            
            if vm !== viewModel {
                cancellable = nil
            }
            
            vm = viewModel
            
            if cancellable == nil {
                cancellable = vm?
                    .objectWillChange
                    .sink { [unowned self] _ in
                        self.objectWillChange.send()
                }
            }

            return vm!
        }
    }
    
    private let provider: () -> A

    init(_ provider: @escaping () -> A) {
        self.provider = provider
    }

    subscript<Property>(dynamicMember keypath: KeyPath<A, Property>) -> Property {
        return value[keyPath: keypath]
    }
    
    subscript<Property>(dynamicMember keypath: ReferenceWritableKeyPath<A, Property>) -> Property {
        get { value[keyPath: keypath] }
        set { value[keyPath: keypath] = newValue }
    }
}
