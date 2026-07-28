import SwiftUI

// MARK: - Discussion Section

struct BookDiscussionSectionView: View {

    let section: BookDiscussionSection
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionInformation

            ZStack {
                commentsList

                if !isUnlocked {
                    lockedOverlay
                }
            }
        }
    }

    private var sectionInformation: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("PÁGINA \(section.page)")
                    .font(
                        .system(
                            size: 12,
                            weight: .bold
                        )
                    )

                Text(commentDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(
                        .black.opacity(0.55)
                    )
            }

            Spacer()
        }
        .foregroundStyle(.black)
    }

    private var commentsList: some View {
        VStack(spacing: 16) {
            ForEach(section.comments) { comment in
                if isUnlocked {
                    NavigationLink(
                        value: comment.id
                    ) {
                        BookDiscussionCommentCard(
                            comment: comment
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    BookDiscussionCommentCard(
                        comment: comment
                    )
                    .allowsHitTesting(false)
                }
            }
        }
        .blur(
            radius: isUnlocked ? 0 : 9
        )
        .opacity(
            isUnlocked ? 1 : 0.60
        )
    }

    private var lockedOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 20))

            Text("Continue lendo")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )

            Text(
                "Comentários liberados na página \(section.page)."
            )
            .font(.system(size: 11))
            .multilineTextAlignment(.center)
        }
        .foregroundStyle(.black)
        .padding(14)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 18
            )
        )
        .padding(.horizontal, 16)
    }

    private var commentDescription: String {
        section.comments.count == 1
            ? "1 comentário"
            : "\(section.comments.count) comentários"
    }
}

// MARK: - Comment Card

struct BookDiscussionCommentCard: View {

    let comment: BookDiscussionComment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(comment.author)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )

            Text(comment.text)
                .font(.system(size: 14))
                .lineSpacing(2)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            HStack(spacing: 6) {
                Spacer()

                Image(
                    systemName: "bubble.left.fill"
                )
                .font(.system(size: 13))

                Text(replyDescription)
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )

                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
            }
            .foregroundStyle(
                .black.opacity(0.70)
            )
        }
        .foregroundStyle(.black)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            comment.color.opacity(0.90)
        )
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 34,
                bottomLeadingRadius: 34,
                bottomTrailingRadius: 6,
                topTrailingRadius: 6
            )
        )
        .contentShape(Rectangle())
    }

    private var replyDescription: String {
        switch comment.replies.count {
        case 0:
            return "Iniciar chat"

        case 1:
            return "1 resposta"

        default:
            return "\(comment.replies.count) respostas"
        }
    }
}

// MARK: - Timeline

struct BookCommentsTimelineView: View {

    let sections: [BookDiscussionSection]
    let activeSectionID: UUID?
    let currentPage: Int
    let finalPage: Int
    let onSectionSelected: (UUID) -> Void

    var body: some View {
        GeometryReader { geometry in
            let topPadding: CGFloat = 42
            let bottomPadding: CGFloat = 42

            let timelineHeight = max(
                geometry.size.height
                    - topPadding
                    - bottomPadding,
                1
            )

            ZStack {
                timelineBackground

                timelineLine(
                    geometry: geometry,
                    height: timelineHeight
                )

                pageLabels(
                    geometry: geometry
                )

                timelineEndpoints(
                    geometry: geometry,
                    topPadding: topPadding,
                    bottomPadding: bottomPadding
                )

                commentMarkers(
                    geometry: geometry,
                    topPadding: topPadding,
                    timelineHeight: timelineHeight
                )

                currentProgressMarker(
                    geometry: geometry,
                    topPadding: topPadding,
                    timelineHeight: timelineHeight
                )
            }
            .foregroundStyle(.black)
        }
    }

    // MARK: Timeline Background

