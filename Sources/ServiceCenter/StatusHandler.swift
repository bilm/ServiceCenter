//
//  StatusHandler.swift
//  
//
//  Created by Bil Moorhead on 2/24/22.
//

import Foundation

public protocol StatusHandler: Sendable {
	
	typealias Output		= ServiceCenter.Output
	typealias HTTPStatus	= ServiceCenter.HTTPStatus

	typealias Request		= ServiceCenter.ServiceRequest
		
	//
	//	INFO -	Do something appropriate for the status code.
	//			If necessary throw an error
	//
	//			The service request is passed along in case the 
	//			handler wants to know anything about the actual
	//			request, or even try it again.
	func handle(status: HTTPStatus, for request: Request, on center: ServiceCenter) async throws ->Output
	
}

open class EmptyStatusHandler: StatusHandler, @unchecked Sendable {
	
	public func handle(status: HTTPStatus, for request: Request, on center: ServiceCenter) async throws -> Output {
		
		throw status
		
	}
	
}
