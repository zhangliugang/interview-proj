//
//  EndpointRow.swift
//  Interview-proj
//
//  Created by August on 11/17/20.
//

import SwiftUI

struct EndpointRow: View {
	let model: Endpoint
	
    var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(model.name ?? "")
				.font(.headline)
				.foregroundColor(.blue)
			Text(model.value ?? "")
				.font(.footnote)
				.lineLimit(nil)
		}.frame(maxWidth: .infinity, alignment: .leading)
		.padding(12)
    }
}

struct EndpointRow_Previews: PreviewProvider {
    static var previews: some View {
        EndpointRow(model: Endpoint(name: "authorizations_url", value: "https://api.github.com/authorizations"))
    }
}
