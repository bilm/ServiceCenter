//
//  DateFormatter.swift
//  
//
//  Created by Bil Moorhead on 1/23/22.
//

import Foundation

extension DateFormatter {
	
	public static let serviceCenterDateFormatter: DateFormatter = {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		
		return formatter
		
	}()

}
