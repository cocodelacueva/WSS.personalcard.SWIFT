//
//  ContentView.swift
//  personalcard Watchkitapp Watch App
//
//  Created by coco on 15/05/2026.
//

import SwiftUI

struct ContentView: View {
    // Mismas claves y mismo store compartido (App Group) que el iPhone.
    @AppStorage(StorageKeys.company, store: SharedStorage.defaults) private var company = ""
    @AppStorage(StorageKeys.name,    store: SharedStorage.defaults) private var name    = ""
    @AppStorage(StorageKeys.phone,   store: SharedStorage.defaults) private var phone   = ""
    @AppStorage(StorageKeys.email,   store: SharedStorage.defaults) private var email   = ""
    @AppStorage(StorageKeys.text,    store: SharedStorage.defaults) private var text    = ""
    @AppStorage(StorageKeys.font,    store: SharedStorage.defaults) private var selectedFont: AppFont = .system
    // El Watch solo lee el PNG ya generado por el iPhone — no genera el QR.
    @AppStorage(StorageKeys.qrImageData, store: SharedStorage.defaults) private var qrImageData: Data = Data()

    var body: some View {
        // .verticalPage permite navegar con la corona digital y deslizando.
        TabView {
            qrPage
            textPage
        }
        .tabViewStyle(.verticalPage)
    }

    // Página 1: solo el QR, sin texto.
    private var qrPage: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if let qr = UIImage(data: qrImageData) {
                Image(uiImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                Text("Configurá una URL\nen el iPhone")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .padding()
            }
        }
    }

    // Página 2: todo el texto. ScrollView por si no entra.
    private var textPage: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if !company.isEmpty {
                        Text(company)
                            .font(selectedFont.font(size: 16, weight: .semibold))
                    }
                    if !name.isEmpty {
                        Text(name)
                            .font(selectedFont.font(size: 18, weight: .medium))
                    }
                    if !text.isEmpty  { Text(text).font(selectedFont.font(size: 13)) }
                    if !phone.isEmpty { Text(phone).font(selectedFont.font(size: 13)) }
                    if !email.isEmpty { Text(email).font(selectedFont.font(size: 13)) }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    ContentView()
}
