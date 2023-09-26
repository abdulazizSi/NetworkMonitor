//
//  NetworkMonitorService.swift
//  NetworkMonitor
//
//  Created by Abdulaziz Alsikh on 26.09.2023.
//

import Foundation
import Network

/**
   A class responsible for monitoring network connectivity and determining the current connection type.
   
   You can use this class to monitor network status changes and determine whether the device is connected to the internet via Wi-Fi, cellular, Ethernet, or an unknown connection.

   - Note: This class follows the Singleton design pattern and provides a shared instance via the `shared` property.
 */
open class NetworkMonitor {
    
    /// The shared instance of the `NetworkMonitor` class.
    public static let shared = NetworkMonitor()
    
    /// The queue used for monitoring network changes asynchronously.
    private let queue = DispatchQueue.global()
    
    /// The network path monitor that observes network changes.
    private let monitor: NWPathMonitor
    
    /// Indicates whether the device is currently connected to the internet.
    public private(set) var isConnected: Bool = false
    
    /// The type of network connection (e.g., Wi-Fi, cellular, Ethernet, or unknown).
    public private(set) var connectionType: ConnectionType = .unknown
    
    /// Enumeration representing different types of network connections.
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    /// Private initializer to enforce the Singleton pattern.
    private init() {
        monitor = NWPathMonitor()
    }
    
    /// Starts monitoring network connectivity.
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.getConnectionType(path)
        }
    }
    
    /// Stops monitoring network connectivity.
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    /// Determines the connection type based on the given network path.
    ///
    /// - Parameter path: The network path to analyze.
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
