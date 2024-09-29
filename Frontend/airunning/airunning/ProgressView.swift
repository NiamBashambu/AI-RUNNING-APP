//
//  ProgressView.swift
//  airunning
//
//  Created by Niam Bashambu on 9/28/24.
//
import SwiftUI

struct ProgressView: View {
    var body: some View {
        VStack {
            // Initialize ProgressView with no arguments
            SwiftUI.ProgressView("Fetching Activities") // Display a loading message
                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                .scaleEffect(1.5)
                .padding()
        }
        .background(Color(UIColor.systemBackground).opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .previewLayout(.sizeThatFits) // Preview the layout
    }
}
