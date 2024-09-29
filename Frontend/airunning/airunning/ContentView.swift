import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var authSession: ASWebAuthenticationSession? // Authentication session for web-based OAuth
    @State private var isAuthenticated = false
    @State private var activities: [Activity] = []
    @State private var resultMessage: String = ""
    @State private var showAlert = false
    @State private var isLoading = true // Loading state for the initial view

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .transition(.opacity) // Add opacity transition for fade-in/fade-out effect
            } else {
                TabView {
                    NavigationView {
                        VStack {
                            Text("OptiRun")
                                .font(.largeTitle)
                                .bold()
                                .padding(.top, 20)

                            Text("Connect to your Strava account and start exploring your activities.")
                                .font(.headline)
                                .padding()

                            Button(action: {
                                authenticateWithBackend() // Trigger authentication
                            }) {
                                Text("Authenticate with Strava")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 70)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)

                            Spacer() // Spacer to center the button

                            // Show result message if exists
                            if !resultMessage.isEmpty {
                                Text(resultMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(resultMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                    DataView(activities: $activities) // Pass activities binding
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Data")
                        }

                    AboutView() // About view tab
                        .tabItem {
                            Image(systemName: "info.circle")
                            Text("About")
                        }
                }
                .background(Color(UIColor.systemBackground))
                .transition(.opacity) // Smooth transition from loading to main view
            }
        }
        .animation(.easeInOut(duration: 1.0)) // Smooth fade-in/fade-out animation
        .onAppear {
            // Simulate a loading delay of 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
        }
    }

    // Authenticate with Strava via the backend
    func authenticateWithBackend() {
        // Construct the URL for your backend's Strava auth route
        guard let backendAuthURL = URL(string: "http://localhost:2000/auth/strava") else {
            DispatchQueue.main.async {
                resultMessage = "Invalid backend authentication URL"
                showAlert = true
            }
            return
        }

        print("Attempting to authenticate with backend URL: \(backendAuthURL)") // Log the URL

        // Start the authentication session
        authSession = ASWebAuthenticationSession(url: backendAuthURL, callbackURLScheme: "airunning") { callbackURL, error in
            if let error = error {
                print("Authentication session error: \(error.localizedDescription)") // Log error
                resultMessage = "Authentication failed: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let callbackURL = callbackURL else {
                resultMessage = "Callback URL was not received."
                showAlert = true
                return
            }
            
            // Handle the callback from the backend
            handleAuthCallback(url: callbackURL)
        }

        authSession?.start()
    }

    // Handle the callback after authentication
    func handleAuthCallback(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let code = queryItems.first(where: { $0.name == "code" })?.value {
            print("Authentication code: \(code)")
            exchangeCodeForTokens(code: code) // Call function to exchange code for tokens
        } else {
            resultMessage = "Failed to extract authentication code."
            showAlert = true
        }
    }

    // Exchange the code for tokens via your backend
    func exchangeCodeForTokens(code: String) {
        NetworkManager.shared.exchangeCodeForTokens(code: code) { error in
            if let error = error {
                DispatchQueue.main.async {
                    resultMessage = error.localizedDescription
                    showAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    fetchActivities() // Fetch activities after successful token exchange
                }
            }
        }
    }

    // Fetch activities from your backend after authentication
    func fetchActivities() {
        NetworkManager.shared.fetchActivities { activities, error in
            if let error = error {
                DispatchQueue.main.async {
                    resultMessage = "Error fetching activities: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            DispatchQueue.main.async {
                if let activities = activities {
                    self.activities = activities
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
