//
//  ServiceState.swift
//  Goth
//
//  Created by Bil Moorhead on 9/25/21.
//

import Foundation
import Logger

public protocol ServiceState: Sendable {
	
	var version: String { get set }
	var logger: Logger? { get set }
	
}

open class EmptyServiceState: ServiceState, @unchecked Sendable {
	
	public var version = "0.0.0"
	public var logger: Logger? = nil
	
	public init() {}
	
}
