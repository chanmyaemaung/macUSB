import Foundation

struct WindowsToolchainPresence {
    let hasHomebrew: Bool
    let hasWimlib: Bool
    let homebrewPath: String?
    let wimlibPath: String?
}

extension AnalysisLogic {
    func detectWindowsToolchainPresence() -> WindowsToolchainPresence {
        let homebrewPath = resolveExecutablePathForWindowsAnalysis(named: "brew")
        let wimlibPath = resolveExecutablePathForWindowsAnalysis(named: "wimlib-imagex")

        return WindowsToolchainPresence(
            hasHomebrew: homebrewPath != nil,
            hasWimlib: wimlibPath != nil,
            homebrewPath: homebrewPath,
            wimlibPath: wimlibPath
        )
    }

    private func resolveExecutablePathForWindowsAnalysis(named executable: String) -> String? {
        let fm = FileManager.default
        let fixedSearchRoots = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/opt/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]

        for root in fixedSearchRoots {
            let candidate = URL(fileURLWithPath: root).appendingPathComponent(executable).path
            if fm.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }

        if let pathEnv = ProcessInfo.processInfo.environment["PATH"], !pathEnv.isEmpty {
            for root in pathEnv.split(separator: ":").map(String.init) {
                let candidate = URL(fileURLWithPath: root).appendingPathComponent(executable).path
                if fm.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [executable]
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return nil
        }

        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            return nil
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty else {
            return nil
        }

        return output
    }
}
