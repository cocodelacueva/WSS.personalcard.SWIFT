//
//  SyncAPI.swift
//  personalcard
//
//  Created by coco on 08/06/2026.
//

import Foundation

enum SyncError: Error {
    case noKey
    case unauthorized     // 401
    case server(Int)
    case decoding(Error)
}

enum SyncAPI {
    // Simulador: localhost = tu Mac. iPhone físico: la IP de tu Mac en la WiFi.
    static let baseURL = URL(string: "https://intranetapi.whitesuit.studio")!
    //static let baseURL = URL(string: "http://intranetapi.wss.local")!
    //static let baseURL = URL(string: "http://localhost:8080")!
}

struct SyncClient {
    func getList<T: Decodable>(_ path: String, of type: T.Type) async throws -> [T] {
        guard let key = KeychainStore.read(account: KeychainStore.apiKeyAccount) else {
            throw SyncError.noKey
        }
        var request = URLRequest(url: SyncAPI.baseURL.appendingPathComponent(path))
        request.setValue(key, forHTTPHeaderField: "X-API-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else { throw SyncError.server(0) }
        if http.statusCode == 401 { throw SyncError.unauthorized }
        guard (200..<300).contains(http.statusCode) else { throw SyncError.server(http.statusCode) }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Paginated<T>.self, from: data).data
        } catch {
            print("DECODE:", error)
            throw SyncError.decoding(error)
        }
    }
}

extension SyncClient {
    func crm() async throws -> [CRMLead] {
        try await getList("/api/sync/crm", of: CRMLead.self)
    }
    func personas() async throws -> [Persona] {
        try await getList("/api/sync/personas", of: Persona.self)
    }
    
    func entities() async throws -> [Entity] {
        try await getList("/api/sync/entities", of: Entity.self)
    }
    
}
