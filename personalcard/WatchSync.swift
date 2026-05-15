//
//  WatchSync.swift
//  personalcard (compartido con personalcard Watchkitapp Watch App)
//
//  Sincroniza los datos entre el iPhone y el Watch via WatchConnectivity.
//  - El iPhone llama a `push()` cuando cambia algo y manda todo via updateApplicationContext.
//  - El Watch recibe el diccionario en el delegado y lo escribe en SharedStorage.defaults.
//  - Los @AppStorage de cada lado observan UserDefaults y refrescan las vistas.
//

import Foundation
import WatchConnectivity

final class WatchSync: NSObject, WCSessionDelegate {
    static let shared = WatchSync()

    private let session: WCSession?

    private override init() {
        self.session = WCSession.isSupported() ? WCSession.default : nil
        super.init()
        session?.delegate = self
        session?.activate()
    }

    // Envía el snapshot actual al otro lado. updateApplicationContext sobrescribe el
    // anterior — el receptor siempre obtiene el último estado, sin cola.
    func push() {
        guard let session, session.activationState == .activated else { return }
        try? session.updateApplicationContext(currentContext())
    }

    private func currentContext() -> [String: Any] {
        let d = SharedStorage.defaults
        var ctx: [String: Any] = [
            StorageKeys.company: d.string(forKey: StorageKeys.company) ?? "",
            StorageKeys.name:    d.string(forKey: StorageKeys.name)    ?? "",
            StorageKeys.phone:   d.string(forKey: StorageKeys.phone)   ?? "",
            StorageKeys.email:   d.string(forKey: StorageKeys.email)   ?? "",
            StorageKeys.text:    d.string(forKey: StorageKeys.text)    ?? "",
            StorageKeys.url:     d.string(forKey: StorageKeys.url)     ?? "",
            StorageKeys.font:    d.string(forKey: StorageKeys.font)    ?? AppFont.system.rawValue
        ]
        if let qr = d.data(forKey: StorageKeys.qrImageData) {
            ctx[StorageKeys.qrImageData] = qr
        }
        return ctx
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let d = SharedStorage.defaults
        for (key, value) in applicationContext {
            d.set(value, forKey: key)
        }
    }

    // Estos dos métodos son obligatorios solo en iOS — el Watch no los necesita.
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        // El usuario cambió de Watch — reactivar para el nuevo.
        session.activate()
    }
    #endif
}
