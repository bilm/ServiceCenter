//
//  ServiceState.swift
//  Goth
//
//  Created by Bil Moorhead on 9/25/21.
//

import Foundation

public protocol ServiceState {
	
	var version: String { get set }
	
}

open class EmptyServiceState: ServiceState {
	
	public var version = "0.0.0"
	
	public init() {}
	
}
