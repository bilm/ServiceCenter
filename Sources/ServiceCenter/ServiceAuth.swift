//
//  ServiceAuth.swift
//  
//
//  Created by Bil Moorhead on 10/11/21.
//

@preconcurrency import Foundation

public enum ServiceAuth : Sendable {
	
	case nothing
	case basic(URLCredential)
	case bearer(URLCredential)
	case absolute(String,String)
	
	public var authorization: String? {
		
		switch self {
			
		case .nothing:							return nil
		case .basic(let credential):			return credential.basic
		case .bearer(let credential):			return credential.bearer
		case .absolute(let keyword, let token):	return "\(keyword) \(token)"

		}
		
	}
	
	public static var superuser: ServiceAuth { .basic(.superuser) }
	
}

extension URLCredential {
	
	public static var superuser: URLCredential {
		
		URLCredential(
			user: "superuser",
			password: "5up3ru53r",
			persistence: .forSession)
		
	}

}

extension URLCredential {
	
	public var basic: String? {
		
		guard let user = user, let password = password else { return nil }
		return "Basic \(Data("\(user):\(password)".utf8).base64EncodedString())"
		
	}
	public var bearer: String? { 
		
		password.flatMap { "Bearer \($0)" }
		
	}
	
}
