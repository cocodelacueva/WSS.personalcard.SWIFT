//
//  ContentView.swift
//  personalcard
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    // @AppStorage lee/escribe en UserDefaults compartido (App Group) — así el Watch ve los mismos datos.
    @AppStorage(StorageKeys.company, store: SharedStorage.defaults) private var company = ""
    @AppStorage(StorageKeys.name,    store: SharedStorage.defaults) private var name    = ""
    @AppStorage(StorageKeys.phone,   store: SharedStorage.defaults) private var phone   = ""
    @AppStorage(StorageKeys.email,   store: SharedStorage.defaults) private var email   = ""
    @AppStorage(StorageKeys.text,    store: SharedStorage.defaults) private var text    = ""
    @AppStorage(StorageKeys.url,     store: SharedStorage.defaults) private var url     = ""
    @AppStorage(StorageKeys.font,    store: SharedStorage.defaults) private var selectedFont: AppFont = .system
    // PNG del QR ya generado. Se actualiza al editar la URL; aquí solo se lee.
    @AppStorage(StorageKeys.qrImageData, store: SharedStorage.defaults) private var qrImageData: Data = Data()

    @State private var showingEdit = false
    @State private var showingNotes = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 24) {
                    if !company.isEmpty {
                        Text(company)
                            .font(selectedFont.font(size: 22, weight: .semibold))
                    }

                    qrView

                    VStack(spacing: 6) {
                        if !name.isEmpty {
                            Text(name)
                                .font(selectedFont.font(size: 28, weight: .medium))
                        }
                        if !text.isEmpty  { Text(text) }
                        if !phone.isEmpty { Text(phone) }
                        if !email.isEmpty { Text(email) }
                    }
                    .font(selectedFont.font(size: 17))
                }
                .foregroundStyle(.black)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Editar", systemImage: "gearshape") { showingEdit = true }
                        .foregroundStyle(.black)
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditView()
            }
            .onAppear {
                // Migración / fallback: si hay URL pero todavía no se persistió la imagen, generala.
                if !url.isEmpty && qrImageData.isEmpty {
                    QRGenerator.regenerateAndStore(from: url)
                }
                // Empuja el estado actual al Watch al abrir la app — útil si el Watch
                // se instala/abre después de haber cargado datos en el iPhone.
                WatchSync.shared.push()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Notas", systemImage: "doc") { showingNotes = true }
                        .foregroundStyle(.black)
                }
            }.sheet(isPresented: $showingNotes) {
                NotesView()
            }
        }
    }

    @ViewBuilder
    private var qrView: some View {
        if let qr = UIImage(data: qrImageData) {
            Image(uiImage: qr)
                .interpolation(.none) // QR nítido sin antialiasing
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black, lineWidth: 1)
                .frame(width: 220, height: 220)
                .overlay(Text("Configurá una URL").foregroundStyle(.secondary))
        }
    }
}

#Preview {
    ContentView()
}