    private var timelineBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                BookDiscussionColors.background
                    .opacity(0.92)
            )
    }

    // MARK: Timeline Line

    private func timelineLine(
        geometry: GeometryProxy,
        height: CGFloat
    ) -> some View {
        Rectangle()
            .fill(.black)
            .frame(
                width: 1.5,
                height: height
            )
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
    }

    // MARK: Page Labels

    private func pageLabels(
        geometry: GeometryProxy
    ) -> some View {
        Group {
            Text("Pág 1")
                .font(.system(size: 10))
                .position(
                    x: geometry.size.width / 2,
                    y: 12
                )

            Text("Pág \(finalPage)")
                .font(.system(size: 10))
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height - 10
                )
        }
    }

    // MARK: Start and End Points

    private func timelineEndpoints(
        geometry: GeometryProxy,
        topPadding: CGFloat,
        bottomPadding: CGFloat
    ) -> some View {
        Group {
            Circle()
                .fill(.black)
                .frame(
                    width: 6,
                    height: 6
                )
                .position(
                    x: geometry.size.width / 2,
                    y: topPadding
                )

            Circle()
                .fill(.black)
                .frame(
                    width: 6,
                    height: 6
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height
                        - bottomPadding
                )
        }
    }

    // MARK: Comment Markers

    private func commentMarkers(
        geometry: GeometryProxy,
        topPadding: CGFloat,
        timelineHeight: CGFloat
    ) -> some View {
        ForEach(sections) { section in
            let positionY = markerPosition(
                page: section.page,
                topPadding: topPadding,
                timelineHeight: timelineHeight
            )

            Button {
                onSectionSelected(section.id)
            } label: {
                BookTimelineCircle(
                    commentCount:
                        section.comments.count,
                    isSelected:
                        activeSectionID == section.id,
                    isUnlocked:
                        section.page <= currentPage
                )
            }
            .buttonStyle(.plain)
            .position(
                x: geometry.size.width / 2,
                y: positionY
            )
            .accessibilityLabel(
                "Comentários da página \(section.page)"
            )
            .accessibilityValue(
                section.comments.count == 1
                    ? "1 comentário"
                    : "\(section.comments.count) comentários"
            )
        }
    }

    // MARK: Current User Progress

    private func currentProgressMarker(
        geometry: GeometryProxy,
        topPadding: CGFloat,
        timelineHeight: CGFloat
    ) -> some View {
        let positionY = markerPosition(
            page: currentPage,
            topPadding: topPadding,
            timelineHeight: timelineHeight
        )

        return ZStack {
            Circle()
                .fill(
                    BookDiscussionColors.background
                )
                .frame(
                    width: 18,
                    height: 18
                )

            Circle()
                .fill(.black)
                .frame(
                    width: 10,
                    height: 10
                )
        }
        .position(
            x: geometry.size.width / 2,
            y: positionY
        )
        .accessibilityLabel(
            "Progresso atual"
        )
        .accessibilityValue(
            "Página \(currentPage)"
        )
        .zIndex(20)
    }

    // MARK: Marker Position

    private func markerPosition(
        page: Int,
        topPadding: CGFloat,
        timelineHeight: CGFloat
    ) -> CGFloat {
        let safePage = min(
            max(page, 1),
            finalPage
        )

        let pageProgress =
            CGFloat(safePage - 1)
            / CGFloat(max(finalPage - 1, 1))

        return topPadding
            + timelineHeight * pageProgress
    }
}

// MARK: - Comment Marker

struct BookTimelineCircle: View {

    let commentCount: Int
    let isSelected: Bool
    let isUnlocked: Bool

    private var circleSize: CGFloat {
        let minimumSize: CGFloat = 20
        let growthPerComment: CGFloat = 8
        let maximumSize: CGFloat = 58

        let calculatedSize =
            minimumSize
            + CGFloat(commentCount)
            * growthPerComment

        return min(
            calculatedSize,
            maximumSize
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    BookDiscussionColors.accent
                        .opacity(
                            isUnlocked
                                ? 0.48
                                : 0.20
                        )
                )
                .frame(
                    width: circleSize,
                    height: circleSize
                )

            if isSelected {
                Circle()
                    .stroke(
                        BookDiscussionColors.accent,
                        lineWidth: 2
                    )
                    .frame(
                        width: circleSize + 6,
                        height: circleSize + 6
                    )
            }

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(
                        .black.opacity(0.55)
                    )
            }
        }
        .frame(
            width: 68,
            height: 68
        )
        .contentShape(Circle())
    }
}

// MARK: - Bottom Navigation

struct BookNavigationItem: View {

    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 27,
                        weight: .light
                    )
                )

            Text(title)
                .font(.system(size: 10))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .overlay(alignment: .top) {
            if isSelected {
                Rectangle()
                    .fill(.black)
                    .frame(height: 2)
            }
        }
    }
}

// MARK: - Feather Icon

struct BookProgressFeather: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Feather stem
        path.move(
            to: CGPoint(
                x: rect.width * 0.27,
                y: rect.height * 0.93
            )
        )

        path.addCurve(
            to: CGPoint(
                x: rect.width * 0.80,
                y: rect.height * 0.09
            ),
            control1: CGPoint(
                x: rect.width * 0.20,
                y: rect.height * 0.55
            ),
            control2: CGPoint(
                x: rect.width * 0.49,
                y: rect.height * 0.20
            )
        )

        // Feather outline
        path.addCurve(
            to: CGPoint(
                x: rect.width * 0.22,
                y: rect.height * 0.55
            ),
            control1: CGPoint(
                x: rect.width * 0.52,
                y: rect.height * 0.04
            ),
            control2: CGPoint(
                x: rect.width * 0.20,
                y: rect.height * 0.24
            )
        )

        path.addCurve(
            to: CGPoint(
                x: rect.width * 0.80,
                y: rect.height * 0.09
            ),
            control1: CGPoint(
                x: rect.width * 0.50,
                y: rect.height * 0.63
            ),
            control2: CGPoint(
                x: rect.width * 0.83,
                y: rect.height * 0.34
            )
        )

        // Internal feather lines
        path.move(
            to: CGPoint(
                x: rect.width * 0.30,
                y: rect.height * 0.49
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.69,
                y: rect.height * 0.46
            )
        )

        path.move(
            to: CGPoint(
                x: rect.width * 0.37,
                y: rect.height * 0.38
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.72,
                y: rect.height * 0.35
            )
        )

        path.move(
            to: CGPoint(
                x: rect.width * 0.47,
                y: rect.height * 0.27
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.73,
                y: rect.height * 0.24
            )
        )

        path.move(
            to: CGPoint(
                x: rect.width * 0.36,
                y: rect.height * 0.48
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.25,
                y: rect.height * 0.35
            )
        )

        path.move(
            to: CGPoint(
                x: rect.width * 0.44,
                y: rect.height * 0.36
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.width * 0.35,
                y: rect.height * 0.24
            )
        )

        return path
    }
}
