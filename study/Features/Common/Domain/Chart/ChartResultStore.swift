import Foundation

struct ChartResultSnapshot: Codable, Identifiable, Hashable {
    let id: String
    let profileId: String
    let chartJSON: String
    let computedAt: Date
    let engineVersion: String

    init(
        id: String = UUID().uuidString,
        profileId: String,
        chartJSON: String,
        computedAt: Date = Date(),
        engineVersion: String = "jing-js-v1"
    ) {
        self.id = id
        self.profileId = profileId
        self.chartJSON = chartJSON
        self.computedAt = computedAt
        self.engineVersion = engineVersion
    }
}

final class ChartResultStore {
    static let shared = ChartResultStore()

    private enum Keys {
        static let snapshots = "ziwei_chart_results_v1"
    }

    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "app.study.chart-result-store")
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

    func load() -> [ChartResultSnapshot] {
        queue.sync {
            loadUnsafe().sorted { $0.computedAt > $1.computedAt }
        }
    }

    func latest() -> ChartResultSnapshot? {
        load().first
    }

    func latest(for profileId: String) -> ChartResultSnapshot? {
        load().first(where: { $0.profileId == profileId })
    }

    func save(_ snapshot: ChartResultSnapshot) {
        queue.sync {
            var items = loadUnsafe()
            items.removeAll { $0.id == snapshot.id }
            items.insert(snapshot, at: 0)
            saveUnsafe(items)
        }
    }

    func saveLatest(profileId: String, chartJSON: String, engineVersion: String = "jing-js-v1") {
        queue.sync {
            var items = loadUnsafe()
            items.removeAll { $0.profileId == profileId }
            items.insert(
                ChartResultSnapshot(
                    profileId: profileId,
                    chartJSON: chartJSON,
                    computedAt: Date(),
                    engineVersion: engineVersion
                ),
                at: 0
            )
            saveUnsafe(items)
        }
    }

    func clear() {
        queue.sync {
            defaults.removeObject(forKey: Keys.snapshots)
        }
    }

    func remove(profileId: String) {
        queue.sync {
            var items = loadUnsafe()
            items.removeAll { $0.profileId == profileId }
            saveUnsafe(items)
        }
    }

    private func loadUnsafe() -> [ChartResultSnapshot] {
        guard let data = defaults.data(forKey: Keys.snapshots) else {
            return []
        }
        return (try? decoder.decode([ChartResultSnapshot].self, from: data)) ?? []
    }

    private func saveUnsafe(_ items: [ChartResultSnapshot]) {
        guard let data = try? encoder.encode(items) else {
            return
        }
        defaults.set(data, forKey: Keys.snapshots)
    }
}
