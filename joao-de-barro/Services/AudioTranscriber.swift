import Foundation
import Speech

@MainActor
final class AudioTranscriber {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))

    func transcribe(audioURL: URL) async -> String? {
        guard await hasAuthorization(), recognizer?.isAvailable == true else {
            return nil
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        return await withCheckedContinuation { continuation in
            var hasFinished = false

            recognizer?.recognitionTask(with: request) { result, error in
                guard !hasFinished else { return }

                if let result, result.isFinal {
                    hasFinished = true
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if error != nil {
                    hasFinished = true
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func hasAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        return status == .authorized
    }
}
