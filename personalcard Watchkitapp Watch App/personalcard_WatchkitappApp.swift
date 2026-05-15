//
//  personalcard_WatchkitappApp.swift
//  personalcard Watchkitapp Watch App
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

@main
struct personalcard_Watchkitapp_Watch_AppApp: App {
    init() {
        // Activa WCSession al arrancar — recibe los datos que manda el iPhone.
        _ = WatchSync.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
