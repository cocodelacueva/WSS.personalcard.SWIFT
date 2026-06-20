//
//  CrmListView.swift
//  personalcard
//
//  Created by coco on 10/06/2026.
//

import SwiftUI

struct CrmListView: View {
    @Environment(IntranetStore.self) private var store
    
    var body: some View {
        NavigationStack {
            List(store.crm) { p in
                VStack(alignment: .leading) {
                    HStack {
                        Text(p.personaName ?? "Sin nombre").font(.headline)
                        if let entity = p.entityName {
                            Text("| \(entity)").font(.subheadline)
                        }
                    }
                    
                    if let nextStep = p.nextStep {
                        Text(nextStep).padding(2)
                        
                        if let date = p.nextStepDateParsed {
                            Text(date, format: Date.FormatStyle(date: .long, timeZone: .gmt)).bold().foregroundStyle(p.isDueSoon ? .red : .secondary)
                        } else if let raw = p.nextStepDate {
                            Text(raw)   // por si el formato no matchea, al menos mostrás algo
                        }
                        
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                Text(store.lastSyncText)
                    .font(.subheadline)
                    .padding(4)
            }
            .refreshable { await store.refresh() }// pull-to-refresh
            .navigationTitle("CRM")
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
}

#if DEBUG
#Preview {
    CrmListView()
        .environment(IntranetStore.preview)
}
#endif
