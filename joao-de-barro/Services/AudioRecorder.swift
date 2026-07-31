import AVFoundation
import Foundation
import Observation

@MainActor
@Observable
final class AudioRecorder {
    private var recorder: AVAudioRecorder?

    var isRecording = false
    var errorMessage: String?

    func startRecording() async {
        errorMessage = nil

        guard await requestPermission() else {
            errorMessage = "Permita o acesso ao microfone para gravar uma resposta em áudio."
            return
        }

        do {
            #if !os(macOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            #endif

            recorder = try AVAudioRecorder(url: recordingURL(), settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            recorder?.record()
            isRecording = true
        } catch {
            errorMessage = "Não foi possível iniciar a gravação: \(error.localizedDescription)"
            isRecording = false
        }
    }

    func stopRecording() -> URL? {
        guard let recorder, isRecording else { return nil }

        recorder.stop()
        self.recorder = nil
        isRecording = false
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
        return recorder.url
    }

    private func requestPermission() async -> Bool {
        #if os(macOS)
        return await AVCaptureDevice.requestAccess(for: .audio)
#else
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }
        }
#endif
    }

    private func recordingURL() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let recordingsDirectory = directory.appendingPathComponent("Recordings", isDirectory: true)
        try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        return recordingsDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
    }
}

