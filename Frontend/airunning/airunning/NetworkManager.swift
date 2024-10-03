import Foundation

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance

    private init() {}

    // Perform a request to authenticate with Strava
    func authenticateWithStrava(completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "https://optirun.onrender.com/auth/strava") else {
            completion(nil, NSError(domain: "NetworkManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid authentication URL"]))
            return
        }

        // Perform the authentication request
        // Here we simply return the URL to be opened, since ASWebAuthenticationSession handles it
        completion(url.absoluteString, nil)
    }

    // Exchange authorization code for tokens
    func exchangeCodeForTokens(code: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "https://optirun.onrender.com/auth/callback") else {
            completion(NSError(domain: "NetworkManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid callback URL"]))
            return
        }

        URLSession.shared.dataTask(with: url) { _, _, error in
            completion(error)
        }.resume()
    }

    // Fetch activities from the backend
    func fetchActivities(completion: @escaping ([Activity]?, Error?) -> Void) {
        guard let url = URL(string: "https://optirun.onrender.com/activities") else {
            completion(nil, NSError(domain: "NetworkManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid activities URL"]))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "NetworkManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let activities = try JSONDecoder().decode([Activity].self, from: data)
                completion(activities, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
