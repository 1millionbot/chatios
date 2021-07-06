//
//  PrivacyPolicyVIewModel.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

import Foundation
import Combine
 

final class PrivacyPolicyViewModel: ObservableObject {
    init(policyLink: [String: URL?]) {
        self.navigateToTOSUrl = {
            if let url = policyLink[Env.lanCode] ?? nil {
                Env.nav.openInBrowser(url)
            }
        }
    }
    
    // MARK: Input
    
    let navigateToTOSUrl: () -> Void
    
    let policyDenied: () -> Void = {
        Env.nav.closeChat()
    }
}
