//
//  BookCommentChatPage.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 28/07/26.
//

import SwiftUI

struct BookCommentChatPage: View {

    @Environment(\.dismiss) private var dismiss

    let comment: BookDiscussionComment
    let onSendReply: (UUID, String) -> Void

    @State private var draftReply = ""
    @State private var localReplies: [BookChatReply]

    init(
        comment: BookDiscussionComment,
        onSendReply: @escaping (UUID, String) -> Void
    ) {
        self.comment = comment
        self.onSendReply = onSendReply

        _localReplies = State(
            initialValue: comment.replies
        )
    }

    private var trimmedReply: String {
        draftReply.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        ZStack {
            BookDiscussionColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                originalComment
                repliesTitle
                repliesScroll
                replyComposer
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(
                        systemName: "chevron.left"
                    )
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text("Chat")
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    // MARK: Original Comment

    private var originalComment: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("COMENTÁRIO INICIAL")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            .black.opacity(0.55)
                        )

                    Text(comment.author)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                }

                Spacer()

                Image(
                    systemName: "quote.opening"
                )
                .font(.system(size: 28))
                .foregroundStyle(
                    .black.opacity(0.35)
                )
            }

            Text(comment.text)
                .font(.system(size: 19))
                .lineSpacing(5)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            HStack(spacing: 6) {
                Image(
                    systemName: "bubble.left.fill"
                )

                Text(replyDescription)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
            }
            .foregroundStyle(
                .black.opacity(0.60)
            )
        }
        .foregroundStyle(.black)
        .frame(
            maxWidth: .infinity,
            minHeight: 190,
            alignment: .topLeading
        )
        .padding(24)
        .background(
            comment.color.opacity(0.92)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 30
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 30
            )
            .stroke(
                .black.opacity(0.18),
                lineWidth: 1.5
            )
        }
        .shadow(
            color: .black.opacity(0.14),
            radius: 12,
            y: 6
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }

    private var replyDescription: String {
        switch localReplies.count {
        case 0:
            return "Nenhuma resposta"

        case 1:
            return "1 resposta"

        default:
            return "\(localReplies.count) respostas"
        }
    }

    // MARK: Replies

    private var repliesTitle: some View {
        HStack {
            Text("Respostas")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

            Spacer()
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    private var repliesScroll: some View {
        ScrollViewReader { proxy in
            ScrollView(
                .vertical,
                showsIndicators: false
            ) {
                LazyVStack(spacing: 12) {
                    if localReplies.isEmpty {
                        emptyChat
                    } else {
                        ForEach(localReplies) { reply in
                            BookReplyBubble(reply: reply)
                                .id(reply.id)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .onChange(
                of: localReplies.count
            ) {
                guard let lastReply = localReplies.last else {
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

    private var emptyChat: some View {
        VStack(spacing: 10) {
            Image(
                systemName:
                    "bubble.left.and.bubble.right"
            )
            .font(
                .system(
                    size: 34,
                    weight: .light
                )
            )

            Text("Ainda não há respostas")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

            Text(
                "Seja a primeira pessoa a responder."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                .black.opacity(0.6)
            )
        }
        .foregroundStyle(.black)
        .padding(.top, 35)
    }

    // MARK: Composer

    private var replyComposer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "Escreva uma resposta...",
                text: $draftReply,
                axis: .vertical
            )
            .lineLimit(1...4)
            .font(.system(size: 14))
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                .black.opacity(0.07)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )

            Button(action: sendReply) {
                Image(systemName: "arrow.up")
                    .font(
                        .system(
                            size: 16,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        BookDiscussionColors.background
                    )
                    .frame(width: 42, height: 42)
                    .background(.black)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(trimmedReply.isEmpty)
            .opacity(
                trimmedReply.isEmpty ? 0.35 : 1
            )
        }
        .padding(16)
        .background(
            BookDiscussionColors.background
        )
    }

    private func sendReply() {
        guard !trimmedReply.isEmpty else {
            return
        }

        let reply = BookChatReply(
            author: "Você",
            text: trimmedReply,
            isCurrentUser: true
        )

        withAnimation(
            .easeInOut(duration: 0.2)
        ) {
            localReplies.append(reply)
        }

        onSendReply(
            comment.id,
            trimmedReply
        )

        draftReply = ""
    }
}

// MARK: - Reply Bubble

struct BookReplyBubble: View {

    let reply: BookChatReply

    var body: some View {
        HStack {
            if reply.isCurrentUser {
                Spacer(minLength: 55)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reply.author)
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )

                Text(reply.text)
                    .font(.system(size: 14))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                reply.isCurrentUser
                    ? BookDiscussionColors.accent
                    : Color.white.opacity(0.45)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )

            if !reply.isCurrentUser {
                Spacer(minLength: 55)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
