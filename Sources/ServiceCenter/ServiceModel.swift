//
//  ServiceModel.swift
//  Goth
//
//  Created by Bil Moorhead on 9/19/21.
//

import Foundation

public protocol ServiceModel: Sendable {
	
	var alternative: String { get }
	
}

public typealias CodableServiceModel = ServiceModel & Codable

//


extension Array: ServiceModel where Element: ServiceModel {
	
	public var alternative: String { map { $0.alternative }.joined(separator: "\n") }
	
}
extension Data: ServiceModel {
	
	public var alternative: String { String(data: self, encoding: .utf8) ?? self.hex }
	
}
extension String: ServiceModel {
	
	public var alternative: String { self }
	
}

//
//
//

// MARK: -	Miscellany

#if os(iOS)

// MARK: -	UIKit

import class UIKit.UIImage

extension UIImage: ServiceModel {
	
	public var alternative: String { "\(self)" }
	
}

#elseif os(macOS)

// MARK: -	AppKit

import class AppKit.NSImage

extension NSImage: ServiceModel {
	
	public var alternative: String { "\(self)" }
	
}

#endif
