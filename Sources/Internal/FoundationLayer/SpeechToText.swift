//
//  SpeechToText.swift
//  OneMillionBot
//
//  Created by Adrián Rubio on 18/02/2021.
//

import Foundation
import Combine
import Speech
import AVFoundation

struct SpeechToText {
    let begin: () -> AnyPublisher<String, Error>
    let end: (_ discard: Bool) -> Void
}

extension SpeechToText {
    
    /// Wrapper around SFSpeechRecognizer. It will ask for the needed permissions and
    /// emit whenever it detects and transcribes any speech into text.
    
    static var live: SpeechToText {
        var subject = CurrentValueSubject<String, Error>("")
        let speech = SpeechInterface { subject }
        
        return SpeechToText(
            begin: {
                subject = CurrentValueSubject<String, Error>("")
                
                let sendError = {
                    DispatchQueue.main.async {
                        subject.send(completion: .failure(OneMillionBotError.inssuficientPermissions))
                    }
                }

                SFSpeechRecognizer.requestAuthorization { authStatus in
                    if authStatus == .authorized {
                        AVCaptureDevice.requestAccess(for: .audio) { bool in
                            if bool {
                                speech.begin()
                            } else {
                                sendError()
                            }
                        }
                    } else {
                        sendError()
                    }
                }
                
                return subject
                    .last()
                    .eraseToAnyPublisher()
            },
            end: { discard in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    speech.stop()

                    if !discard {
                        subject.send(completion: .finished)
                    }
                }
            }
        )
    }
}

fileprivate final class SpeechInterface: NSObject, SFSpeechRecognizerDelegate {
    private var speechRecognizer: SFSpeechRecognizer!
    private let audioEngine = AVAudioEngine()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var subject: () -> CurrentValueSubject<String, Error>
    
    init(_ subject: @escaping () -> CurrentValueSubject<String, Error>) {
        self.subject = subject
        super.init()
    }
    
    func begin() {
        speechRecognizer = SFSpeechRecognizer(
            locale: Locale(identifier: Env.speechLang)
        )
        
        speechRecognizer.delegate = self
        startRecording()
    }
    
    private func startRecording() {
        // Cancel the previous task if it's running.
        if audioEngine.isRunning { return }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure the audio session for the app.
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            
            // Create and configure the speech recognition request.
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                Env.log(
                    "Unable to create a SFSpeechAudioBufferRecognitionRequest object"
                )
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            
            // Keep speech recognition data on device
            if #available(iOS 13, *) {
                recognitionRequest.requiresOnDeviceRecognition = false
            }
            
            // Create a recognition task for the speech recognition session.
            // Keep a reference to the task so that it can be canceled.
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    self.subject().send(
                        result.bestTranscription.formattedString
                    )
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    // Stop recognizing speech if there is a problem.
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    error.map {
                        if $0._code != 216 {
                            self.subject().send(completion: .failure($0))
                        }
                    }
                }
            }
            
            // Configure the microphone input.
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            Env.log(error.localizedDescription)
        }
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
        recognitionTask?.finish()
        recognitionTask = nil

        recognitionRequest = nil
        recognitionTask = nil

        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            Env.log("Recognition Not Available")
        }
    }
}
