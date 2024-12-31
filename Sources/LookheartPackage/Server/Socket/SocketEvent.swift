//
//  File.swift
//  
//
//  Created by 정연호 on 10/28/24.
//

import Foundation
import SocketIO

public typealias EventListener = NormalCallback

public enum SocketEvent {
    case custom(String)
    case client(SocketClientEvent)
}
