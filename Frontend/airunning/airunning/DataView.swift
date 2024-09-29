import SwiftUI

struct DataView: View {
    @Binding var activities: [Activity] // Binding to receive activities from ContentView

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(activities) { activity in
                        ActivityRow(activity: activity)
                            .transition(.slide) // Transition for sliding effect
                            .animation(.easeIn(duration: 0.3)) // Smooth appearance animation
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 8)
            }
            .navigationTitle("Your Activity")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground)) // Instagram-like background color
        }
    }
}
