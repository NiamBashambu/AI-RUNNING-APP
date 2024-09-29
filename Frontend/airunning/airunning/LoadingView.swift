//
//  LoadingView.swift
//  airunning
//
//  Created by Niam Bashambu on 9/28/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            VStack {
                Image("your_logo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle()) // Make the logo circular
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 5) // Add shadow to the logo
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
