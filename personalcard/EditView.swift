//
//  EditView.swift
//  personalcard
//

import SwiftUI

struct EditView: View {
    // Mismas claves y mismo store compartido que ContentView y el Watch.
    @AppStorage(StorageKeys.company, store: SharedStorage.defaults) private var company = ""
    @AppStorage(StorageKeys.name,    store: SharedStorage.defaults) private var name    = ""
    @AppStorage(StorageKeys.phone,   store: SharedStorage.defaults) private var phone   = ""
    @AppStorage(StorageKeys.email,   store: SharedStorage.defaults) private var email   = ""
    @AppStorage(StorageKeys.text,    store: SharedStorage.defaults) private var text    = ""
    @AppStorage(StorageKeys.url,     store: SharedStorage.defaults) private var url     = ""
    @AppStorage(StorageKeys.font,    store: SharedStorage.defaults) private var selectedFont: AppFont = .system

    @Environment(\.dismiss) private var dismiss

    // Snapshot serializado de todos los campos — se usa para detectar cualquier cambio
    // y empujarlo al Watch en una sola .onChange.
    private var snapshot: String {
        "\(company)|\(name)|\(phone)|\(email)|\(text)|\(url)|\(selectedFont.rawValue)"
    }

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

                Section {
                    NavigationLink("Licencias de tipografías") {
                        LicensesView()
                    }
                } footer: {
                    Text("Raleway y Open Sans · SIL Open Font License 1.1")
                }
            }
            .navigationTitle("Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
            // Regenera el QR cada vez que cambia la URL.
            .onChange(of: url) { _, newValue in
                QRGenerator.regenerateAndStore(from: newValue)
            }
            // Empuja al Watch ante cualquier cambio en los campos (snapshot detecta todo).
            .onChange(of: snapshot) { _, _ in
                WatchSync.shared.push()
            }
        }
    }
}

#Preview {
    EditView()
}
