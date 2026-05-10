import Foundation
import AppKit

extension AnalysisLogic {
    var windowsFallbackSymbolName: String {
        if #available(macOS 11.0, *), NSImage(systemSymbolName: "pc", accessibilityDescription: nil) != nil {
            return "pc"
        }
        return "desktopcomputer"
    }

    func resetWindowsDetectionState() {
        self.isWindowsDetected = false
        self.windowsFamily = nil
        self.windowsServicePack = nil
        self.windowsArchitecture = nil
        self.isWindowsARM = false
        self.windowsHasEFI = false
    }

    func applyWindowsDetectionResult(_ result: WindowsDetectionResult, sourceURL: URL) {
        self.isWindowsDetected = true
        self.windowsFamily = result.family
        self.windowsServicePack = result.servicePack
        self.windowsArchitecture = result.arch
        self.isWindowsARM = result.isARM
        self.windowsHasEFI = result.efiStatus.hasEFI

        self.recognizedVersion = result.displayName
        self.sourceAppURL = nil
        self.detectedSystemIcon = nil

        self.needsCodesign = true
        self.isLegacyDetected = false
        self.isRestoreLegacy = false
        self.isCatalina = false
        self.isSierra = false
        self.isMavericks = false
        self.isUnsupportedSierra = false
        self.isPPC = false
        self.legacyArchInfo = nil
        self.userSkippedAnalysis = false
        self.requiredUSBCapacityGB = nil

        if result.isSupported {
            self.isSystemDetected = true
            self.showUnsupportedMessage = false
            self.showUSBSection = false
        } else {
            self.isSystemDetected = false
            self.showUnsupportedMessage = true
            self.showUSBSection = false
        }

        self.log("Rozpoznano obraz Windows: \(result.displayName)")
        self.log("Windows support gate: supported=\(result.isSupported ? "TAK" : "NIE"), reason=\(result.supportReason.rawValue), hasEFI=\(result.efiStatus.hasEFI ? "TAK" : "NIE")")
        self.log("Windows source file: \(sourceURL.path)")
        AppLogging.separator()
    }
}
