//
//  JSON.swift
//  
//
//  Created by Bil Moorhead on 1/11/21.
//

import Foundation

public final class ServiceCenterJSON {
	
	public static var encoder: JSONEncoder = {
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .formatted(.serviceCenterDateFormatter)

		return encoder
		
	}()
	
	public static var encoderNWK: JSONEncoder = {
		
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .formatted(.serviceCenterDateFormatter)

		return encoder
		
	}()
	
	public static var encoderHEX: JSONEncoder = {
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .formatted(.serviceCenterDateFormatter)
		encoder.dataEncodingStrategy = .custom {
			var container = $1.singleValueContainer()
			try container.encode($0.hex)
		}

		return encoder
		
	}()
	
	
	//
	//
	//
	
	
	public static var decoder: JSONDecoder = {
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.serviceCenterDateFormatter)

		return decoder
		
	}()

	public static var decoderNWK: JSONDecoder = {
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.serviceCenterDateFormatter)

		return decoder
		
	}()

	public static var decoderHEX: JSONDecoder = {
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.serviceCenterDateFormatter)
		decoder.dataDecodingStrategy = .custom {
			let containter = try $0.singleValueContainer()
			let string = try containter.decode(String.self)
			return Data(hexString: string)
		}

		return decoder
		
	}()
	
}
