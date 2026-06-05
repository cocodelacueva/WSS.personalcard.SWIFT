//
//  CardHelpers.swift
//  personalcard
//

import SwiftUI
import UIKit

// App Group compartido entre el target de iPhone y el de Watch.
// Para que realmente se compartan los datos, hay que activar la capability
// "App Groups" en AMBOS targets con este mismo identificador.
// Si todavía no está configurado, cae a UserDefaults.standard sin romper.
enum SharedStorage {
    static let appGroupID = "group.com.whitesuit.personalcard"

    static let defaults: UserDefaults = {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }()
}

// Claves usadas con @AppStorage (UserDefaults).
// Centralizadas para evitar typos en strings sueltos.
enum StorageKeys {
    static let company     = "company"
    static let name        = "name"
    static let phone       = "phone"
    static let email       = "email"
    static let text        = "text"
    static let url         = "url"
    static let font        = "font"
    static let notes       = "notes"
    static let qrImageData = "qrImageData" // PNG bytes del QR — el iPhone lo genera, el Watch lo lee.
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

// QRGenerator solo existe en iOS: watchOS no incluye CoreImage en su SDK.
// El Watch lee el PNG ya generado desde el suite compartido.
#if canImport(CoreImage)
import CoreImage

enum QRGenerator {
    private static let context = CIContext()

    static func generate(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M",               forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // Genera el QR y persiste el PNG en el suite compartido.
    // Llamar solo cuando cambia la URL — no en cada render.
    static func regenerateAndStore(from string: String) {
        if let image = generate(from: string), let data = image.pngData() {
            SharedStorage.defaults.set(data, forKey: StorageKeys.qrImageData)
        } else {
            SharedStorage.defaults.removeObject(forKey: StorageKeys.qrImageData)
        }
    }
}
#endif
