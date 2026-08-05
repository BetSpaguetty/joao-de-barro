import SwiftUI

struct TimeLine2: View {
    @State private var comments: [BookDiscussionComment]
    @State private var selectedCommentID: UUID?
    @State private var selectedPage: Int?
    @State private var likedComments = Set<UUID>()
    @State private var currentPage = 0

    private let totalPages = 480

    init() {
        let comments = TimeLineSampleData.comments
        _comments = State(initialValue: comments)
        _selectedCommentID = State(initialValue: comments.first?.id)
        _selectedPage = State(initialValue: comments.first?.page)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let availableHeight = geometry.size.height
                let topHeight = availableHeight * (209.0 / 874.0)

                ZStack {
                    Color.white
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        topSection
                            .frame(height: topHeight)
                            .background(Color.white)
                            .zIndex(2)

                        pageCarousel
                            .frame(height: availableHeight - topHeight)
                    }

                    progressButton
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottomTrailing
                        )
                        .offset(y: geometry.safeAreaInsets.bottom)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { commentID in
                if let comment = findComment(id: commentID) {
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

    private var topSection: some View {
        VStack(spacing: 0) {
            TimeLineHeader()
            Spacer(minLength: 0)

            ReadingProgressHeader(
                currentCommentIndex: selectedCommentPartIndex,
                commentPages: commentPages,
                totalPages: totalPages,
                readingProgress:
                    Double(currentPage) / Double(totalPages)
            )

            BookDividerView()
        }
    }

    private var pageCarousel: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width * 0.76

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 8) {
                    ForEach(commentGroups) { group in
                        commentsColumn(
                            group,
                            width: pageWidth,
                            availableHeight: geometry.size.height
                        )
                        .id(group.page)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .contentMargins(
                .horizontal,
                (geometry.size.width - pageWidth) / 2,
                for: .scrollContent
            )
            .scrollTargetBehavior(
                .viewAligned(limitBehavior: .always)
            )
            .scrollPosition(id: $selectedPage, anchor: .center)
            .onChange(of: selectedPage) {
                guard let selectedPage,
                      let first = commentGroups
                        .first(where: { $0.page == selectedPage })?
                        .comments.first else {
                    return
                }

                selectedCommentID = first.id
            }
        }
    }

    private func commentsColumn(
        _ group: TimeLine2PageGroup,
        width: CGFloat,
        availableHeight: CGFloat
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 18) {
                ForEach(group.comments) { comment in
                    commentAndChat(
                        comment,
                        width: width
                    )
                    .id(comment.id)
                }
            }
            .scrollTargetLayout()
            .padding(.top, 18)
            .padding(.bottom, 80)
        }
        .frame(width: width, height: availableHeight)
        .scrollTargetBehavior(
            .viewAligned(limitBehavior: .always)
        )
        .scrollPosition(id: $selectedCommentID, anchor: .top)
    }

    private func commentAndChat(
        _ comment: BookDiscussionComment,
        width: CGFloat
    ) -> some View {
        VStack(spacing: -32) {
            MainPaperCommentCard(
                comment: comment,
                isLiked: likedComments.contains(comment.id),
                onLike: {
                    toggleLike(comment.id)
                },
                usesLegacyLayout: true,
                showsReplyStack: false
            )
            .zIndex(1)

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
            .zIndex(2)
        }
        .frame(width: width)
    }

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

    private var selectedComment: BookDiscussionComment? {
        guard let selectedCommentID else {
            return comments.first
        }

        return comments.first { $0.id == selectedCommentID }
    }

    private var commentPages: [Int] {
        Array(Set(comments.compactMap { $0.page })).sorted()
    }

    private var commentGroups: [TimeLine2PageGroup] {
        commentPages.map { page in
            TimeLine2PageGroup(
                page: page,
                comments: comments.filter { $0.page == page }
            )
        }
    }

    private var selectedCommentPartIndex: Int {
        guard let page = selectedComment?.page,
              let index = commentPages.firstIndex(of: page) else {
            return 0
        }

        return index
    }

    private func findComment(id: UUID) -> BookDiscussionComment? {
        comments.first { $0.id == id }
    }

    private func toggleLike(_ commentID: UUID) {
        withAnimation(
            .spring(response: 0.3, dampingFraction: 0.7)
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
        guard let index = comments.firstIndex(
            where: { $0.id == commentID }
        ) else {
            return
        }

        comments[index].replies.append(reply)
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
            selectedPage = page
            selectedCommentID = newComment.id
        }
    }
}

private struct TimeLine2PageGroup: Identifiable {
    let page: Int
    let comments: [BookDiscussionComment]

    var id: Int { page }
}

#Preview {
    TimeLine2()
}
