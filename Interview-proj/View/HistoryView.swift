//
//  HistoryView.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import SwiftUI

struct HistoryView: View {
	
	@EnvironmentObject var store: Store
	
	var historyList: AppState.HistroryList { store.appState.historieList }

    var body: some View {
		NavigationView {
			ScrollView {
				ForEach(historyList.histories ?? []) { history in
					HStack(alignment: .center, spacing: 8) {
						Text(history.date!.description)
							.font(.headline)
						Spacer()
						Image(systemName: history.success ? "checkmark.circle" : "xamrk.circle")
					}
					.frame(height: 30)
					.padding(.leading, 12)
					.padding(.trailing, 12)
				}
				
			}
			.navigationBarTitle("History")
			.navigationBarItems(trailing: Button("Done", action: {
				store.dispatch(.closeHistory)
			}))
			.onAppear {
				store.dispatch(.loadHistory)
			}
			.onDisappear {
				self.store.appState.historieList.showHistoryPanel = false
			}
		}
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
		HistoryView().environmentObject(Store.sample)
    }
}
