//
//  ContentView.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import SwiftUI

struct MainView: View {
	@EnvironmentObject var store: Store
	
	private var historyListBinding: Binding<AppState.HistroryList> {
		$store.appState.historieList
	}

	private var showError: Binding<Bool> {
		$store.appState.appInfo.showErrorView
	}
	
    var body: some View {
		NavigationView {
			EndpointRootView()
				.navigationBarTitle(Text("Github"), displayMode: .inline)
				.navigationBarItems(leading: progressView, trailing: Button("History", action: {
					store.dispatch(.showHistory)
				}))
		}
		.sheet(isPresented: historyListBinding.showHistoryPanel) {
			HistoryView().environmentObject(store)
		}
		.error(isShowing: showError)
		
    }
	
	
	
	@ViewBuilder
	var progressView: some View {
		if store.appState.endpointList.isLoading {
			ProgressView().foregroundColor(.black)
		} else {
			EmptyView()
		}
	}

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
		MainView().environmentObject(Store.sample)
    }
}
