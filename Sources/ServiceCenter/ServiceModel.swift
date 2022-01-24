//
//  ServiceModel.swift
//  Goth
//
//  Created by Bil Moorhead on 9/19/21.
//

import Foundation

import Metadata

public protocol ServiceModel {
	
	var alternative: String { get }
	
}

//


extension Array: ServiceModel where Element:ServiceModel {
	
	public var alternative: String { map { $0.alternative }.joined(separator: "\n") }
	
}
extension Data: ServiceModel {
	
	public var alternative: String {
		String(data: self, encoding: .utf8) ?? self.hex }
	
}
extension String: ServiceModel {
	
	public var alternative: String { return self }
	
}

//
//
//

// MARK: - Metadata
extension Metadata: ServiceModel {
	
	public var alternative: String { "\(self)" }
	
	public init(service: Service, serviceCenter: ServiceCenter) async throws {
		
		self = try await serviceCenter.model(service)
		
	}
	
}

// MARK: -	Miscellany
extension Nothing: ServiceModel {
	
	public var alternative: String { "" }
	
}

#if os(iOS)

// MARK: -	UIKit

import UIKit

extension UIImage: ServiceModel {
	
	public var alternative: String { "\(self)" }
	
}

#elseif os(macOS)

// MARK: -	AppKit

import AppKit

extension NSImage: ServiceModel {
	
	public var alternative: String { "\(self)" }
	
}

#endif
