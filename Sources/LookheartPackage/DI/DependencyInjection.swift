//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import Swinject

public class DependencyInjection {
    public static let shared = DependencyInjection()
    private let container: Container
    
    public init() {
        container = Container()
        
        let assemblies: [LookHeartAssembly] = [
            UtilsAssembly(),
            NetworkAssembly(),
            LineChartAssembly()
        ]
        
        assemblies.forEach { $0.assemble(container: container) }
    }
    
    public func registerAssemblies(_ assemblies: [LookHeartAssembly]) {
        assemblies.forEach { $0.assemble(container: container) }
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
}
