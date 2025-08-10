import CoreGraphics

struct ExportPackage: Codable { let version: Int; let habits: [Habit]; let logs: [HabitLog] }

enum QRCodeServiceError: Error { case notImplemented }

enum QRCodeService {
    static func encode(_ package: ExportPackage) throws -> CGImage { throw QRCodeServiceError.notImplemented }
    static func decode(_ image: CGImage) throws -> ExportPackage { throw QRCodeServiceError.notImplemented }
}
