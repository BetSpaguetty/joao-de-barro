import SwiftUI

struct CommentsTimelineView: View {

    private let finalPage = 424

    @State private var currentPage = 40
    @State private var activeSectionID: UUID?
    @State private var isShowingProgress = false

    @State private var sections =
        BookDiscussionSection.sampleData

    var body: some View {
        NavigationStack {
            ZStack {
                BookDiscussionColors.background
                    .ignoresSafeArea()

                mainContent
                    .blur(
                        radius: isShowingProgress ? 7 : 0
                    )
                    .disabled(isShowingProgress)

                if isShowingProgress {
                    progressOverlay
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(
                for: UUID.self
            ) { commentID in
                if let comment = findComment(
                    id: commentID
                ) {
                    BookCommentChatPage(
                        comment: comment,
                        onSendReply: addReply
                    )
                } else {
                    Text("Comentário não encontrado")
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            if activeSectionID == nil {
                activeSectionID = sections.first?.id
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            bookInformation
            scrollableContent
            bottomNavigation
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            HStack {
                Image(systemName: "person.circle")
                    .font(
                        .system(
                            size: 34,
                            weight: .light
                        )
                    )

                Spacer()
            }

            Text("logo")
                .font(.system(size: 21))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 28)
        .frame(height: 100)
    }

    // MARK: Book

    private var bookInformation: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Devorador de estrelas")
                .font(.system(size: 21))

            Text("prazo: 30/07")
                .font(.system(size: 13))

            Text("Seu progresso: pág \(currentPage)")
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    .black.opacity(0.55)
                )
                .padding(.top, 5)
        }
        .foregroundStyle(.black)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 12)
    }

    // MARK: Scroll

    private var scrollableContent: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                ScrollView(
                    .vertical,
                    showsIndicators: false
                ) {
                    LazyVStack(spacing: 40) {
                        ForEach(sections) { section in
                            BookDiscussionSectionView(
                                section: section,
                                isUnlocked:
                                    section.page <= currentPage
                            )
                            .id(section.id)
                        }
                    }
                    .padding(.leading, 22)
                    .padding(.trailing, 92)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
                .scrollPosition(
                    id: $activeSectionID,
                    anchor: .top
                )

                BookCommentsTimelineView(
                    sections: sections,
                    activeSectionID: activeSectionID,
                    currentPage: currentPage,
                    finalPage: finalPage,
                    onSectionSelected: { sectionID in
                        activeSectionID = sectionID

                        withAnimation(
                            .easeInOut(duration: 0.45)
                        ) {
                            proxy.scrollTo(
                                sectionID,
                                anchor: .top
                            )
                        }
                    }
                )
                .frame(width: 84)
                .padding(.trailing, 2)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: Progress Overlay

    private var progressOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.08)
                .ignoresSafeArea()
                .onTapGesture {
                    closeProgress()
                }

            UpdateReadingProgressView(
                currentPage: currentPage,
                finalPage: finalPage,
                onCancel: closeProgress,
                onConfirm: confirmProgress
            )
            .frame(maxWidth: 370)
            .padding(.horizontal, 22)
            .transition(
                .scale(scale: 0.92)
                .combined(with: .opacity)
            )
        }
        .zIndex(10)
    }

    // MARK: Bottom Bar

    private var bottomNavigation: some View {
        HStack(spacing: 28) {
            BookNavigationItem(
                icon: "book.pages",
                title: "Livro",
                isSelected: false
            )

            BookNavigationItem(
                icon: "bubble.left",
                title: "Comentários",
                isSelected: true
            )

            Spacer()

            Button(action: openProgress) {
                ZStack {
                    Circle()
                        .fill(
                            BookDiscussionColors.accent
                        )
                        .frame(
                            width: 78,
                            height: 78
                        )

                    BookProgressFeather()
                        .stroke(
                            .black,
                            style: StrokeStyle(
                                lineWidth: 3,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .frame(
                            width: 43,
                            height: 58
                        )
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "Atualizar progresso"
            )
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // MARK: Progress Actions

    private func openProgress() {
        withAnimation(
            .spring(
                response: 0.32,
                dampingFraction: 0.82
            )
        ) {
            isShowingProgress = true
        }
    }

    private func closeProgress() {
        withAnimation(
            .easeInOut(duration: 0.2)
        ) {
            isShowingProgress = false
        }
    }

    private func confirmProgress(
        page: Int,
        commentText: String
    ) {
        currentPage = page

        let trimmedText = commentText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if !trimmedText.isEmpty {
            addComment(
                text: trimmedText,
                page: page
            )
        }

        closeProgress()
    }

    private func addComment(
        text: String,
        page: Int
    ) {
        let comment = BookDiscussionComment(
            author: "Você",
            text: text,
            color: BookDiscussionColors.accent,
            replies: []
        )

        if let index = sections.firstIndex(
            where: { $0.page == page }
        ) {
            sections[index]
                .comments
                .append(comment)

            activeSectionID = sections[index].id
        } else {
            let section = BookDiscussionSection(
                page: page,
                comments: [comment]
            )

            sections.append(section)
            sections.sort {
                $0.page < $1.page
            }

            activeSectionID = section.id
        }
    }

    // MARK: Chat Actions

    private func findComment(
        id: UUID
    ) -> BookDiscussionComment? {
        for section in sections {
            if let comment = section.comments.first(
                where: { $0.id == id }
            ) {
                return comment
            }
        }

        return nil
    }

    private func addReply(
        commentID: UUID,
        text: String
    ) {
        for sectionIndex in sections.indices {
            guard let commentIndex = sections[
                sectionIndex
            ].comments.firstIndex(
                where: { $0.id == commentID }
            ) else {
                continue
            }

            let reply = BookChatReply(
                author: "Você",
                text: text,
                isCurrentUser: true
            )

            sections[sectionIndex]
                .comments[commentIndex]
                .replies
                .append(reply)

            return
        }
    }
}

#Preview {
    CommentsTimelineView()
}
