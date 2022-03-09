//
//  ServiceCurator.swift
//  
//
//  Created by Bil Moorhead on 2/27/22.
//

import Foundation

public protocol ServiceCurator: Sendable {
	
	typealias Authorization = ServiceAuth.Authorization
	
	var serviceAuth: ServiceAuth { get set }
	func update(serviceAuth: ServiceAuth)

	//
	//	INFO -	This is what is expect by the HTTP 'Authorization' header field.
	//			
	var authorization: Authorization? { get }
	
	//
	//
	//
	
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

public final class BasicCurator: ServiceCurator, @unchecked Sendable {
	
	public var serviceAuth: ServiceAuth
	public func update(serviceAuth: ServiceAuth) { self.serviceAuth = serviceAuth }
	
	public init(serviceAuth: ServiceAuth = .nothing) {
		
		self.serviceAuth = serviceAuth
		
	}
	
	public var authorization: Authorization? { serviceAuth.authorization }
	
	//
	//
	//
	
	public func handle(status: HTTPStatus, for request: Request, on center: ServiceCenter) async throws -> Output {
		
		switch status {
		case .ok(_, let output):	return output
		default:					throw status
		}
		
	}

}
