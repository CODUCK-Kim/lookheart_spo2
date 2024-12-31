//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import Swinject
import UIKit

class UtilsAssembly: LookHeartAssembly {
    func assemble(container: Container) {
        // loading indicator
        container.register(LoadingIndicator.self) { _ in
            LoadingIndicator()
        }
        
        // basic alert
        container.register(MyAlert.self) { _ in
            return MyAlert.shared
        }
        
        // dateTime
        container.register(MyDateTime.self) { _ in
            return MyDateTime.shared
        }

        // keycahin
        container.register(Keychain.self) { _ in
            return Keychain.shared
        }
        
        // ui
        container.register(UIFactory.self) { _ in
            return UIFactory.shared
        }
        
        // keyboard
        container.register(KeyboardEventHandling.self) { _ in
            return KeyboardEventHandling()
        }
    }
}
