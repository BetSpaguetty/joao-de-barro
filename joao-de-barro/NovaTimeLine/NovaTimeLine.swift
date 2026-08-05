import SwiftUI

struct NovaTimeLine: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isReplyFocused: Bool

    @State private var comments = TimeLineSampleData.comments
    @State private var selectedCommentID: UUID?
    @State private var replyText = ""
    @State private var progressPercent = 0
    @State private var browsingPercent = 0
    @State private var progressText = "0"
    @State private var readingNote = ""
    @State private var isShowingProgress = false
    @State private var replyRecorder = AudioRecorder()
    @State private var progressRecorder = AudioRecorder()

    private let bookPageCount = 480
    private let transcriber = AudioTranscriber()

    init() {
        let firstComment = TimeLineSampleData.comments.first
        let initialPercent = firstComment?.page.map {
            Int(
                (Double($0) / 480.0 * 100)
                    .rounded()
            )
        } ?? 0

        _selectedCommentID = State(
            initialValue: firstComment?.id
        )
        _browsingPercent = State(
            initialValue: initialPercent
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mainContent(size: geometry.size)
                    .blur(radius: isShowingProgress ? 5 : 0)

                if isShowingProgress {
                    Color.black.opacity(0.03)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture(perform: closeProgress)

                    NovaProgressPanel(
                        progressPercent: $progressPercent,
                        progressText: $progressText,
                        readingNote: $readingNote,
                        recorder: progressRecorder,
                        onMicrophoneTap: toggleProgressRecording,
                        onSave: saveProgress
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottom
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
        .animation(
            .easeInOut(duration: 0.23),
            value: isShowingProgress
        )
        .onChange(of: progressPercent) {
            progressText = String(progressPercent)
        }
        .onChange(of: browsingPercent) {
            selectFirstCommentAtCurrentProgress()
        }
        .onChange(of: selectedCommentID) {
            updateBrowsingPercentFromSelectedComment()
        }
        .alert(
            "Gravação de áudio",
            isPresented: Binding(
                get: {
                    replyRecorder.errorMessage != nil
                    || progressRecorder.errorMessage != nil
                },
                set: {
                    if !$0 {
                        replyRecorder.errorMessage = nil
                        progressRecorder.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                replyRecorder.errorMessage = nil
                progressRecorder.errorMessage = nil
            }
        } message: {
            Text(
                replyRecorder.errorMessage
                ?? progressRecorder.errorMessage
                ?? ""
            )
        }
    }

    private func mainContent(size: CGSize) -> some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                NovaTimelineHeader(
                    onBack: { dismiss() },
                    progressPercent: progressPercent,
                    browsingPercent: $browsingPercent,
                    commentPercentages: commentPercentages
                )

                NovaConversationArea(
                    comments: orderedComments,
                    selectedCommentID: $selectedCommentID,
                    progressPercent: browsingPercent,
                    height: max(size.height - 182, 220)
                )
            }

            NovaReplyComposer(
                replyText: $replyText,
                isFocused: $isReplyFocused,
                isRecording: replyRecorder.isRecording,
                canSend: selectedCommentIndex != nil,
                onSend: sendTextReply,
                onMicrophoneTap: toggleReplyRecording,
                onOpenProgress: openProgress
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottom
            )
        }
    }

    private var commentPercentages: [Int] {
        Array(Set(comments.map(commentPercentage))).sorted()
    }

    private var visibleComments: [BookDiscussionComment] {
        comments.filter {
            commentPercentage($0) == browsingPercent
        }
    }

    private var orderedComments: [BookDiscussionComment] {
        comments.sorted {
            commentPercentage($0) < commentPercentage($1)
        }
    }

    private var selectedCommentIndex: Int? {
        guard let selectedCommentID else {
            return nil
        }

        return comments.firstIndex {
            $0.id == selectedCommentID
        }
    }

    private var trimmedReply: String {
        replyText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func commentPercentage(
        _ comment: BookDiscussionComment
    ) -> Int {
        guard let page = comment.page else {
            return 0
        }

        return min(
            max(
                Int(
                    (Double(page) / Double(bookPageCount) * 100)
                        .rounded()
                ),
                0
            ),
            100
        )
    }

    private func selectFirstCommentAtCurrentProgress() {
        selectedCommentID = visibleComments.first?.id
    }

    private func updateBrowsingPercentFromSelectedComment() {
        guard let selectedCommentID,
              let comment = comments.first(where: {
                  $0.id == selectedCommentID
              }) else {
            return
        }

        let percent = commentPercentage(comment)
        guard browsingPercent != percent else {
            return
        }
        browsingPercent = percent
    }

    private func sendTextReply() {
        guard !trimmedReply.isEmpty,
              let index = selectedCommentIndex else {
            return
        }

        comments[index].replies.append(
            BookChatReply(
                author: "Você",
                text: trimmedReply,
                isCurrentUser: true
            )
        )
        replyText = ""
    }

    private func toggleReplyRecording() {
        if replyRecorder.isRecording {
            guard let url = replyRecorder.stopRecording() else {
                return
            }
            Task { await sendAudioReply(url) }
        } else {
            isReplyFocused = false
            Task { await replyRecorder.startRecording() }
        }
    }

    private func sendAudioReply(_ url: URL) async {
        guard let index = selectedCommentIndex else {
            return
        }

        let transcription = await transcriber.transcribe(
            audioURL: url
        )
        comments[index].replies.append(
            BookChatReply(
                author: "Você",
                isCurrentUser: true,
                audioURL: url,
                transcription:
                    transcription ?? "Transcrição indisponível."
            )
        )
    }

    private func toggleProgressRecording() {
        if progressRecorder.isRecording {
            guard let url = progressRecorder.stopRecording() else {
                return
            }
            Task {
                if let transcription =
                    await transcriber.transcribe(audioURL: url) {
                    readingNote = transcription
                }
            }
        } else {
            Task { await progressRecorder.startRecording() }
        }
    }

    private func openProgress() {
        isReplyFocused = false
        isShowingProgress = true
    }

    private func closeProgress() {
        isShowingProgress = false
    }

    private func saveProgress() {
        let trimmedNote = readingNote.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedNote.isEmpty {
            let page = Int(
                (Double(progressPercent) / 100.0
                    * Double(bookPageCount)).rounded()
            )
            let newComment = BookDiscussionComment(
                author: "Você",
                text: trimmedNote,
                color: BookDiscussionColors.accent,
                page: page,
                replies: []
            )

            comments.append(newComment)
            browsingPercent = progressPercent
            selectedCommentID = newComment.id
            readingNote = ""
        }

        closeProgress()
    }
}

#Preview {
    NovaTimeLine()
}
