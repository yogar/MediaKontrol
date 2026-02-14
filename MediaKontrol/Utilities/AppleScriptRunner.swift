import Foundation

actor AppleScriptRunner {
    enum Error: Swift.Error, LocalizedError {
        case executionFailed(String)
        case processError(Int32)

        var errorDescription: String? {
            switch self {
            case .executionFailed(let message):
                return "AppleScript execution failed: \(message)"
            case .processError(let code):
                return "osascript exited with code \(code)"
            }
        }
    }

    @discardableResult
    func run(_ script: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", script]

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            process.terminationHandler = { _ in
                let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

                let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if process.terminationStatus != 0 {
                    continuation.resume(throwing: Error.executionFailed(errorOutput.isEmpty ? "Unknown error" : errorOutput))
                } else {
                    continuation.resume(returning: output)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
