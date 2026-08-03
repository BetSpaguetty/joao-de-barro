//
//  TimeLineTopComponents.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 30/07/26.
//

import SwiftUI

struct TimeLineHeader: View {
    var body: some View {
        ZStack {
            Text("Título do Livro")
                .font(
                    .system(
                        size: 24,
                        weight: .medium,
                        design: .serif
                    )
                )
                .italic()

            HStack {
                Spacer()

                HStack(spacing: 16) {
                    Button {
                        // Abrir configurações.
                    } label: {
                        Image(systemName: "gearshape")
                    }

                    NavigationLink {
                        PerfilClube()
                    } label: {
                        Image(systemName: "person")
                    }
                    .accessibilityLabel("Abrir perfil do clube")
                }
                .font(.system(size: 24))
                .frame(width: 76, alignment: .trailing)
            }
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 25)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }
}

// MARK: - Reading progress

struct ReadingProgressHeader: View {

    var currentCommentIndex = 0
    var commentPages: [Int] = []
    var totalPages = 1
    var readingProgress = 0.0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let positions = commentPositions(width: width)
            let safeIndex = min(
                max(currentCommentIndex, 0),
                max(positions.count - 1, 0)
            )

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)

                Circle()
                    .fill(.black)
                    .frame(width: 7, height: 7)

                Circle()
                    .fill(.black)
                    .frame(width: 7, height: 7)
                    .offset(x: width - 7)

                ForEach(
                    Array(positions.enumerated()),
                    id: \.offset
                ) { _, position in
                    Circle()
                        .fill(.black.opacity(0.12))
                        .frame(width: 27, height: 27)
                        .offset(x: position - 13.5)
                }

                if !positions.isEmpty {
                    Circle()
                        .fill(.black)
                        .frame(width: 11, height: 11)
                        .offset(
                            x: positions[safeIndex] - 5.5
                        )
                        .animation(
                            .spring(
                                response: 0.35,
                                dampingFraction: 0.78
                            ),
                            value: safeIndex
                        )
                }

                VStack(spacing: 1) {
                    Image(
                        systemName:
                            "person.crop.circle"
                    )
                    .font(.system(size: 17))

                    Image(
                        systemName:
                            "arrowtriangle.down.fill"
                    )
                    .font(.system(size: 7))
                }
                .offset(
                    x: min(
                        max(readingProgress, 0),
                        1
                    ) * (width - 17),
                    y: -26
                )
                .animation(
                    .spring(
                        response: 0.42,
                        dampingFraction: 0.82
                    ),
                    value: readingProgress
                )
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 48)
    }

    private func commentPositions(
        width: CGFloat
    ) -> [CGFloat] {
        let pages = commentPages
            .filter { $0 >= 0 }
            .sorted()

        guard !pages.isEmpty else {
            return []
        }

        let safeTotal = max(totalPages, 1)
        let usableWidth = max(width - 14, 1)

        return pages.map { page in
            let progress = min(
                max(CGFloat(page) / CGFloat(safeTotal), 0),
                1
            )

            return 7 + (progress * usableWidth)
        }
    }
}

// MARK: - Book divider

struct BookDividerView: View {

    var body: some View {
        TimeLineBookShape()
            .stroke(
                .black,
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(height: 30)
            .padding(.horizontal, 45)
            .padding(.bottom, 18)
    }
}

private struct TimeLineBookShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = rect.midX

        path.move(
            to: CGPoint(
                x: rect.minX,
                y: rect.minY + 2
            )
        )

        path.addCurve(
            to: CGPoint(
                x: center - 12,
                y: rect.maxY - 11
            ),
            control1: CGPoint(
                x: rect.width * 0.30,
                y: rect.minY + 1
            ),
            control2: CGPoint(
                x: center - 40,
                y: rect.minY + 7
            )
        )

        path.addLine(
            to: CGPoint(
                x: center - 12,
                y: rect.maxY - 2
            )
        )

        path.addLine(
            to: CGPoint(
                x: center + 12,
                y: rect.maxY - 2
            )
        )

        path.addLine(
            to: CGPoint(
                x: center + 12,
                y: rect.maxY - 11
            )
        )

        path.addCurve(
            to: CGPoint(
                x: rect.maxX,
                y: rect.minY + 2
            ),
            control1: CGPoint(
                x: center + 40,
                y: rect.minY + 7
            ),
            control2: CGPoint(
                x: rect.width * 0.70,
                y: rect.minY + 1
            )
        )

        return path
    }
}
