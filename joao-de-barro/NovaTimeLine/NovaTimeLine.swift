import SwiftUI

struct NovaTimeLine: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isReplyFocused: Bool

    @State private var comments = TimeLineSampleData.comments
    @State private var selectedCommentID: UUID?
    @State private var replyText = ""
    @State private var progressPercent = 0
    @State private var progressPage = 1
    @State private var browsingPercent = 0
    @State private var readingNote = ""
    @State private var isShowingProgress = false
    @State private var replyRecorder = AudioRecorder()
    @State private var progressRecorder = AudioRecorder()

    private let bookPageCount = 480
    private let transcriber = AudioTranscriber()

    init() {
        let firstComment = TimeLineSampleData.comments.first
        var initialPercent = 0
        if let page = firstComment?.page {
            let percent = (Double(page) / 480.0) * 100
            initialPercent = Int(percent.rounded())
        }

        _selectedCommentID = State(
            initialValue: firstComment?.id
        )
        _progressPage = State(
            initialValue: firstComment?.page ?? 1
        )
        _progressPercent = State(
            initialValue: initialPercent
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
                        currentPage: progressPage,
                        totalPages: bookPageCount,
                        readingNote: $readingNote,
                        recorder: progressRecorder,
                        onMicrophoneTap: toggleProgressRecording,
                        onOpenChat: closeProgress,
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
        Array(Set(readableComments.map(commentPercentage))).sorted()
    }

    private var visibleComments: [BookDiscussionComment] {
        readableComments.filter {
            commentPercentage($0) == browsingPercent
        }
    }

    private var orderedComments: [BookDiscussionComment] {
        readableComments.sorted {
            commentPercentage($0) < commentPercentage($1)
        }
    }

    private var readableComments: [BookDiscussionComment] {
        comments.filter { comment in
            guard let page = comment.page else {
                return true
            }

            return page <= progressPage
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
              let comment = readableComments.first(where: {
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

    private func saveProgress(page: Int) {
        let savedPage = min(max(page, 1), bookPageCount)
        let savedPercent = Int(
            (Double(savedPage) / Double(bookPageCount) * 100)
                .rounded()
        )

        progressPage = savedPage
        progressPercent = savedPercent

        let trimmedNote = readingNote.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !trimmedNote.isEmpty {
            let newComment = BookDiscussionComment(
                author: "Você",
                text: trimmedNote,
                color: BookDiscussionColors.accent,
                page: savedPage,
                replies: []
            )

            comments.append(newComment)
            browsingPercent = savedPercent
            selectedCommentID = newComment.id
            readingNote = ""
        } else if !readableComments.contains(where: {
            $0.id == selectedCommentID
        }) {
            let lastReadableComment = readableComments.max {
                ($0.page ?? 0) < ($1.page ?? 0)
            }

            selectedCommentID = lastReadableComment?.id
            browsingPercent = lastReadableComment.map {
                commentPercentage($0)
            } ?? savedPercent
        }

        closeProgress()
    }
}

#Preview {
    NovaTimeLine()
}
