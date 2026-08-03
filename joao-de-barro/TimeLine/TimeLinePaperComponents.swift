import SwiftUI

// MARK: - Main comment

struct MainPaperCommentCard: View {

    let comment: BookDiscussionComment
    let isLiked: Bool
    let onLike: () -> Void
    var usesLegacyLayout = false
    var showsReplyStack = true
    @State private var audioPlayer = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorHeader
            divider
            commentText
            actions
        }
        .foregroundStyle(.black)
        .frame(width: usesLegacyLayout ? 226 : 250)
        .padding(.horizontal, usesLegacyLayout ? 32 : 35)
        .padding(.vertical, usesLegacyLayout ? 39 : 48)
        .background {
            MainPaperBackground(
                isStacked:
                    showsReplyStack
                    && !comment.replies.isEmpty,
                replyCount: comment.replies.count,
                stackSeed: comment.id.uuidString
                    .unicodeScalars
                    .reduce(0) { $0 + Int($1.value) }
            )
        }
        .shadow(
            color: .black.opacity(0.15),
            radius: 3,
            x: 1,
            y: 2
        )
    }

    private var authorHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 22))

            Text("\(comment.author):")
                .font(
                    .system(
                        size: 17,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            Spacer()

            if let page = comment.page {
                Text("pág. \(page)")
                    .font(
                        .system(
                            size: 11,
                            weight: .medium,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(.black.opacity(0.58))
                    .fixedSize()
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.black.opacity(0.70))
            .frame(height: 1)
    }

    @ViewBuilder
    private var commentText: some View {
        if let audioURL = comment.audioURL {
            Button {
                audioPlayer.toggle(url: audioURL)
            } label: {
                Label(
                    audioPlayer.isPlaying
                        ? "Parar áudio"
                        : "Ouvir comentário",
                    systemImage: audioPlayer.isPlaying
                        ? "stop.fill"
                        : "play.fill"
                )
            }
            .buttonStyle(.plain)

            Text(comment.transcription ?? comment.text)
                .commentBodyStyle()
        } else {
            Text(comment.text)
                .commentBodyStyle()
        }
    }
}

private extension View {
    func commentBodyStyle() -> some View {
        self
            .font(
                .system(
                    size: 14,
                    weight: .regular,
                    design: .monospaced
                )
            )
            .tracking(0.5)
            .lineSpacing(1.5)
            .lineLimit(14)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}

extension MainPaperCommentCard {
    private var actions: some View {
        HStack(spacing: 6) {
            Spacer()

            Image("Peninha")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)

            Button(action: onLike) {
                Image(
                    systemName: isLiked
                        ? "heart.fill"
                        : "heart"
                )
                .foregroundStyle(
                    isLiked ? .red : .black
                )
                .font(
                    .system(
                        size: 21,
                        weight: .medium
                    )
                )
                .frame(width: 25, height: 25)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
        .padding(.top, 1)
    }
}

// MARK: - First chat message

struct FirstReplyPreview: View {

    let reply: BookChatReply
    let remainingReplies: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            replyHeader
            divider
            replyText

            HStack {
                if remainingReplies > 0 {
                    remainingRepliesLabel
                }

                Spacer()

                Image("Peninha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)

                Image(systemName: "heart")
                    .font(.system(size: 18))
            }
        }
        .foregroundStyle(.black)
        .frame(width: 242)
        .padding(.horizontal, 30)
        .padding(.top, 29)
                .padding(.bottom, 34)
        .background {
            ChatPaperBackground()
        }
        .shadow(
            color: .black.opacity(0.10),
            radius: 2,
            y: 1
        )
    }

    private var replyHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 19))

            Text("\(reply.author):")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .monospaced
                    )
                )

            Spacer()

            Image(systemName: "chevron.right")
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    .black.opacity(0.45)
                )
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.black.opacity(0.70))
            .frame(height: 1)
    }

    private var replyText: some View {
        Text(
            reply.isAudioMessage
                ? (reply.transcription ?? "Mensagem de áudio")
                : reply.text
        )
            .font(
                .system(
                    size: 13,
                    weight: .regular,
                    design: .monospaced
                )
            )
            .tracking(0.4)
            .lineSpacing(2)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }

    private var remainingRepliesLabel: some View {
        Text(
            remainingReplies == 1
                ? "Mais 1 mensagem"
                : "Mais \(remainingReplies) mensagens"
        )
        .font(
            .system(
                size: 10,
                weight: .semibold
            )
        )
        .foregroundStyle(.black.opacity(0.55))
    }
}

