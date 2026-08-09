import Foundation
import Combine
#if canImport(Speech)
import Speech
import AVFoundation
#endif

/// 语音识别与录音管理器 (Speech & Voice Input Manager)
public class SpeechRecognitionManager: ObservableObject {
    public static let shared = SpeechRecognitionManager()
    
    @Published public var isRecording: Bool = false
    @Published public var recognizedText: String = ""
    @Published public var permissionDenied: Bool = false
    
    #if canImport(Speech)
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    #endif
    
    public init() {}
    
    /// 请求麦克风与语音识别双重权限
    public func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        #if canImport(Speech)
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                #if os(iOS)
                AVAudioApplication.requestRecordPermission { micGranted in
                    DispatchQueue.main.async {
                        self.permissionDenied = !micGranted
                        completion(micGranted)
                    }
                }
                #else
                DispatchQueue.main.async {
                    self.permissionDenied = false
                    completion(true)
                }
                #endif
            } else {
                DispatchQueue.main.async {
                    self.permissionDenied = true
                    completion(false)
                }
            }
        }
        #else
        completion(false)
        #endif
    }
    
    /// 开始语音倾听录音
    public func startRecording(simulatedText: String = "", onTextRecognized: @escaping (String) -> Void) {
        #if targetEnvironment(simulator) || !os(iOS)
        // 模拟器或 macOS 命令行测试环境：模拟语音流输入
        guard !isRecording else { return }
        self.isRecording = true
        self.recognizedText = "正在倾听口述..."
        
        let textToEmit = simulatedText
        if !textToEmit.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self, self.isRecording else { return }
                self.recognizedText = textToEmit
                onTextRecognized(textToEmit)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.stopRecording()
                }
            }
        }
        #else
        #if canImport(Speech)
        guard !isRecording else { return }
        
        // 清理旧任务
        stopRecording()
        
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetoothHFP, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession error: \(error)")
        }
        #endif
        
        if speechRecognizer == nil || !(speechRecognizer?.isAvailable ?? false) {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) ?? SFSpeechRecognizer()
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.recognizedText = text
                    onTextRecognized(text)
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        if recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("AudioEngine start error: \(error)")
        }
        #else
        DispatchQueue.main.async {
            self.isRecording = false
        }
        #endif
        #endif
    }
    
    /// 停止语音倾听录音
    public func stopRecording() {
        #if canImport(Speech)
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        #endif
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    /// 切换录音状态
    public func toggleRecording(simulatedText: String = "", onTextRecognized: @escaping (String) -> Void) {
        if isRecording {
            stopRecording()
        } else {
            #if targetEnvironment(simulator) || !os(iOS)
            startRecording(simulatedText: simulatedText, onTextRecognized: onTextRecognized)
            #else
            requestAuthorization { [weak self] granted in
                if granted {
                    self?.startRecording(simulatedText: simulatedText, onTextRecognized: onTextRecognized)
                }
            }
            #endif
        }
    }
}
