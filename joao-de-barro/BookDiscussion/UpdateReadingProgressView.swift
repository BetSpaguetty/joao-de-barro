//
//  UpdateReadingProgressView.swift
//  joao-de-barro
//
//  Created by Ilan Cukierman on 28/07/26.
//

import SwiftUI

struct UpdateReadingProgressView: View {

    let currentPage: Int
    let finalPage: Int
    let onCancel: () -> Void
    let onConfirm: (Int, String) -> Void

    @State private var selectedPage: Double
    @State private var commentText = ""

    init(
        currentPage: Int,
        finalPage: Int,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (Int, String) -> Void
    ) {
        self.currentPage = currentPage
        self.finalPage = finalPage
        self.onCancel = onCancel
        self.onConfirm = onConfirm

        _selectedPage = State(
            initialValue: Double(currentPage)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            closeButton

            Text("Atualizar progresso")
                .font(.system(size: 30))
                .padding(.top, 2)

            progressSlider
                .padding(.top, 35)

            commentEditor
                .padding(.top, 25)

            confirmButton
                .padding(.top, 24)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .padding(.bottom, 28)
        .background(
            BookDiscussionColors.accent,
            in: RoundedRectangle(
                cornerRadius: 48
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 48
            )
            .stroke(.black, lineWidth: 4)
        }
        .shadow(
            color: .black.opacity(0.22),
            radius: 22,
            y: 10
        )
    }

    private var closeButton: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private var progressSlider: some View {
        VStack(spacing: 2) {
            HStack {
                Text("Pág 1")
                Spacer()
                Text("Pág \(finalPage)")
            }
            .font(.system(size: 16))

            Slider(
                value: $selectedPage,
                in: 1...Double(finalPage),
                step: 1
            )
            .tint(.black)

            Text("\(Int(selectedPage))")
                .font(
                    .system(
                        size: 16,
                        weight: .medium
                    )
                )
        }
    }

    private var commentEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Comentário opcional")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )

            TextEditor(text: $commentText)
                .font(.system(size: 15))
                .scrollContentBackground(.hidden)
                .frame(height: 92)
                .padding(10)
                .background(
                    .white.opacity(0.92),
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )
                .overlay(alignment: .topLeading) {
                    if commentText.isEmpty {
                        Text(
                            "Comente sobre a página \(Int(selectedPage))..."
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(
                            .black.opacity(0.42)
                        )
                        .padding(.horizontal, 15)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                    }
                }
        }
    }

    private var confirmButton: some View {
        Button {
            onConfirm(
                Int(selectedPage),
                trimmedComment
            )
        } label: {
            Text(buttonTitle)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18
                    )
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 42)
    }

    private var trimmedComment: String {
        commentText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var buttonTitle: String {
        trimmedComment.isEmpty
            ? "atualizar página"
            : "atualizar e publicar"
    }
}
