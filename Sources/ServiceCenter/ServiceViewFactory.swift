//
//  ServiceViewFactory.swift
//  Goth
//
//  Created by Bil Moorhead on 9/21/21.
//

import SwiftUI

public protocol ServiceViewFactory {
	
	associatedtype ServiceView: View
	
	@ViewBuilder func view<Model>(for service: Service, model: Model) ->Self.ServiceView

}
