//
//  JSON.swift
//  
//
//  Created by Bil Moorhead on 1/11/21.
//

import Foundation
import DateFormats

final class JSON {
	
	static var encoder: JSONEncoder = {
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .formatted(.iso8601Full)
//		encoder.dataEncodingStrategy = .custom {
//			var container = $1.singleValueContainer()
//			try container.encode($0.hex)
//		}

		return encoder
		
	}()
	static var encoderNWK: JSONEncoder = {
		
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(.iso8601Full)

		return encoder
		
	}()
	
	
	//
	//
	//
	
	
	static var decoder: JSONDecoder = {
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.iso8601Full)
//		decoder.dataDecodingStrategy = .custom {
//			let containter = try $0.singleValueContainer()
//			let string = try containter.decode(String.self)
//			return Data(hexString: string)
//		}

		return decoder
		
	}()

	static var decoderNWK: JSONDecoder = {
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.iso8601Full)

		return decoder
		
	}()
	
}
