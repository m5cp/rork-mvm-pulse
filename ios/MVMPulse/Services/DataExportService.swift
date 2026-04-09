import Foundation
import UniformTypeIdentifiers

nonisolated struct ExportableData: Codable, Sendable {
    let version: String
    let exportDate: Date
    let userProfile: UserProfile
    let assessmentResults: [AssessmentResult]
    let roadmap: Roadmap
    let streakData: StreakData
}

struct DataExportService {
    static func exportData(from storage: StorageService) -> Data? {
        let exportable = ExportableData(
            version: "1.0",
            exportDate: Date(),
            userProfile: storage.userProfile,
            assessmentResults: storage.assessmentResults,
            roadmap: storage.roadmap,
            streakData: storage.streakData
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(exportable)
    }

    static func importData(_ data: Data, into storage: StorageService) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let imported = try? decoder.decode(ExportableData.self, from: data) else {
            return false
        }
        storage.userProfile = imported.userProfile
        storage.assessmentResults = imported.assessmentResults
        storage.roadmap = imported.roadmap
        storage.streakData = imported.streakData
        return true
    }
}
