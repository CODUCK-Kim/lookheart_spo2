//
//  File.swift
//  
//
//  Created by KHJ on 10/28/24.
//

import Foundation
import SocketIO


public class SocketIOManager {
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    public init() { }
    
    public func connect(
        url: String,
        endPoint: EndPoint,
        options: SocketIOClientConfiguration,
        eventListeners: [(SocketEvent, EventListener)]
    ) {
        manager = SocketManager(socketURL: URL(string: url)!, config: options)
        socket = manager?.socket(forNamespace: endPoint.rawValue)
//        socket = manager.defaultSocket
        
        guard let socket = socket else {
            print("Socket init Error")
            return
        }
        
        for (eventName, listener) in eventListeners {
            switch eventName {
            case .custom(let event):
                socket.on(event, callback: listener)
            case .client(let clientEvent):
                socket.on(clientEvent: clientEvent, callback: listener)
            }
        }
        
        socket.connect()
    }
    
    public func disconnect() {
        if checkSocketInitialization() {
            print("Socket Disconnected")
            socket?.disconnect()
            socket?.removeAllHandlers()
        }
    }
    
    
    /// JSON 객체
    public func sendData(event: String, data: [String: Any]) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    
    public func sendData(event: String, data: String) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    private func checkSocketInitialization() -> Bool {
        return socket?.status == .connected
    }
}
