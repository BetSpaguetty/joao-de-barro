import SwiftUI

struct NovaReplyComposer: View {
    @Binding var replyText: String
    let isFocused: FocusState<Bool>.Binding
    let isRecording: Bool
    let canSend: Bool
    let onSend: () -> Void
    let onMicrophoneTap: () -> Void
    let onOpenProgress: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onMicrophoneTap) {
                Image(
                    systemName: isRecording
                        ? "stop.circle.fill"
                        : "mic"
                )
                .font(.system(size: 26))
                .foregroundStyle(isRecording ? .red : .black)
            }
            .buttonStyle(.plain)
            .disabled(!canSend)

            TextField(
                "escreva sua resposta...",
                text: $replyText,
                axis: .vertical
            )
            .focused(isFocused)
            .lineLimit(1...3)
            .font(.system(size: 13, design: .monospaced))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(0.72))
            .overlay {
                Capsule()
                    .stroke(.black, lineWidth: 1.5)
            }
            .clipShape(Capsule())
            .submitLabel(.send)
            .onSubmit(onSend)
            .disabled(!canSend)

            Button(action: onSend) {
                Image(systemName: "paperplane")
                    .font(.system(size: 28))
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
            .disabled(!canSend || trimmedText.isEmpty)
            .opacity(
                !canSend || trimmedText.isEmpty ? 0.45 : 1
            )
        }
        .padding(.horizontal, 48)
        .padding(.top, 24)
        .padding(.bottom, 18)
        .frame(height: 116, alignment: .bottom)
        .background(
            NovaTimelineStyle.composerGray
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .topTrailing) {
            NovaComposerTabs(
                onOpenProgress: onOpenProgress
            )
            .offset(y: -64)
        }
    }

    private var trimmedText: String {
        replyText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}

struct NovaComposerTabs: View {
    let onOpenProgress: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button(action: onOpenProgress) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 10,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 10
                )
                .fill(NovaTimelineStyle.composerGray)
                .frame(width: 64, height: 18)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Atualizar progresso")

            ZStack {
                NovaBookmarkShape()
                    .fill(NovaTimelineStyle.composerGray)

                Image(systemName: "pencil.tip")
                    .font(.system(size: 24))
                    .rotationEffect(.degrees(-24))
                    .offset(y: 12)
            }
            .frame(width: 60, height: 64)
        }
        .padding(.trailing, 32)
    }
}

struct NovaBookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(
            to: CGPoint(x: rect.midX, y: rect.minY + 22)
        )
        path.addLine(
            to: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(
            to: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(
            to: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

enum NovaTimelineStyle {
    static let composerGray = Color(
        red: 0.85,
        green: 0.85,
        blue: 0.85
    )

    static let panelGray = Color(
        red: 0.73,
        green: 0.73,
        blue: 0.73
    )
}
