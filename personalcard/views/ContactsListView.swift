//
//  ContactsListView.swift
//  personalcard
//
//  Created by coco on 08/06/2026.
//

import SwiftUI
import SwiftData

struct ContactsListView: View {
    @Environment(IntranetStore.self) private var store
    @State private var search = ""
    
    var filtered: [Persona] {
        guard !search.isEmpty else { return store.personas }
        return store.personas.filter { p in
            p.name.localizedCaseInsensitiveContains(search) ||
            p.entities.contains(where: { $0.name.localizedCaseInsensitiveContains(search) })
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filtered) { p in
                DisclosureGroup {
                    contactBody(for: p)
                } label: {
                    // header siempre visible
                    HStack {
                        Text(p.name).font(.headline)
                        if let entity = p.entities.first {
                            Text("| \(entity.name)").font(.subheadline).foregroundStyle(Color.secondary).font(Font.subheadline.weight(.light))
                        }
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
            .navigationTitle("Contactos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EntitiesListView()
                    } label: {
                        Label("Empresas", systemImage: "building.2")
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
    private func contactBody(for p: Persona) -> some View {
        VStack(alignment: .leading) {
            if let category = p.category {
                Text("Categoría: \(category)")
            }
            HStack {
                Text(p.country ?? "")
                Text(p.location ?? "")
            }.padding(2)
            Divider()
            if let entity = p.entities.first {
                HStack {
                    if let rol = entity.rol {
                        Text(rol)
                            .foregroundStyle(Color.secondary)
                            .font(Font.subheadline.weight(.light))
                        Text("@")
                            .foregroundStyle(Color.secondary)
                            .font(Font.subheadline.weight(.light))
                    }
                    Text(entity.name).font(.subheadline).foregroundStyle(Color.secondary).font(Font.subheadline.weight(.bold))
                }
                Divider()
            }
            
            if let email = p.email, let url = URL(string: "mailto:\(email)") {
                Link(destination: url) {
                    Label(email, systemImage: "envelope")
                        .padding(2)
                }
            }
            if let telephone = p.telephone {
                let clean = telephone.filter { $0.isNumber || $0 == "+" }
                    if let url = URL(string: "tel:\(clean)") {
                        Link(destination: url) { Label(telephone, systemImage: "phone")
                                .padding(2)
                        }
                    }
            }
            if let linkedin = p.meta.first(where: { $0.key == "linkedin" }),
               let url = URL(string: linkedin.value) {
                Link(destination: url) {
                    Label(linkedin.value, systemImage: "link")
                        .padding(2)
                }
            }
            
            if let whatsapp = p.meta.first(where: { $0.key == "whatsapp" }),
               let url = URL(string: whatsapp.value) {
                Link(destination: url) {
                    Label("WhatsApp", systemImage: "message.fill")
                        .padding(2)
                }
            }
            
        }
    }
    
}

#if DEBUG
#Preview {
    ContactsListView()
        .environment(IntranetStore.preview)
}
#endif
