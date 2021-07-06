//
//  NavigationCoordinator.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 23/01/2021.
//

 
import Foundation
import SwiftUI
import UIKit
import Agrume

fileprivate final class LightContentHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

struct NavigationCoordinator {
    let presentRoot: (BotConfig, @escaping () -> Void) -> UIViewController?
    let closeChat: () -> Void
    let openInBrowser: (URL) -> Void
    let presentScreen: (UIViewController) -> Void
    let showPhoto: (UIImage) -> Void
}

extension NavigationCoordinator {
    static var live: NavigationCoordinator {
        let getTop = {
            UIApplication.shared.windows.first.flatMap {
                $0.topViewController()
            }
        }
        
        return NavigationCoordinator(
            presentRoot: { config, completion in
                return getTop().map {
                    let vc = LightContentHostingController(rootView: OneMillionBotRoot(config: config)
                    )
                    vc.view.backgroundColor = .white
                    vc.modalPresentationStyle = .fullScreen
                    
                    $0.present(vc, animated: true, completion: completion)
                    
                    return vc
                }
            },
            closeChat: {
                getTop()?.dismiss(animated: true)
            },
            openInBrowser: { url in
                UIApplication.shared.open(url, options: [:])
            },
            presentScreen: { vc in
                UIApplication.shared.windows.first.flatMap {
                    $0.topViewController()
                }.map {
                    $0.present(vc, animated: true)
                }
            },
            showPhoto: { image in
                getTop().map { top in
                    let agrume = Agrume(
                        image: image,
                        background: .blurred(.regular)
                    )
                    
                    agrume.show(from: top)
                }
            }
        )
    }
}
