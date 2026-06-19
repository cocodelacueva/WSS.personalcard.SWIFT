//
//  EntitiesListView.swift
//  personalcard
//
//  Created by coco on 19/06/2026.
//

import SwiftUI

struct EntitiesListView: View {
    @Environment(IntranetStore.self) private var store
    @State private var search = ""
    
    var filtered: [Entity] {
        guard !search.isEmpty else { return store.entities }
        return store.entities.filter { e in
            e.name.localizedCaseInsensitiveContains(search)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filtered) { e in
                DisclosureGroup {
                    entityBody(for: e)
                } label: {
                    // header siempre visible
                    HStack {
                        Text(e.name).font(.headline)
                    }
                }
            }
            .searchable(text: $search)
            .refreshable { await store.refresh() }// pull-to-refresh
            .navigationTitle("Entidades")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ContactsListView()
                    } label: {
                        Label("Contactos", systemImage: "person")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func entityBody(for e: Entity) -> some View {
        Text(e.name)
    }
}

#Preview {
    EntitiesListView()
        .environment(IntranetStore.preview)
}
