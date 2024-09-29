import Foundation

// Struct for decoding the athlete data
struct Athlete: Codable {
    let id: Int
    let resource_state: Int
}

// Struct for decoding the map data
struct ActivityMap: Codable {
    let id: String
    let summary_polyline: String?
    let resource_state: Int
}

// Main Activity struct for decoding the activity data
struct Activity: Codable, Identifiable {
    let id: Int
    let name: String
    let distance: Double
    let moving_time: Int
    let elapsed_time: Int
    let total_elevation_gain: Double
    let type: String
    let sport_type: String
    let workout_type: Int?
    let start_date: String
    let start_date_local: String
    let timezone: String
    let utc_offset: Int
    let location_city: String?
    let location_state: String?
    let location_country: String?
    let achievement_count: Int
    let kudos_count: Int
    let comment_count: Int
    let athlete_count: Int
    let photo_count: Int
    let map: ActivityMap
    let trainer: Bool
    let commute: Bool
    let manual: Bool
    let private_activity: Bool
    let visibility: String
    let flagged: Bool
    let gear_id: String?
    let start_latlng: [Double]?
    let end_latlng: [Double]?
    let average_speed: Double
    let max_speed: Double
    let average_cadence: Double?
    let has_heartrate: Bool
    let average_heartrate: Double?
    let max_heartrate: Double?
    let elev_high: Double?
    let elev_low: Double?
    let upload_id: Int
    let upload_id_str: String
    let external_id: String
    let from_accepted_tag: Bool
    let pr_count: Int
    let total_photo_count: Int
    let has_kudoed: Bool
    let recommendations: [String] // Added recommendations

    enum CodingKeys: String, CodingKey {
        case id, name, distance, moving_time, elapsed_time, total_elevation_gain, type, sport_type, workout_type, start_date, start_date_local, timezone, utc_offset, location_city, location_state, location_country, achievement_count, kudos_count, comment_count, athlete_count, photo_count, map, trainer, commute, manual, private_activity = "private", visibility, flagged, gear_id, start_latlng, end_latlng, average_speed, max_speed, average_cadence, has_heartrate, average_heartrate, max_heartrate, elev_high, elev_low, upload_id, upload_id_str, external_id, from_accepted_tag, pr_count, total_photo_count, has_kudoed, recommendations // Fixed here
    }
}
