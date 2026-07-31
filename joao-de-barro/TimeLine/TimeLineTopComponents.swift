//
//  TimeLineTopComponents.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 30/07/26.
//

import SwiftUI

struct TimeLineHeader: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
            }

            Spacer()

            Text("Título do Livro")
                .font(
                    .system(
                        size: 24,
                        weight: .medium,
                        design: .serif
                    )
                )
                .italic()

            Spacer()

            HStack(spacing: 16) {
                Button {
                    // Abrir configurações.
                } label: {
                    Image(systemName: "gearshape")
                }

                Button {
                    // Abrir perfil.
                } label: {
                    Image(systemName: "person")
                }
            }
            .font(.system(size: 24))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 25)
        .padding(.top, 18)
        .padding(.bottom, 20)
    }
}

// MARK: - Reading progress

struct ReadingProgressHeader: View {

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

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

                Circle()
                    .fill(.black)
                    .frame(width: 23, height: 23)
                    .offset(x: width * 0.18)

                Circle()
                    .fill(.black.opacity(0.12))
                    .frame(width: 27, height: 27)
                    .offset(
                        x: width * 0.18 + 16
                    )

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
                    x: width * 0.68,
                    y: -26
                )
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 48)
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
