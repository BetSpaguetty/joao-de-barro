import SwiftUI

struct NovaTimelineHeader: View {
    let onBack: () -> Void
    let progressPercent: Int
    @Binding var browsingPercent: Int
    let commentPercentages: [Int]

    var body: some View {
        VStack(spacing: 0) {
            header
            progressLine
        }
        .frame(height: 198)
    }

    private var header: some View {
        ZStack {
            Text("Título do livro")
                .font(
                    .system(
                        size: 28,
                        weight: .semibold,
                        design: .serif
                    )
                )

            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 16) {
                    Image(systemName: "gearshape")
                    Image(systemName: "person")
                }
                .font(.system(size: 23))
                .frame(width: 72)
            }
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 28)
        .frame(height: 88, alignment: .bottom)
    }

    private var progressLine: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)

                Circle()
                    .fill(.black)
                    .frame(width: 6, height: 6)

                Circle()
                    .fill(.black)
                    .frame(width: 6, height: 6)
                    .offset(x: width - 6)

                ForEach(commentPercentages, id: \.self) { percent in
                    Circle()
                        .fill(.black.opacity(0.12))
                        .frame(width: 22, height: 22)
                        .offset(
                            x: position(
                                for: percent,
                                width: width,
                                elementWidth: 22
                            )
                        )
                        .contentShape(Circle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                browsingPercent = percent
                            }
                        }
                }

                Circle()
                    .fill(.black)
                    .frame(width: 19, height: 19)
                    .offset(
                        x: position(
                            for: browsingPercent,
                            width: width,
                            elementWidth: 19
                        )
                    )

                Image(systemName: "bookmark.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.gray.opacity(0.62))
                    .offset(
                        x: position(
                            for: progressPercent,
                            width: width,
                            elementWidth: 22
                        ),
                        y: 17
                    )
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let ratio = min(
                            max(value.location.x / max(width, 1), 0),
                            1
                        )
                        let draggedPercent = Int((ratio * 100).rounded())
                        browsingPercent = nearestCommentPercent(
                            to: draggedPercent
                        )
                    }
            )
        }
        .frame(height: 72)
        .padding(.horizontal, 48)
        .padding(.top, 18)
    }

    private func position(
        for percent: Int,
        width: CGFloat,
        elementWidth: CGFloat
    ) -> CGFloat {
        let ratio = CGFloat(min(max(percent, 0), 100)) / 100
        return ratio * max(width - elementWidth, 1)
    }

    private func nearestCommentPercent(to percent: Int) -> Int {
        commentPercentages.min {
            abs($0 - percent) < abs($1 - percent)
        } ?? percent
    }
}
