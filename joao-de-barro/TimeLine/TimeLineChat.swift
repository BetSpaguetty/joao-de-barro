//
//  TimeLineChat.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 30/07/26.
//

import SwiftUI

struct TimeLineChat: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    let comment: BookDiscussionComment
    let onSendReply: (UUID, BookChatReply) -> Void

    @State private var message = ""
    @State private var replies: [BookChatReply]
    @State private var recorder = AudioRecorder()
    private let audioTranscriber = AudioTranscriber()

    init(
        comment: BookDiscussionComment,
        onSendReply: @escaping (UUID, BookChatReply) -> Void
    ) {
        self.comment = comment
        self.onSendReply = onSendReply

        _replies = State(
            initialValue: comment.replies
        )
    }

    private var trimmedMessage: String {
        message.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                chatHeader

                ScrollViewReader { proxy in
                    ScrollView(
                        .vertical,
                        showsIndicators: false
                    ) {
                        LazyVStack(spacing: -34) {
                            TimeLineChatPaper(
                                author: comment.author,
                                text: comment.text,
                                page: comment.page,
                                angle: -1.2
                            )
                            .zIndex(0)

                            ForEach(
                                Array(replies.enumerated()),
                                id: \.element.id
                            ) { index, reply in
                                TimeLineChatPaper(
                                    author: reply.author,
                                    text: reply.text,
                                    audioURL: reply.audioURL,
                                    transcription: reply.transcription,
                                    isCurrentUser:
                                        reply.isCurrentUser,
                                    angle: index.isMultiple(of: 2)
                                        ? 0.9
                                        : -0.7
                                )
                                .id(reply.id)
                                .zIndex(Double(index + 1))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 150)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .onChange(of: replies.count) {
                        guard let lastReply = replies.last else {
                            return
                        }

                        withAnimation {
                            proxy.scrollTo(
                                lastReply.id,
                                anchor: .bottom
                            )
                        }
                    }
                }
            }

            if !isTextFieldFocused {
                Color(
                    red: 0.97,
                    green: 0.93,
                    blue: 0.92
                )
                .frame(height: 44)
                .offset(y: 34)
                .ignoresSafeArea(
                    .container,
                    edges: .bottom
                )
                .allowsHitTesting(false)
            }

            messageComposer
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .alert("Gravação de áudio", isPresented: Binding(
            get: { recorder.errorMessage != nil },
            set: { if !$0 { recorder.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { recorder.errorMessage = nil }
        } message: {
            Text(recorder.errorMessage ?? "")
        }
    }

    // MARK: - Cabeçalho

    private var chatHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Título do Livro")
                    .font(
                        .system(
                            size: 22,
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
                .font(.system(size: 22))
                .frame(width: 72)
            }
            .padding(.horizontal, 18)
            .padding(.top, 2)
            .padding(.bottom, 18)

            ReadingProgressHeader()

            BookDividerView()
        }
        .frame(height: 190, alignment: .top)
        .foregroundStyle(.black)
    }

    // MARK: - Campo de resposta

    private var messageComposer: some View {
        HStack(spacing: 9) {
            Button {
                if recorder.isRecording {
                    guard let audioURL = recorder.stopRecording() else { return }
                    Task { await sendAudioReply(audioURL: audioURL) }
                } else {
                    Task { await recorder.startRecording() }
                }
            } label: {
                Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic")
                    .font(.system(size: 23))
                    .foregroundStyle(recorder.isRecording ? .red : .black)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                recorder.isRecording
                    ? "Parar e enviar áudio"
                    : "Gravar resposta em áudio"
            )

            TextField(
                "escreva sua resposta...",
                text: $message,
                axis: .vertical
            )
            .focused($isTextFieldFocused)
            .lineLimit(1)
            .font(
                .system(
                    size: 13,
                    design: .monospaced
                )
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.75))
            .overlay {
                Capsule()
                    .stroke(.black, lineWidth: 1.5)
            }
            .clipShape(Capsule())
            .submitLabel(.send)
            .onSubmit(sendMessage)

            Button(action: sendMessage) {
                Image(systemName: "paperplane")
                    .font(.system(size: 26))
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
            .disabled(trimmedMessage.isEmpty)
            .opacity(trimmedMessage.isEmpty ? 0.45 : 1)
        }
        .padding(.horizontal, 36)
        .padding(.top, 38)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 126, alignment: .bottom)
        .background {
            Image("FundoConversa")
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(0.92)
                .ignoresSafeArea(
                    .container,
                    edges: .bottom
                )
        }
    }

    private func sendMessage() {
        guard !trimmedMessage.isEmpty else {
            return
        }

        let newReply = BookChatReply(
            author: "Você",
            text: trimmedMessage,
            isCurrentUser: true
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            replies.append(newReply)
        }

        onSendReply(comment.id, newReply)

        message = ""
    }

    private func sendAudioReply(audioURL: URL) async {
        let transcription = await audioTranscriber.transcribe(audioURL: audioURL)
            ?? "Transcrição indisponível."
        let newReply = BookChatReply(
            author: "Você",
            isCurrentUser: true,
            audioURL: audioURL,
            transcription: transcription
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            replies.append(newReply)
        }

        onSendReply(comment.id, newReply)
    }
}

// MARK: - Papel de cada mensagem

private struct TimeLineChatPaper: View {

    let author: String
    let text: String
    var page: Int? = nil
    var audioURL: URL?
    var transcription: String?
    var isCurrentUser = false
    var angle = 0.0
    @State private var audioPlayer = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 6) {
                Image(systemName: "person.circle")
                    .font(.system(size: 20))

                Text(author + ":")
                    .font(
                        .system(
                            size: 16,
                            weight: .bold,
                            design: .monospaced
                        )
                    )

                Spacer()

                if let page {
                    Text("pág. \(page)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.black.opacity(0.58))
                        .fixedSize()
                }
            }

            Rectangle()
                .fill(.black.opacity(0.8))
                .frame(height: 1)

            if let audioURL {
                Button {
                    audioPlayer.toggle(url: audioURL)
                } label: {
                    Label(
                        audioPlayer.isPlaying ? "Parar áudio" : "Mensagem de áudio",
                        systemImage: audioPlayer.isPlaying ? "stop.fill" : "play.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Reproduz o áudio enviado")

                Text(transcription ?? "Transcrição indisponível.")
                    .font(.system(size: 14, design: .monospaced))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(text)
                    .font(
                        .system(
                            size: 14,
                            design: .monospaced
                        )
                    )
                    .lineSpacing(2)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .foregroundStyle(.black)
        .frame(width: 282, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, 30)
        .padding(.bottom, 32)
        .background {
            Image("PapelConversa")
                .resizable(resizingMode: .stretch)
        }
        .rotationEffect(.degrees(angle))
        .frame(
            maxWidth: .infinity,
            alignment: .center
        )
    }
}

#Preview {
    NavigationStack {
        TimeLineChat(
            comment: TimeLineSampleData.comments[0],
            onSendReply: { _, _ in }
        )
    }
}
