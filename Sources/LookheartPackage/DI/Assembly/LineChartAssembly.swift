//
//  File.swift
//  
//
//  Created by 정연호 on 10/29/24.
//

import Foundation
import Swinject

class LineChartAssembly: LookHeartAssembly {
    func assemble(container: Container) {
        // Controller
        container.register(LineChartController.self) { r in
            LineChartController(
                dateTime: r.resolve(MyDateTime.self)!
            )
        }
        
        // Service
        container.register(LineChartService.self) { r in
            LineChartService(
                networkController: r.resolve(NetworkProtocol.self)!, 
                profile: r.resolve(UserProfileManager.self)!
            )
        }
        
        // Repository
        container.register(LineChartRepository.self) { r in
            LineChartRepository(
                service: r.resolve(LineChartService.self)!,
                dateTimeManager: r.resolve(DateTimeManager.self)!
            )
        }
        
        // ViewModel
        container.register(LineChartViewModel.self) { r in
            LineChartViewModel(
                repository: r.resolve(LineChartRepository.self)!
            )
        }
    }
}
