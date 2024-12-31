//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Swinject

class NetworkAssembly: LookHeartAssembly {
    func assemble(container: Container) {
        // AlamofireController
        container.register(NetworkProtocol.self) { _ in
            return AlamofireController.shared
        }
        
        // Socket IO
        container.register(SocketIOManager.self) { _ in
            SocketIOManager()
        }
        
        // UserProfile
        container.register(UserProfileManager.self) { _ in
            return UserProfileManager.shared
        }
    }
}
