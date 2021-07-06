//
//  Localization.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 05/03/2021.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(
            self,
            bundle: Bundle.current,
            comment: ""
        )
    }
    
    func localized(for lan: Language) -> String {
        let localizedBundle = Bundle.current
            .path(forResource: lan.id, ofType: "lproj")
            .flatMap(Bundle.init(path:))
        
        return localizedBundle.map {
            NSLocalizedString(
                self,
                bundle: $0,
                comment: ""
            )
        } ?? self.localized
    }
}

struct LocalizableValues {
    private (set) var yes = "yes".localized
    private (set) var no = "no".localized
    private (set) var forgetData = "forgetData".localized
    private (set) var forgetDataText = "forgetDataText".localized
    private (set) var selectLanguage = "selectLanguage".localized
    private (set) var selectLanguageText = "selectLanguageText".localized
    private (set) var privacyPolicy = "privacyPolicy".localized
    private (set) var writing = "writing".localized
    private (set) var typingBarPlaceholder = "typingBarPlaceholder".localized
    private (set) var gdprLink = "gdprLink".localized
    private (set) var byOneMBot = "byOneMBot".localized
    private (set) var error = "errorHappened".localized
    private (set) var ok = "ok".localized
    
    private (set) var current: Language!
    
    mutating func setLanguage(_ lang: Language) {
        current = lang.id == "va" ?
            Language(
                id: "ca",
                languageName: "languages_ca".localized
            ) : lang
        
        yes = "yes".localized(for: current)
        no = "no".localized(for: current)
        forgetData = "forgetData".localized(for: current)
        forgetDataText = "forgetDataText".localized(for: current)
        selectLanguage = "selectLanguage".localized(for: current)
        selectLanguageText = "selectLanguageText".localized(for: current)
        privacyPolicy = "privacyPolicy".localized(for: current)
        writing = "writing".localized(for: current)
        typingBarPlaceholder = "typingBarPlaceholder".localized(for: current)
        gdprLink = "gdprLink".localized(for: current)
        byOneMBot = "byOneMBot".localized(for: current)
        error =  "errorHappened".localized(for: current)
        ok = "ok".localized(for: current)
    }
}
