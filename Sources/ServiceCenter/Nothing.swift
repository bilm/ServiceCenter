//
//  Nothing.swift
//  
//
//  Created by Bil Moorhead on 12/25/19.
//  Copyright © 2019 Bil Moorhead. All rights reserved.
//

import Foundation

public struct Nothing: Codable, Error {

	///	This represents a Okay (200) HTTP return with no Body
	///	This represents a Error (400 or 500) HTTP return we are ignoring the Body
	
	public init() {}
}
