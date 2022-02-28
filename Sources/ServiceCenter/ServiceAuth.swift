//
//  ServiceAuth.swift
//  
//
//  Created by Bil Moorhead on 10/11/21.
//

@preconcurrency import Foundation

public enum ServiceAuth : Sendable {
	
	public typealias Authorization = String
	
	case nothing
	case basic(URLCredential)
	case bearer(URLCredential)
	case absolute(String,String)
	
	//
	//	INFO -	This is what is expect by the HTTP 'Authorization' header field.
	//			Currently only Basic and Bearer are implicitly captured.
	//			
	public var authorization: Authorization? {
		
		switch self {
			
		case .nothing:							return nil
		case .basic(let credential):			return credential.basic
		case .bearer(let credential):			return credential.bearer
		case .absolute(let keyword, let token):	return "\(keyword) \(token)"

		}
		
	}
	
}
