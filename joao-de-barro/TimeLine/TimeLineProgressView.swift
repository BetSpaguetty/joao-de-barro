import SwiftUI

struct TimeLineProgressView: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    let totalPages: Int
    let onSave: (Int, String, URL?, String?) -> Void

    @State private var selectedPage: Double
    @State private var pageText: String
    @State private var readingComment = ""
    @State private var recordedAudioURL: URL?
    @State private var recorder = AudioRecorder()
    private let audioTranscriber = AudioTranscriber()

    private enum Field {
        case page
        case comment
    }

    init(
        currentPage: Int = 234,
        totalPages: Int = 480,
        onSave: @escaping (Int, String, URL?, String?) -> Void = { _, _, _, _ in }
    ) {
        let safeTotal = max(totalPages, 1)
        let safePage = min(max(currentPage, 1), safeTotal)

        self.totalPages = safeTotal
        self.onSave = onSave
        _selectedPage = State(initialValue: Double(safePage))
        _pageText = State(initialValue: String(safePage))
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                formPaper
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .onTapGesture {
            focusedField = nil
        }
        .alert("Gravação de áudio", isPresented: Binding(
            get: { recorder.errorMessage != nil },
            set: { if !$0 { recorder.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                recorder.errorMessage = nil
            }
        } message: {
            Text(recorder.errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 23))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Título do Livro")
                .font(
                    .system(
                        size: 23,
                        weight: .medium,
                        design: .serif
                    )
                )
                .italic()

            Spacer()

            HStack(spacing: 14) {
                Image(systemName: "gearshape")
                Image(systemName: "person")
            }
            .font(.system(size: 23))
            .frame(width: 76)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 20)
        .frame(height: 112, alignment: .top)
        .padding(.top, 8)
    }

    private var formPaper: some View {
        ZStack(alignment: .top) {
            Image("Progress")
                .resizable(resizingMode: .stretch)
                .padding(.top, -24)
                .padding(.leading, 10)
                .ignoresSafeArea(edges: .bottom)

            VStack(alignment: .leading, spacing: 0) {
                pageSection
                    .padding(.top, 70)
                    .offset(x: 12)

                commentSection
                    .padding(.top, 38)
                    .offset(x: 12)

                sendButton
                    .padding(.top, 48)
            }
            .padding(.horizontal, 66)
            .padding(.top, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Em que página você parou?")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    TextField("", text: $pageText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .page)
                        .frame(width: 65)
                        .onChange(of: pageText) {
                            updatePageFromText()
                        }

                    Rectangle()
                        .fill(.black)
                        .frame(width: 1, height: 28)

                    Text("pág")
                        .fixedSize()
                        .padding(.horizontal, 8)
                }
                .font(.system(size: 14, design: .monospaced))
                .frame(height: 34)
                .overlay {
                    Capsule()
                        .stroke(.black, lineWidth: 1.5)
                }

                Text("de \(totalPages) páginas")
                    .font(.system(size: 14, design: .monospaced))
                    .fixedSize()
            }

            Slider(
                value: $selectedPage,
                in: 1...Double(totalPages),
                step: 1
            )
            .tint(.gray)
            .onChange(of: selectedPage) {
                pageText = String(Int(selectedPage))
            }
        }
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("O que você está achando?")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $readingComment)
                    .focused($focusedField, equals: .comment)
                    .font(.system(size: 14, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .overlay(alignment: .topLeading) {
                        if readingComment.isEmpty {
                            Text(
                                "escreva aqui seus\npensamentos durante a\nleitura ..."
                            )
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.48))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                        }
                    }

                Button {
                    toggleRecording()
                } label: {
                    Image(
                        systemName: recorder.isRecording
                            ? "stop.circle.fill"
                            : "mic"
                    )
                        .font(.system(size: 25))
                        .foregroundStyle(
                            recorder.isRecording ? .red : .black
                        )
                        .padding(16)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    recorder.isRecording
                        ? "Parar gravação"
                        : "Gravar comentário em áudio"
                )
            }
            .frame(height: 238)
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.black, lineWidth: 1.7)
            }
        }
    }

    private var sendButton: some View {
        HStack {
            Spacer()

            Button {
                focusedField = nil
                saveComment()
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 22))

                    Text(
                        hasComment
                            ? "Enviar comentário"
                            : "Salvar progresso"
                    )
                        .font(
                            .system(
                                size: 14,
                                weight: .medium,
                                design: .monospaced
                            )
                        )
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .frame(height: 42)
                .overlay {
                    Capsule()
                        .stroke(.black, lineWidth: 1.7)
                }
            }
            .buttonStyle(.plain)
            .disabled(recorder.isRecording)
            .opacity(recorder.isRecording ? 0.45 : 1)
        }
    }

    private var trimmedComment: String {
        readingComment.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var hasComment: Bool {
        !trimmedComment.isEmpty || recordedAudioURL != nil
    }

    private func toggleRecording() {
        if recorder.isRecording {
            guard let audioURL = recorder.stopRecording() else {
                return
            }

            recordedAudioURL = audioURL
            Task {
                if let transcription = await audioTranscriber.transcribe(
                    audioURL: audioURL
                ), readingComment.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty {
                    readingComment = transcription
                }
            }
        } else {
            focusedField = nil
            Task {
                await recorder.startRecording()
            }
        }
    }

    private func saveComment() {
        let transcription = recordedAudioURL == nil
            ? nil
            : (trimmedComment.isEmpty ? nil : trimmedComment)

        onSave(
            Int(selectedPage),
            trimmedComment,
            recordedAudioURL,
            transcription
        )
    }

    private func updatePageFromText() {
        guard let page = Int(pageText) else {
            return
        }

        selectedPage = Double(
            min(max(page, 1), totalPages)
        )
    }
}

#Preview {
    NavigationStack {
        TimeLineProgressView()
    }
}
