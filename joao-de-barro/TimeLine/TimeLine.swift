import SwiftUI

struct TimeLine: View {

    @State private var comments: [BookDiscussionComment]
    @State private var selectedCommentID: UUID?
    @State private var likedComments = Set<UUID>()
    @State private var currentPage = 0

    private let totalPages = 480

    init() {
        let comments = TimeLineSampleData.comments

        _comments = State(initialValue: comments)
        _selectedCommentID = State(
            initialValue: comments.first?.id
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let availableHeight = geometry.size.height
                let topHeight =
                    availableHeight * (209.0 / 874.0)
                let commentHeight =
                    availableHeight * (367.0 / 874.0)
                let chatHeight =
                    availableHeight - topHeight - commentHeight

                ZStack {
                    Color.white
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        topSection
                            .frame(height: topHeight)

                        commentsCarousel
                            .frame(height: commentHeight)

                        bottomSection(
                            safeAreaBottom:
                                geometry.safeAreaInsets.bottom
                        )
                        .frame(height: chatHeight)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(
                for: UUID.self
            ) { commentID in
                if let comment = findComment(
                    id: commentID
                ) {
                    TimeLineChat(
                        comment: comment,
                        onSendReply: addReply
                    )
                } else {
                    ContentUnavailableView(
                        "Comentário não encontrado",
                        systemImage: "bubble.left"
                    )
                }
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Top

    private var topSection: some View {
        VStack(spacing: 0) {
            TimeLineHeader()

            Spacer(minLength: 0)

            ReadingProgressHeader(
                currentCommentIndex: selectedCommentPartIndex,
                commentPages: commentPages,
                totalPages: totalPages,
                readingProgress: Double(currentPage)
                    / Double(totalPages)
            )
            BookDividerView()
        }
    }

    // MARK: - Main comments

    private var commentsCarousel: some View {
        GeometryReader { geometry in
            let sideMargin = max(
                (geometry.size.width - 290) / 2,
                16
            )

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                LazyHStack(
                    alignment: .center,
                    spacing: 16
                ) {
                    ForEach(comments) { comment in
                        MainPaperCommentCard(
                            comment: comment,
                            isLiked: likedComments.contains(
                                comment.id
                            ),
                            onLike: {
                                toggleLike(comment.id)
                            }
                        )
                        .padding(.top, 32)
                        .id(comment.id)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(
                .horizontal,
                sideMargin,
                for: .scrollContent
            )
            .scrollTargetBehavior(
                .viewAligned(limitBehavior: .always)
            )
            .scrollPosition(
                id: $selectedCommentID,
                anchor: .center
            )
        }
    }

    // MARK: - Bottom

    @ViewBuilder
    private func bottomSection(
        safeAreaBottom: CGFloat
    ) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let comment = selectedComment {
                NavigationLink(value: comment.id) {
                    if let firstReply = comment.replies.first {
                        FirstReplyPreview(
                            reply: firstReply,
                            remainingReplies: max(
                                comment.replies.count - 1,
                                0
                            )
                        )
                    } else {
                        EmptyChatPreview()
                    }
                }
                .buttonStyle(.plain)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 40)
                .id(comment.id)
                .transition(.opacity)
            }

            progressButton
                .offset(y: safeAreaBottom)
        }
    }

    // MARK: - Progress button

    private var progressButton: some View {
        NavigationLink {
            TimeLineProgressView(
                currentPage: max(currentPage, 1),
                totalPages: totalPages,
                onSave: { page, text, audioURL, transcription in
                    currentPage = page
                    addComment(
                        text: text,
                        page: page,
                        audioURL: audioURL,
                        transcription: transcription
                    )
                }
            )
        } label: {
            Image("BotaoProgresso")
                .resizable()
                .scaledToFit()
                .frame(width: 108)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel("Atualizar progresso")
    }
    // MARK: - Selected comment

    private var selectedComment:
        BookDiscussionComment? {
        guard let selectedCommentID else {
            return comments.first
        }

        return comments.first {
            $0.id == selectedCommentID
        }
    }

    private var commentPages: [Int] {
        Array(Set(comments.compactMap { $0.page })).sorted()
    }

    private var selectedCommentPartIndex: Int {
        guard let page = selectedComment?.page,
              let index = commentPages.firstIndex(of: page) else {
            return 0
        }

        return index
    }

    // MARK: - Helpers

    private func findComment(
        id: UUID
    ) -> BookDiscussionComment? {
        comments.first {
            $0.id == id
        }
    }

    private func toggleLike(_ commentID: UUID) {
        withAnimation(
            .spring(
                response: 0.3,
                dampingFraction: 0.7
            )
        ) {
            if likedComments.contains(commentID) {
                likedComments.remove(commentID)
            } else {
                likedComments.insert(commentID)
            }
        }
    }

    private func addReply(
        commentID: UUID,
        reply: BookChatReply
    ) {
        guard let commentIndex =
            comments.firstIndex(
                where: { $0.id == commentID }
            )
        else {
            return
        }

        comments[commentIndex]
            .replies
            .append(reply)
    }

    private func addComment(
        text: String,
        page: Int,
        audioURL: URL?,
        transcription: String?
    ) {
        guard !text.isEmpty || audioURL != nil else {
            return
        }

        let newComment = BookDiscussionComment(
            author: "Você",
            text: text,
            color: BookDiscussionColors.accent,
            page: page,
            audioURL: audioURL,
            transcription: transcription,
            replies: []
        )

        comments.append(newComment)
        comments.sort {
            ($0.page ?? Int.max) < ($1.page ?? Int.max)
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCommentID = newComment.id
        }
    }

}

#Preview {
    TimeLine()
}
