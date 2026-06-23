//
//  NotesView.swift
//  personalcard
//
//  Created by coco on 03/06/2026.
//

import SwiftUI

struct NotesView: View {
    @AppStorage(StorageKeys.notes, store: SharedStorage.defaults) private var Notes = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
          Form {

              ZStack {

                  TextEditor(text: $Notes)
                      .frame(minHeight: 500, maxHeight: .infinity )
                      .cornerRadius(8)
                      .focused($isEditorFocused)

              }
              .padding()
            }
          .navigationTitle("Tomar notas")
          .scrollDismissesKeyboard(.interactively)
          .toolbar {
              ToolbarItemGroup(placement: .topBarTrailing) {
                  Button("Listo") {
                      isEditorFocused = false
                  }
              }
          }
        }
    }
}

#if DEBUG
#Preview {
    NotesView()
}
#endif
