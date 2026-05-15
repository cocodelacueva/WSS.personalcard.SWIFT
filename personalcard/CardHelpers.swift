//
//  CardHelpers.swift
//  personalcard
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

// Claves usadas con @AppStorage (UserDefaults).
// Centralizadas para evitar typos en strings sueltos.
enum StorageKeys {
    static let company = "company"
    static let name    = "name"
    static let phone   = "phone"
    static let email   = "email"
    static let text    = "text"
    static let url     = "url"
    static let font    = "font"
}

// Las fuentes "raleway" y "openSans" requieren los .ttf bundleados en la app.
// Si no están registradas, SwiftUI cae a la fuente del sistema sin romper.
enum AppFont: String, CaseIterable, Identifiable {
    case system   = "Sistema"
    case raleway  = "Raleway"
    case openSans = "Open Sans"

    var id: String { rawValue }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight)
        case .raleway:
            return .custom(postscriptName(family: "Raleway", weight: weight), size: size)
        case .openSans:
            return .custom(postscriptName(family: "OpenSans", weight: weight), size: size)
        }
    }

    private func postscriptName(family: String, weight: Font.Weight) -> String {
        let suffix: String
        switch weight {
        case .bold:     suffix = "Bold"
        case .semibold: suffix = "SemiBold"
        case .medium:   suffix = "Medium"
        default:        suffix = "Regular"
        }
        return "\(family)-\(suffix)"
    }
}

enum QRGenerator {
    private static let context = CIContext()
    private static let filter  = CIFilter.qrCodeGenerator()

    static func generate(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }

        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
