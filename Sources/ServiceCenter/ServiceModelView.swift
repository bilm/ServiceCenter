//
//  ServiceModelView.swift
//  Goth
//
//  Created by Bil Moorhead on 9/21/21.
//

import SwiftUI

public struct ServiceModelView: View {
	
	@Binding var serviceModel: ServiceModel?
	
	public var body: some View {
		
		ScrollView {
			
			Text("\(serviceModel?.alternative ?? "«»")")
				.font(.system(size: 18, weight: .regular, design: .monospaced))
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.leading, 24)
			
		}
		
    }
	
	public init(serviceModel: Binding<ServiceModel?>) {
		
		self._serviceModel = serviceModel
		
	}
	
}

struct ServiceModelView_Previews: PreviewProvider {
	
    static var previews: some View {
		
		ServiceModelView(serviceModel: .constant("ServiceModel"))
		.previewDisplayName("Single String")
		ServiceModelView(serviceModel: .constant(Data("ServiceModel".utf8)))
			.previewDisplayName("Single Data")
		ServiceModelView(serviceModel: .constant(["ServiceModel","ServiceModel"]))
			.previewDisplayName("Multiple Strings")

    }
	
}
