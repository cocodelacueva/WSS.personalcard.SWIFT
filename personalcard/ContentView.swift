//
//  ContentView.swift
//  personalcard
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
            .tabItem {
                Label("Home", systemImage: "qrcode")
            }
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "document")
                }
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
}

#Preview {
    ContentView()
}
