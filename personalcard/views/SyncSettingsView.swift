//
//  SyncSettingsView.swift
//  personalcard
//
//  Created by coco on 08/06/2026.
//

import SwiftUI

struct SyncSettingsView: View {
    @State private var keyInput = ""
    @State private var connected = KeychainStore.read(account: KeychainStore.apiKeyAccount) != nil
    
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Conexión con la intranet") {
                    if connected {
                        Label("Conectado", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                        Button("Desconectar", role: .destructive) {
                            KeychainStore.delete(account: KeychainStore.apiKeyAccount)
                            connected = false
                        }
                    } else {
                        SecureField("Pegá tu API key (wsk_...)", text: $keyInput)
                        Button("Guardar") {
                            KeychainStore.save(keyInput, account:  KeychainStore.apiKeyAccount)
                            connected = true
                            keyInput = ""
                            // TODO: pedí permiso de notificaciones (Paso 11) y dispará:
                            //       Task { await store.refresh() }
                        }
                        .disabled(keyInput.isEmpty)
                    }
                }
            }
            .navigationTitle("Sincronización")
        }
        
    }
}

#Preview {
    SyncSettingsView()
}
