//
//  SyncModels.swift
//  personalcard
//
//  Created by coco on 08/06/2026.
//

import Foundation

struct Paginated<T: Decodable>: Decodable {
    let data: [T]
}

struct CRMLead: Codable, Identifiable {
    let id: Int
    let personaName: String?
    let entityName: String?
    let stageName: String?
    let nextStep: String?
    let nextStepDate: String?    // "yyyy-MM-dd" — lo dejamos String por ahora
    let estimatedValue: String?
    let currency: String?
    let lastActivityDate: String?
    let firstActivityDate: String?
    let interestLevel: String?
}

extension CRMLead {
    private static let isoFormatter = ISO8601DateFormatter()
    var nextStepDateParsed: Date? {
        guard let s = nextStepDate else { return nil }
        return Self.isoFormatter.date(from: s)
    }
    
    var isDueSoon: Bool {
        guard let date = nextStepDateParsed else { return false }
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.startOfDay(for: date) <= cal.startOfDay(for: Date())
    }
}

struct MetaPersona: Codable, Identifiable {
    let id: Int
    let key: String
    let value: String
    let notes: String?
}

struct Entity: Codable, Identifiable {
    let id: Int
    let name: String
    let industry: String?
    let category: String?
    let country: String?
    let region: String?
    let location: String?
    let url: String?
    let email: String?
}

struct EntityInPersona: Codable {
    let entityId: Int
    let name: String
    let industry: String?
    let category: String?
    let country: String?
    let region: String?
    let location: String?
    let url: String?
    let isPrimary: Bool?
    let rol: String?
    let startDate: String?
    let endDate: String?
}

struct Persona: Codable, Identifiable {
    let id: Int
    let name: String
    let telephone: String?
    let email: String?
    let country: String?
    let region: String?
    let location: String?
    let category: String?
    let meta: [MetaPersona]
    let entities: [EntityInPersona]
}


// Persona+Samples.swift — datos de mentira, solo en debug
#if DEBUG
extension Persona {
    static let samples: [Persona] = [
        Persona(id: 1, name: "Cosme Fulanito", telephone: "+54911123451", email: "cosme@fulanito.com", country: "Argentina", region: "LATAM", location: "CABA", category: "Medios", meta: [], entities: [
            EntityInPersona(entityId: 1,name: "White Suit Studio",industry: "Videojuegos",category: nil,country: nil,region: nil,location: nil,url: nil,isPrimary: true,rol: "CEO",startDate: nil,endDate: nil),
        ]),
        Persona(id: 2, name: "Pablo Fulano", telephone: "+54911123451", email: "email@dominio.com", country: "Argentina", region: "LATAM", location: "CABA", category: "Influencer", meta: [
            MetaPersona(id: 1,key: "linkedin",value: "https://www.linkedin.com/in/unlinkedin/",notes: "Linkedin"),
            MetaPersona(id: 2,key: "whatsapp",value: "+54911123451",notes: "WhatsApp")
        ], entities: []),
    ]

}

extension Entity {
    static let samples: [Entity] = [
        Entity(
            id: 1, name: "White Suit Studio", industry: "Videojuegos", category: "videojuegos", country: "Argentina", region: "LATAM", location: "CABA", url: "https://Whitesuit.studio", email:nil),
        Entity(
            id: 5, name: "BENE.luxic", industry: "Ventas", category: "Sales",country: "Estados Unidos",region: "NA",location: "Miami",url: "https://www.beneluxic.com/",email: nil)
    ]
}
#endif
