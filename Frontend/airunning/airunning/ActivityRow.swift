import SwiftUI


struct ActivityRow: View {
    var activity: Activity
    @State private var isExpanded: Bool = false // State to track if the row is expanded

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User Information Header
            HStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.orange)

                

                Spacer()

                Text(formatDate(activity.start_date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

            // Activity Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "figure.run")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.orange)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .scaleEffect(isExpanded ? 1.1 : 1.0) // Scale effect on expansion
                        .animation(.easeInOut(duration: 0.3)) // Animation for scaling

                    VStack(alignment: .leading) {
                        Text(activity.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Type: \(activity.type)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Distance: \(String(format: "%.2f", activity.distance / 1000)) km")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 8)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle() // Toggle expansion on tap
                    }
                }

                if isExpanded {
                    // Recommendations section, shown on expansion
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommendations:")
                            .font(.headline)
                            .padding(.top)

                        ForEach(activity.recommendations, id: \.self) { recommendation in
                            Text("• \(recommendation)")
                                .font(.subheadline)
                                .padding(.leading, 10)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.leading, 56) // Align under the activity row
                    .padding(.bottom, 8)
                    .transition(.opacity) // Fade transition for recommendations
                }
            }
            .padding(.horizontal, 8)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.vertical, 8) // Vertical padding for each activity row
    }

    // Function to format the date string
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
