import SwiftUI

struct TimeLineProgressView: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    let totalPages: Int
    let onSave: (Int, String) -> Void

    @State private var selectedPage: Double
    @State private var pageText: String
    @State private var readingComment = ""

    private enum Field {
        case page
        case comment
    }

    init(
        currentPage: Int = 234,
        totalPages: Int = 480,
        onSave: @escaping (Int, String) -> Void = { _, _ in }
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
                    // Iniciar gravação de áudio.
                } label: {
                    Image(systemName: "mic")
                        .font(.system(size: 25))
                        .foregroundStyle(.black)
                        .padding(16)
                }
                .buttonStyle(.plain)
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
                onSave(
                    Int(selectedPage),
                    readingComment.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                )
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 22))

                    Text("Enviar comentário")
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
        }
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
