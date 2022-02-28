//
//  URLCredential.swift
//  
//
//  Created by Bil Moorhead on 2/27/22.
//

import Foundation


extension URLCredential {
	
	public var basic: String? {
		
		guard let user = user, let password = password else { return nil }
		return "Basic \(Data("\(user):\(password)".utf8).base64EncodedString())"
		
	}
	public var bearer: String? { 
		
		password.flatMap { "Bearer \($0)" }
		
	}
	
}
