import SwiftUI

struct NovaConversationArea: View {
    let comments: [BookDiscussionComment]
    @Binding var selectedCommentID: UUID?
    @State private var showReplies = false
    let progressPercent: Int
    let height: CGFloat

    var body: some View {
        if comments.isEmpty {
            NovaEmptyConversationView(
                progressPercent: progressPercent
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            carousel
        }
    }

    private var carousel: some View {
        GeometryReader { geometry in
            let width = geometry.size.width * 0.88
            
            // Scrow horizontal de todos os comentários "mãe"
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 12) {
                    
                    ForEach(comments) { comment in
                        conversation(comment, width: width)
                            .id(comment.id)
                    }
                    /*
                    ForEach(commentsGroupedByPage, id: \.page) { pageGroup in
                        conversation(
                            pageGroup.comments,
                            width: width
                        )
                    }*/
                }
                .scrollTargetLayout()
            }
            .contentMargins(
                .horizontal,
                (geometry.size.width - width) / 2,
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
        .frame(height: height)
    }

    private func conversation(
        _ comment: BookDiscussionComment,
        width: CGFloat
    ) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Estrutura dos comentários
            LazyVStack(alignment: .leading, spacing: 26) {
                NovaCommentThread(comment: comment)
                /*
                NovaMainCommentCard(comment: comment)
                
                if showReplies {
                    ForEach(comment.replies) { reply in
                        NovaReplyCard(reply: reply)
                    }
                }*/
                
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 130)
        }
        .frame(width: width, height: height)
        .scrollDismissesKeyboard(.interactively)
    }
}

struct NovaEmptyConversationView: View {
    let progressPercent: Int

    var body: some View {
        Text(
            "Ainda não há\ncomentários em\n\(progressPercent)% do livro"
        )
            .font(
                .system(
                    size: 18,
                    weight: .medium,
                    design: .serif
                )
            )
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .foregroundStyle(.black)
            .padding(.bottom, 100)
    }
}

struct NovaCommentThread: View {
    let comment: BookDiscussionComment

    @State private var showReplies = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            NovaMainCommentCard(comment: comment)

            Button {
                withAnimation {
                    showReplies.toggle()
                }
            } label: {
                HStack {
                    Text(
                        showReplies
                        ? "Ocultar respostas"
                        : "Ver \(comment.replies.count) respostas"
                    )

                    Image(
                        systemName: showReplies
                        ? "chevron.up"
                        : "chevron.down"
                    )
                }
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.black)
            }
            .buttonStyle(.plain)

            if showReplies {
                ForEach(comment.replies) { reply in
                    NovaReplyCard(reply: reply)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

// Estrutura do comentário
struct NovaMainCommentCard: View {
    let comment: BookDiscussionComment

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
           
            HStack(spacing: 14) {
                // Nome do autor
                Text(comment.author)
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold,
                            design: .serif
                        )
                    )
                
                // Número da página
                if let page = comment.page {
                    Text("Página \(page)")
                        .font(
                            .system(
                                size: 13,
                                weight: .medium,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(.black.opacity(0.6))
                }
            }
            
            // Texto do comentario
            Text(comment.text)
                .font(.system(size: 14, design: .monospaced))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(red: 0.86, green: 0.86, blue: 0.86),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

struct NovaReplyCard: View {
    let reply: BookChatReply
    @State private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(reply.author)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold,
                        design: .serif
                    )
                )

            Rectangle()
                .fill(.black.opacity(0.82))
                .frame(height: 2)

            if let url = reply.audioURL {
                Button {
                    player.toggle(url: url)
                } label: {
                    Label(
                        player.isPlaying ? "Parar áudio" : "Ouvir áudio",
                        systemImage: player.isPlaying
                            ? "stop.fill"
                            : "play.fill"
                    )
                }
                .buttonStyle(.plain)

                Text(reply.transcription ?? "Transcrição indisponível.")
                    .font(.system(size: 14, design: .monospaced))
            } else {
                Text(reply.text)
                    .font(.system(size: 14, design: .monospaced))
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

