//
//  EndpointRootView.swift
//  Interview-proj
//
//  Created by August on 11/18/20.
//

import SwiftUI

struct EndpointRootView: View {
	
	@EnvironmentObject var store: Store
	
    var body: some View {
		if store.appState.endpointList.endpoints == nil {
			Image(systemName: "cube.box.fill")
				.resizable()
				.foregroundColor(.blue)
				.frame(width: 60.0, height: 60)
				.onAppear {
				self.store.dispatch(.loadEndpoint)
			}
		} else {
			EndpointListView()

		}
		
    }
}

struct EndpointRootView_Previews: PreviewProvider {
    static var previews: some View {
		EndpointRootView().environmentObject(Store())
    }
}
