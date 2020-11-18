//
//  GithubView.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import SwiftUI

struct EndpointListView: View {
	@EnvironmentObject var store: Store
	
	var endpointList: AppState.EndpointList { store.appState.endpointList }
	
    var body: some View {
		ScrollView {
			ForEach(endpointList.endpoints ?? []) { ep in
				EndpointRow(model: ep)

			}
		}
    }
}

struct EndpointListView_Previews: PreviewProvider {
    static var previews: some View {
		EndpointListView().environmentObject(Store.sample)
    }
}
