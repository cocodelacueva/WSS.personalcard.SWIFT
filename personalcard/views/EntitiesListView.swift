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
            .safeAreaInset(edge: .top) {
                Text(store.lastSyncText)
                    .font(.subheadline)
                    .padding(4)
            }
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await store.refresh() }
                    } label: {
                        Label("Sincronizar", systemImage: "arrow.clockwise")
                    }
                    .disabled(store.isLoading)
                }
            }
        }
    }
    
    @ViewBuilder
    private func entityBody(for e: Entity) -> some View {
        VStack(alignment: .leading) {
            HStack {
                if let country = e.country {
                    Text( "\(country)")
                        .font(Font.subheadline.weight(.light))
                }
                Spacer()
                if let region = e.region {
                    Text( "\(region)")
                        .font(Font.subheadline.weight(.light))
                }
            }
            .padding(5)
            
            Divider()
            
            if let email = e.email, let url = URL(string: "mailto:\(email)") {
                Link(destination: url) {
                    Label(email, systemImage: "envelope")
                        .padding(5)
                }
            }
            if let url = e.url, let link = URL(string: url) {
                Link(destination: link) {
                    Label(url, systemImage: "link")
                        .padding(5)
                }
            }
            Divider()
            HStack {
                if let category = e.category {
                    Text(category)
                        .font(Font.subheadline.weight(.light))
                }
                Spacer()
                if let industry = e.industry {
                    Text(industry)
                        .font(Font.subheadline.weight(.light))
                }
            }
            .padding(5)
            
        }
    }
}


#if DEBUG
#Preview {
    EntitiesListView()
        .environment(IntranetStore.preview)
}
#endif
