//
//  EditView.swift
//  personalcard
//

import SwiftUI

struct EditView: View {
    // Mismas claves que ContentView: al editar acá, la pantalla principal se actualiza sola.
    @AppStorage(StorageKeys.company) private var company = ""
    @AppStorage(StorageKeys.name)    private var name    = ""
    @AppStorage(StorageKeys.phone)   private var phone   = ""
    @AppStorage(StorageKeys.email)   private var email   = ""
    @AppStorage(StorageKeys.text)    private var text    = ""
    @AppStorage(StorageKeys.url)     private var url     = ""
    @AppStorage(StorageKeys.font)    private var selectedFont: AppFont = .system

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Empresa") {
                    TextField("Nombre de la empresa", text: $company)
                }

                Section("Datos") {
                    TextField("Nombre", text: $name)

                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("Texto (puesto u otro)", text: $text)
                }

                Section("QR") {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Tipografía") {
                    Picker("Fuente", selection: $selectedFont) {
                        ForEach(AppFont.allCases) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                }
            }
            .navigationTitle("Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    EditView()
}
