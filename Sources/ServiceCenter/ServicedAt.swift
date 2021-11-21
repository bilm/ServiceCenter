//
//  ServicedAt.swift
//  
//
//  Created by Bil Moorhead on 11/20/21.
//

import Foundation

public struct ServicedAt {
	
	public typealias Duration = Double
	
	public let service: Service
	
	public var timestamp: Date = .now
	public var duration: Duration = 0
	
	public mutating func split() { duration = -timestamp.timeIntervalSinceNow }
	
}

extension ServicedAt: Identifiable {
	
	public var id: String { "\(service.name)[\(timestamp.timeIntervalSinceReferenceDate)]"}
	
}

extension ServicedAt: Comparable {
	
	public static func < (lhs: ServicedAt, rhs: ServicedAt) -> Bool {
		
		lhs.timestamp < rhs.timestamp
		&& lhs.service.name < rhs.service.name
		
	}

}

public protocol ServiceHistory {
	
	func add(_ serviced: ServicedAt)
	func remove(_ serviced: ServicedAt)
	func removeAll()
	
	var events: [ServicedAt] { get }
	
}
