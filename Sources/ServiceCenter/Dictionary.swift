//
//  Dictionary.swift
//  Goth
//
//  Created by Bil Moorhead on 9/25/21.
//

import Foundation

extension Dictionary where Key == String, Value == String {
	
	public func subIn(string: String) ->String { 
		
		reduce(string) {
			
			$0.replacingOccurrences(of: $1.0, with: $1.1)
			
		}
		
	}
	
}
extension Dictionary where Key == String {
	
	public var queryItems: [URLQueryItem] {
		
		map { 
			
			URLQueryItem(
				name: $0.0,
				value: String(describing:$0.1)
			)
			
		}
		
	}
	
}
