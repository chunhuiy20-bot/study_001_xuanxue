import Foundation

struct AkashicRecord: Codable, Identifiable, Hashable {
    struct HexSnapshot: Codable, Hashable {
        let index: Int
        let name: String
        let displayName: String
        let lines: [Bool]
        let symbol: String
    }

    let id: String
    let createdAt: Date
    let status: String
    let question: String
    let verdict: String
    let originalHexagram: HexSnapshot
    let changedHexagram: HexSnapshot
    let movingLineIndex: Int

    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        status: String = "已解",
        question: String,
        verdict: String,
        originalHexagram: HexSnapshot,
        changedHexagram: HexSnapshot,
        movingLineIndex: Int
    ) {
        self.id = id
        self.createdAt = createdAt
        self.status = status
        self.question = question
        self.verdict = verdict
        self.originalHexagram = originalHexagram
        self.changedHexagram = changedHexagram
        self.movingLineIndex = movingLineIndex
    }

    static func make(from session: OracleSession, question: String, verdict: String) -> AkashicRecord {
        AkashicRecord(
            question: question,
            verdict: verdict,
            originalHexagram: .init(
                index: session.originalHexagram.index,
                name: session.originalHexagram.name,
                displayName: session.originalHexagram.displayName,
                lines: session.originalLines,
                symbol: Self.hexagramSymbol(for: session.originalHexagram.index)
            ),
            changedHexagram: .init(
                index: session.changedHexagram.index,
                name: session.changedHexagram.name,
                displayName: session.changedHexagram.displayName,
                lines: session.changedLines,
                symbol: Self.hexagramSymbol(for: session.changedHexagram.index)
            ),
            movingLineIndex: session.movingLineIndex
        )
    }

    private static func hexagramSymbol(for index: Int) -> String {
        guard (1...64).contains(index), let scalar = UnicodeScalar(0x4DC0 + index - 1) else {
            return "䷿"
        }
        return String(scalar)
    }
}

final class AkashicRecordStore {
    static let shared = AkashicRecordStore()

    private enum Keys {
        static let records = "akashic_records_v1"
    }

    private let defaults: UserDefaults
    private let maxCount: Int
    private let queue = DispatchQueue(label: "app.study.akashic-record-store")
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard, maxCount: Int = 64) {
        self.defaults = defaults
        self.maxCount = maxCount

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func load() -> [AkashicRecord] {
        queue.sync {
            guard let data = defaults.data(forKey: Keys.records) else {
                return []
            }
            guard let records = try? decoder.decode([AkashicRecord].self, from: data) else {
                return []
            }
            return records
        }
    }

    func append(_ record: AkashicRecord) {
        queue.sync {
            var records = loadUnsafe()
            records.removeAll { $0.id == record.id }
            records.insert(record, at: 0)
            if records.count > maxCount {
                records = Array(records.prefix(maxCount))
            }
            saveUnsafe(records)
        }
    }

    func remove(id: String) {
        queue.sync {
            var records = loadUnsafe()
            records.removeAll { $0.id == id }
            saveUnsafe(records)
        }
    }

    func clear() {
        queue.sync {
            defaults.removeObject(forKey: Keys.records)
        }
    }

    private func loadUnsafe() -> [AkashicRecord] {
        guard let data = defaults.data(forKey: Keys.records) else {
            return []
        }
        return (try? decoder.decode([AkashicRecord].self, from: data)) ?? []
    }

    private func saveUnsafe(_ records: [AkashicRecord]) {
        guard let data = try? encoder.encode(records) else {
            return
        }
        defaults.set(data, forKey: Keys.records)
    }
}
