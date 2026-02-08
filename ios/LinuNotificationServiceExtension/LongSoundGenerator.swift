//
//  LongSoundGenerator.swift
//  LinuNotificationService
//

import AVFoundation
import Foundation
import UserNotifications

private let kLinuSoundPrefix = "linu.sounds.30s"

/// 长铃声生成器
/// 生成长铃声文件并设置到通知的 sound 属性，让系统自动播放
class LongSoundGenerator {
    
    static let shared = LongSoundGenerator()
    
    private init() {}
    
    /// 为通知设置长铃声
    /// - Parameters:
    ///   - content: 通知内容
    ///   - soundFileName: 完整的声音文件名（包含扩展名），nil 表示使用系统默认
    /// - Returns: 处理后的通知内容
    func setLongSound(for content: UNMutableNotificationContent, soundFileName: String?) -> UNMutableNotificationContent {
        if let longSoundUrl = getLongSound(soundFileName: soundFileName) {
            let soundName = UNNotificationSoundName(rawValue: longSoundUrl.lastPathComponent)
            content.sound = UNNotificationSound(named: soundName)
        } else {
            content.sound = UNNotificationSound.default
        }
        
        return content
    }
    
    // MARK: - Private
    
    /// 获取长铃声文件（30秒）
    /// - Parameters:
    ///   - soundFileName: 完整的声音文件名（包含扩展名），nil 表示使用系统默认
    private func getLongSound(soundFileName: String?) -> URL? {
        guard let soundsDirectoryUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.aprilzz.linu"
        )?.appendingPathComponent("Library/Sounds") else {
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: soundsDirectoryUrl.path) {
            try? FileManager.default.createDirectory(
                atPath: soundsDirectoryUrl.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        // 确定原始声音文件路径
        var originalSoundPath: String?
        var actualFileName: String = "default"
        
        if let fileName = soundFileName, !fileName.isEmpty {
            // 使用指定的声音文件
            actualFileName = fileName
            
            // 1. 先在 App Group 的 Library/Sounds 目录中查找（用户自定义声音）
            let sharedSoundPath = soundsDirectoryUrl.appendingPathComponent(fileName).path
            if FileManager.default.fileExists(atPath: sharedSoundPath) {
                originalSoundPath = sharedSoundPath
            }
            
            // 2. 在 Bundle 中查找
            if originalSoundPath == nil {
                let url = URL(fileURLWithPath: fileName)
                let baseName = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension
                if let bundlePath = Bundle.main.path(forResource: baseName, ofType: ext) {
                    originalSoundPath = bundlePath
                }
            }
        } else {
            // 使用系统默认声音（按优先级尝试）
            // 1. Tiptoes.caf - 轻柔的铃声
            // 2. Anticipate.caf - 柔和的提示音  
            // 3. alarm.caf - 系统闹钟（备选）
            let defaultSounds = [
                ("Tiptoes", "caf"),
                ("Anticipate", "caf"),
                ("alarm", "caf")
            ]
            
            for (name, ext) in defaultSounds {
                let systemSoundPath = "/System/Library/Audio/UISounds/\(name).\(ext)"
                if FileManager.default.fileExists(atPath: systemSoundPath) {
                    actualFileName = "\(name).\(ext)"
                    originalSoundPath = systemSoundPath
                    break
                }
            }
        }
        
        guard let originalPath = originalSoundPath else {
            return nil
        }
        
        // 检查是否已有长铃声缓存
        let longSoundName = "\(kLinuSoundPrefix).\(actualFileName)"
        let longSoundPath = soundsDirectoryUrl.appendingPathComponent(longSoundName)
        if FileManager.default.fileExists(atPath: longSoundPath.path) {
            return longSoundPath
        }
        
        return mergeCAFFilesToDuration(
            inputFile: URL(fileURLWithPath: originalPath),
            targetDuration: 30.0,
            outputPath: longSoundPath
        )
    }
    
    /// 将输入的音频文件重复为指定时长的音频文件
    /// - Parameters:
    ///   - inputFile: 原始铃声文件路径
    ///   - targetDuration: 重复的时长（秒）
    ///   - outputPath: 输出文件路径
    /// - Returns: 长铃声文件路径
    private func mergeCAFFilesToDuration(inputFile: URL, targetDuration: TimeInterval, outputPath: URL) -> URL? {
        do {
            let audioFile = try AVAudioFile(forReading: inputFile)
            let audioFormat = audioFile.processingFormat
            let sampleRate = audioFormat.sampleRate
            let targetFrames = AVAudioFramePosition(targetDuration * sampleRate)
            var currentFrames: AVAudioFramePosition = 0
            let outputAudioFile = try AVAudioFile(forWriting: outputPath, settings: audioFormat.settings)
            
            // 交叉淡入淡出长度（约 20ms，减少循环时的杂音）
            let crossfadeFrames = AVAudioFramePosition(sampleRate * 0.02)
            var isFirstLoop = true
            
            while currentFrames < targetFrames {
                guard let buffer = AVAudioPCMBuffer(
                    pcmFormat: audioFormat,
                    frameCapacity: AVAudioFrameCount(audioFile.length)
                ) else {
                    return nil
                }
                
                try audioFile.read(into: buffer)
                
                let remainingFrames = targetFrames - currentFrames
                let isLastLoop = AVAudioFramePosition(buffer.frameLength) > remainingFrames
                
                if isLastLoop {
                    // 最后一次循环，截取剩余部分
                    let truncatedBuffer = AVAudioPCMBuffer(
                        pcmFormat: buffer.format,
                        frameCapacity: AVAudioFrameCount(remainingFrames)
                    )!
                    let channelCount = Int(buffer.format.channelCount)
                    for channel in 0..<channelCount {
                        let sourcePointer = buffer.floatChannelData![channel]
                        let destinationPointer = truncatedBuffer.floatChannelData![channel]
                        memcpy(
                            destinationPointer,
                            sourcePointer,
                            Int(remainingFrames) * MemoryLayout<Float>.size
                        )
                    }
                    truncatedBuffer.frameLength = AVAudioFrameCount(remainingFrames)
                    try outputAudioFile.write(from: truncatedBuffer)
                    break
                } else {
                    // 应用交叉淡入淡出以减少循环时的杂音（第一次循环不应用）
                    if !isFirstLoop && crossfadeFrames > 0 {
                        applyCrossfade(to: buffer, crossfadeFrames: crossfadeFrames, audioFormat: audioFormat)
                    }
                    
                    try outputAudioFile.write(from: buffer)
                    currentFrames += AVAudioFramePosition(buffer.frameLength)
                    isFirstLoop = false
                }
                
                audioFile.framePosition = 0
            }
            
            return outputPath
        } catch {
            print("LongSoundGenerator: Error processing CAF file: \(error)")
            return nil
        }
    }
    
    /// 应用交叉淡入淡出以减少循环时的杂音
    /// 使用正弦曲线实现更平滑的过渡
    private func applyCrossfade(to buffer: AVAudioPCMBuffer, crossfadeFrames: AVAudioFramePosition, audioFormat: AVAudioFormat) {
        let channelCount = Int(audioFormat.channelCount)
        let bufferLength = Int(buffer.frameLength)
        let crossfadeLength = Int(crossfadeFrames)
        
        guard crossfadeLength > 0 && crossfadeLength < bufferLength else {
            return
        }
        
        for channel in 0..<channelCount {
            guard let channelData = buffer.floatChannelData?[channel] else {
                continue
            }
            
            // 在开头应用淡入（使用正弦曲线，从 0 到 1）
            for i in 0..<crossfadeLength {
                let progress = Float(i) / Float(crossfadeLength)
                // 使用正弦曲线：sin(π/2 * progress)，从 0 平滑过渡到 1
                let fadeInFactor = sin(progress * Float.pi / 2.0)
                channelData[i] *= fadeInFactor
            }
            
            // 在结尾应用淡出（使用正弦曲线，从 1 到 0）
            let fadeOutStart = bufferLength - crossfadeLength
            for i in fadeOutStart..<bufferLength {
                let progress = Float(bufferLength - i) / Float(crossfadeLength)
                // 使用正弦曲线：sin(π/2 * progress)，从 1 平滑过渡到 0
                let fadeOutFactor = sin(progress * Float.pi / 2.0)
                channelData[i] *= fadeOutFactor
            }
        }
    }
}

