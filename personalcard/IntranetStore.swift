//
//  IntranetStore.swift
//  personalcard
//
//  Created by coco on 08/06/2026.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class IntranetStore {
    var personas: [Persona] = []
    var entities: [Entity] = []
    var crm: [CRMLead] = []
    var lastSync: Date?
    var lastSyncFailed = false
    var isLoading = false
    var errorMessage: String?
    var hasKey = false
    var keyExpiredAlert = false
    
    private let client = SyncClient()
    
    init() { 
        loadCache()
        hasKey = KeychainStore.read(account: KeychainStore.apiKeyAccount) != nil
    }
    // Refresca solo si pasaron más de 24h (o nunca sincronizó).
    func refreshIfStale() async {
        let oneDay: TimeInterval = 24 * 60 * 60
        if let last = lastSync, Date().timeIntervalSince(last) < oneDay { return }
        await refresh()
    }
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            personas = try await client.personas()
            entities = try await client.entities()
            crm      = try await client.crm()
            lastSync = Date()
            lastSyncFailed = false
            
            saveCache()
            // TODO (Paso 11): Notifier.scheduleNextSteps(from: crm)
        } catch SyncError.noKey {
            errorMessage = "Pegá tu API key para sincronizar."
            
        } catch SyncError.unauthorized {
            errorMessage = "Tu acceso venció. Generá una key nueva en la intranet."
            KeychainStore.delete(account: KeychainStore.apiKeyAccount)
            hasKey = false
            keyExpiredAlert = true      // 👈 dispara el popup
            lastSyncFailed = true
            
        } catch {
            errorMessage = "No se pudo sincronizar (¿sin conexión?)."
            
            lastSyncFailed = true     // ⚠️ NO toco lastSync: queda la última buena
        }
    }
        
    private struct CachedData: Codable {
        var personas: [Persona]
        var entities: [Entity]
        var crm: [CRMLead]
        var lastSync: Date?
    }

    private var cacheURL: URL {
        let dir = URL.applicationSupportDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("contacts-cache.json")
    }

    func saveCache() {
        let snapshot = CachedData(personas: personas, entities: entities, crm: crm, lastSync: lastSync)
        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: cacheURL, options: .atomic)   // atomic = nunca queda a medias
        } catch {
            print("No se pudo guardar caché:", error)
        }
    }

    func loadCache() {
        guard let data = try? Data(contentsOf: cacheURL),
              let cached = try? JSONDecoder().decode(CachedData.self, from: data) else {
            return   // primera vez / no hay archivo: normal, no pasa nada
        }
        personas = cached.personas
        entities = cached.entities
        crm      = cached.crm
        lastSync = cached.lastSync
    }
}

extension IntranetStore {
    var lastSyncText: String {
        guard let last = lastSync else { return "Nunca sincronizado" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return "Actualizado " + f.localizedString(for: last, relativeTo: Date())
    }

    /// True si pasó más de ~25h del último sync exitoso (algo no anda).
    var isStale: Bool {
        guard let last = lastSync else { return true }
        return Date().timeIntervalSince(last) > 25 * 60 * 60
    }
}

//datos de mentira, solo en debug
#if DEBUG
extension IntranetStore {
    static var preview: IntranetStore {
        let store = IntranetStore()
        store.personas = Persona.samples
        store.entities = Entity.samples
        store.crm = CRMLead.samples
        return store
    }
}
#endif