// MARK: - Empty chat

struct EmptyChatPreview: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 7) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 19))

                Text("Conversa:")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold,
                            design: .monospaced
                        )
                    )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        .black.opacity(0.45)
                    )
            }

            Rectangle()
                .fill(.black.opacity(0.70))
                .frame(height: 1)

            Text("Ainda não existem mensagens.")
                .font(
                    .system(
                            size: 13,
                        design: .monospaced
                    )
                )
                .lineSpacing(2)

            Spacer(minLength: 4)

            HStack {
                Text("Toque para iniciar o chat")
                    .font(
                        .system(
                            size: 10,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        .black.opacity(0.55)
                    )

                Spacer()

                Image("Peninha")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            }
        }
        .foregroundStyle(.black)
        .frame(width: 242)
        .padding(.horizontal, 30)
        .padding(.top, 29)
            .padding(.bottom, 34)
        .background {
            ChatPaperBackground()
        }
        .shadow(
            color: .black.opacity(0.10),
            radius: 2,
            y: 1
        )
    }
}

// MARK: - Chat paper asset

private struct ChatPaperBackground: View {

    var body: some View {
        Image("PapelChat")
            .resizable(resizingMode: .stretch)
            .accessibilityHidden(true)
    }
}

// MARK: - Main paper asset

private struct MainPaperBackground: View {

    let isStacked: Bool
    let replyCount: Int
    let stackSeed: Int

    var body: some View {
        ZStack {
            if isStacked {
                if replyCount > 1 {
                    paper
                        .rotationEffect(
                            .degrees(thirdPaperAngle)
                        )
                        .offset(
                            x: thirdPaperOffset.width,
                            y: thirdPaperOffset.height
                        )
                }

                paper
                    .rotationEffect(
                        .degrees(backPaperAngle)
                    )
                    .offset(
                        x: backPaperOffset.width,
                        y: backPaperOffset.height
                    )

                paper
                    .rotationEffect(
                        .degrees(middlePaperAngle)
                    )
                    .offset(
                        x: middlePaperOffset.width,
                        y: middlePaperOffset.height
                    )
            }

            paper
        }
        .accessibilityHidden(true)
    }

    private var direction: CGFloat {
        stackSeed.isMultiple(of: 2) ? 1 : -1
    }

    private var backPaperAngle: Double {
        Double(direction)
            * Double(3 + (stackSeed % 3))
    }

    private var middlePaperAngle: Double {
        Double(-direction)
            * Double(1.5 + Double(stackSeed % 4) * 0.45)
    }

    private var thirdPaperAngle: Double {
        Double(direction)
            * Double(6 + (stackSeed % 2))
    }

    private var backPaperOffset: CGSize {
        CGSize(
            width: direction * CGFloat(7 + stackSeed % 4),
            height: CGFloat(7 + stackSeed % 3)
        )
    }

    private var middlePaperOffset: CGSize {
        CGSize(
            width: -direction * CGFloat(4 + stackSeed % 3),
            height: CGFloat(4 + stackSeed % 2)
        )
    }

    private var thirdPaperOffset: CGSize {
        CGSize(
            width: direction * CGFloat(11 + stackSeed % 3),
            height: CGFloat(10 + stackSeed % 4)
        )
    }

    private var paper: some View {
        Image("papel_comentario")
            .resizable(
                capInsets: EdgeInsets(
                    top: 70,
                    leading: 55,
                    bottom: 70,
                    trailing: 55
                ),
                resizingMode: .stretch
            )
    }
}
