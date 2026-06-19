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
            .refreshable { await store.refresh() }// pull-to-refresh
            .navigationTitle("CRM")
        }
    }
}

#Preview {
    CrmListView()
}
