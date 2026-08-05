import SwiftUI

struct NovaProgressPanel: View {
    private enum Field: Hashable {
        case percentage
        case note
    }

    @Binding var progressPercent: Int
    @Binding var progressText: String
    @Binding var readingNote: String

    let recorder: AudioRecorder
    let onMicrophoneTap: () -> Void
    let onSave: () -> Void

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            percentageSection
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
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
                .fill(NovaTimelineStyle.panelGray)

                Image(systemName: "bubble.left")
                    .font(.system(size: 34))
                    .offset(y: 14)
            }
            .frame(width: 80, height: 82)

            NovaBookmarkShape()
                .fill(NovaTimelineStyle.panelGray)
                .frame(width: 78, height: 38)
        }
        .padding(.trailing, 30)
    }

    private var percentageSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Quanto do livro você leu?")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            HStack(spacing: 10) {
                TextField("", text: $progressText)
                    .focused($focusedField, equals: .percentage)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 86, height: 34)
                    .overlay {
                        Capsule()
                            .stroke(.black, lineWidth: 1.5)
                    }
                    .onChange(of: progressText) {
                        updatePercentFromText()
                    }

                Text("% do livro")
                    .font(.system(size: 14, design: .monospaced))
            }

            Slider(
                value: Binding(
                    get: { Double(progressPercent) },
                    set: {
                        progressPercent = Int($0)
                        progressText = String(progressPercent)
                    }
                ),
                in: 0...100,
                step: 1
            )
            .tint(.black)
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
            onSave()
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

    private func updatePercentFromText() {
        guard let value = Int(progressText) else {
            return
        }
        progressPercent = min(max(value, 0), 100)
    }
}
