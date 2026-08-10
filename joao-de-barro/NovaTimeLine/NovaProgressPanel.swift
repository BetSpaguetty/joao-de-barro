import SwiftUI

struct NovaProgressPanel: View {
    private enum Field: Hashable {
        case page
        case note
    }

    let totalPages: Int
    @Binding var readingNote: String

    let recorder: AudioRecorder
    let onMicrophoneTap: () -> Void
    let onOpenChat: () -> Void
    let onSave: (Int) -> Void

    @FocusState private var focusedField: Field?
    @State private var selectedPage: Double
    @State private var pageText: String

    init(
        currentPage: Int,
        totalPages: Int,
        readingNote: Binding<String>,
        recorder: AudioRecorder,
        onMicrophoneTap: @escaping () -> Void,
        onOpenChat: @escaping () -> Void,
        onSave: @escaping (Int) -> Void
    ) {
        let safeTotal = max(totalPages, 1)
        let safePage = min(max(currentPage, 1), safeTotal)

        self.totalPages = safeTotal
        _readingNote = readingNote
        self.recorder = recorder
        self.onMicrophoneTap = onMicrophoneTap
        self.onOpenChat = onOpenChat
        self.onSave = onSave
        _selectedPage = State(initialValue: Double(safePage))
        _pageText = State(initialValue: String(safePage))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            pageSection
            noteSection
            saveButton
        }
        .padding(.horizontal, 74)
        .padding(.top, 28)
        .frame(maxWidth: .infinity)
        .frame(height: 540, alignment: .top)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 58,
                bottomTrailingRadius: 58,
                topTrailingRadius: 0
            )
            .fill(NovaTimelineStyle.panelGray)
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .topTrailing) {
            raisedTabs
                .offset(y: -82)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Concluir") {
                    focusedField = nil
                }
            }
        }
    }

    private var raisedTabs: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button(action: onOpenChat) {
                ZStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                    .fill(NovaTimelineStyle.composerGray)

                    Image(systemName: "bubble.left")
                        .font(.system(size: 34))
                        .offset(y: 14)
                }
                .frame(width: 80, height: 82)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voltar ao chat")

            NovaBookmarkShape()
                .fill(NovaTimelineStyle.panelGray)
                .frame(width: 78, height: 38)
        }
        .padding(.trailing, 30)
    }

    private var pageSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Em que página você parou?")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            HStack(spacing: 10) {
                TextField("", text: $pageText)
                    .focused($focusedField, equals: .page)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 86, height: 34)
                    .overlay {
                        Capsule()
                            .stroke(.black, lineWidth: 1.5)
                    }
                    .onChange(of: pageText) {
                        updatePageFromText()
                    }

                Text("pág. de \(totalPages)")
                    .font(.system(size: 14, design: .monospaced))
            }

            Slider(
                value: $selectedPage,
                in: 1...Double(totalPages),
                step: 1
            )
            .tint(.black)
            .onChange(of: selectedPage) {
                pageText = String(Int(selectedPage))
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("O que você está achando?")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $readingNote)
                    .focused($focusedField, equals: .note)
                    .font(.system(size: 14, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .overlay(alignment: .topLeading) {
                        if readingNote.isEmpty {
                            Text(
                                "escreva aqui seus\npensamentos durante a\nleitura ..."
                            )
                            .font(
                                .system(
                                    size: 14,
                                    design: .monospaced
                                )
                            )
                            .foregroundStyle(.black.opacity(0.45))
                            .padding(20)
                            .allowsHitTesting(false)
                        }
                    }

                Button(action: onMicrophoneTap) {
                    Image(
                        systemName: recorder.isRecording
                            ? "stop.circle.fill"
                            : "mic"
                    )
                    .font(.system(size: 27))
                    .foregroundStyle(
                        recorder.isRecording ? .red : .black
                    )
                    .padding(18)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 210)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.black, lineWidth: 1.7)
            }
        }
        .padding(.top, 34)
    }

    private var saveButton: some View {
        Button {
            focusedField = nil
            onSave(Int(selectedPage))
        } label: {
            Label("Enviar comentário", systemImage: "paperplane")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .overlay {
                    Capsule()
                        .stroke(.black, lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
        .padding(.top, 22)
    }

    private func updatePageFromText() {
        guard let page = Int(pageText) else {
            return
        }

        selectedPage = Double(min(max(page, 1), totalPages))
    }
}
