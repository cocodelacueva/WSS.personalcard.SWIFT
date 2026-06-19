//
//  ContentView.swift
//  personalcard
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(IntranetStore.self) private var store

    var body: some View {
        @Bindable var store = store
        TabView {
            HomeView()
            .tabItem {
                Label("Home", systemImage: "qrcode")
            }
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "document")
                }
            if store.hasKey {
                CrmListView()
                    .tabItem {
                        Label("CRM", systemImage: "person.crop.circle")
                    }
                ContactsListView()
                    .tabItem {
                        Label("Contacts", systemImage: "person")
                    }
            }
        }
        .alert("Sesión vencida", isPresented: $store.keyExpiredAlert) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text("Tu acceso venció. Generá una key nueva en la intranet y pegala en Ajustes.")
            }
    }
}

#Preview {
    ContentView()
        .environment(IntranetStore.preview)
}
