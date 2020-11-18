//
//  ErrorView.swift
//  Interview-proj
//
//  Created by August on 11/18/20.
//

import SwiftUI


extension View {

	func error(isShowing: Binding<Bool>) -> some View {
		ErrorView(isShowing: isShowing, presenting: { self })
	}

}


struct ErrorView<Presenting>: View where Presenting: View {
	@EnvironmentObject var store: Store
	@Binding var isShowing: Bool
	let presenting: () -> Presenting
	
	
    var body: some View {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			store.dispatch(.dismissError)
		}
		
		return GeometryReader { geometry in
			ZStack(alignment: .bottom) {
				self.presenting()
				
				ZStack {
					Text(store.appState.appInfo.appError?.description() ?? "")
						.font(.title2)
						.foregroundColor(.white)
						.padding()
				}
				.frame(width: geometry.size.width / 2, height: geometry.size.height / 10)
				.background(
					RoundedRectangle(cornerRadius: 20)
							.fill(Color.purple)
				)
				.opacity(self.isShowing ? 1 : 0)

			}
			.padding(.bottom)
		}
    }
}

//struct ErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//		ErrorView(isShowing: Bind, error: .databaseError)
//    }
//}
