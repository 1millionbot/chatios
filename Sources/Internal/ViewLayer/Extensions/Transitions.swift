//
//  Transitions.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 12/02/2021.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static var floatingOptions: AnyTransition {
        let insertion = AnyTransition
            .move(edge: .bottom)
        
        let removal = AnyTransition
            .move(edge: .bottom)
        
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var privacy: AnyTransition {
        let insertion = AnyTransition
            .identity
        
        let removal = AnyTransition
            .move(edge: .bottom)
        
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var chat: AnyTransition {
        let insertion = AnyTransition
            .move(edge: .top)
        
        let removal = AnyTransition
            .identity
        
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    static var menu: AnyTransition {
        let insertion = AnyTransition
            .move(edge: .top)
        
        let removal = AnyTransition
            .move(edge: .top)
        
        return .asymmetric(insertion: insertion, removal: removal)

    }
}
