//
//  personalcardApp.swift
//  personalcard
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

@main
struct personalcardApp: App {
    @State private var intranet = IntranetStore()
    init() {
        // Activa WCSession al arrancar la app — recibe pushes del Watch y permite enviar.
        _ = WatchSync.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(intranet)
                .task { await intranet.refreshIfStale() }
        }
    }
}
