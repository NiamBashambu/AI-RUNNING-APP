//
//  AboutView.swift
//  airunning
//
//  Created by Niam Bashambu on 9/28/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About OptiRun")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)

            Text("Welcome to OptiRun!")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 10)

            Divider() // Adds a divider for separation

            // Bullet point list for better readability
            VStack(alignment: .leading, spacing: 5) {
                Text("• Connect your Strava account")
                Text("• Fetch your running activities")
                Text("• Receive personalized tips and recommendations")
                Text("• Explore your running metrics")
                Text("• Enhance your performance and take your training to the next level")
            }
            .font(.body)
            .padding(.bottom, 20)
            .padding(.horizontal) // Add horizontal padding for bullet points

            Divider() // Another divider

            // Centering the logo
            HStack {
                Spacer()
                Image("your_logo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle()) // Make the logo circular
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 5) // Add shadow to the logo
                Spacer()
            }
            .padding(.bottom, 20)

            Text("Created by Niam Bashambu")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)

            Spacer()
        }
        .padding(20) // Consistent padding around the entire view
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12) // Adds rounded corners to the background
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5) // Adds subtle shadow for depth
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
