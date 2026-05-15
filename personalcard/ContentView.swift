//
//  ContentView.swift
//  personalcard
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    // @AppStorage lee/escribe directo en UserDefaults y refresca la vista al cambiar.
    @AppStorage(StorageKeys.company) private var company = ""
    @AppStorage(StorageKeys.name)    private var name    = ""
    @AppStorage(StorageKeys.phone)   private var phone   = ""
    @AppStorage(StorageKeys.email)   private var email   = ""
    @AppStorage(StorageKeys.text)    private var text    = ""
    @AppStorage(StorageKeys.url)     private var url     = ""
    @AppStorage(StorageKeys.font)    private var selectedFont: AppFont = .system

    @State private var showingEdit = false

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
        }
    }

    @ViewBuilder
    private var qrView: some View {
        if let qr = QRGenerator.generate(from: url) {
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
