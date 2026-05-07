import Foundation

struct ChartProfile: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var longitude: Double
    var gender: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        longitude: Double,
        gender: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.longitude = longitude
        self.gender = (gender == "F") ? "F" : "M"
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

final class ChartProfileStore {
    static let shared = ChartProfileStore()

    private enum Keys {
        static let profiles = "ziwei_chart_profiles_v1"
    }

    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "app.study.chart-profile-store")
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func load() -> [ChartProfile] {
        queue.sync {
            loadUnsafe().sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    func latest() -> ChartProfile? {
        load().first
    }

    func save(_ profile: ChartProfile) {
        queue.sync {
            var profiles = loadUnsafe()
            profiles.removeAll { $0.id == profile.id }
            profiles.insert(profile, at: 0)
            saveUnsafe(profiles)
        }
    }

    func clear() {
        queue.sync {
            defaults.removeObject(forKey: Keys.profiles)
        }
    }

    func remove(id: String) {
        queue.sync {
            var profiles = loadUnsafe()
            profiles.removeAll { $0.id == id }
            saveUnsafe(profiles)
        }
    }

    private func loadUnsafe() -> [ChartProfile] {
        guard let data = defaults.data(forKey: Keys.profiles) else {
            return []
        }
        return (try? decoder.decode([ChartProfile].self, from: data)) ?? []
    }

    private func saveUnsafe(_ profiles: [ChartProfile]) {
        guard let data = try? encoder.encode(profiles) else {
            return
        }
        defaults.set(data, forKey: Keys.profiles)
    }
}
