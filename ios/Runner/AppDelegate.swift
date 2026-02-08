import Flutter
import UIKit
import AVFoundation
import AVKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  private var audioPlayer: AVAudioPlayer?
  private var ringtoneTimer: Timer?
  private var messagesChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 配置音频会话（支持后台播放）
    configureAudioSession()
    
    // 设置 UNUserNotificationCenter delegate
    UNUserNotificationCenter.current().delegate = self
    
    if let controller = window?.rootViewController as? FlutterViewController {
      // 消息 Channel
      messagesChannel = FlutterMethodChannel(
        name: "com.aprilzz.linu/messages",
        binaryMessenger: controller.binaryMessenger
      )
      messagesChannel?.setMethodCallHandler { call, result in
        self.handleMessagesMethod(call: call, result: result)
      }
      
      // 响铃 Channel
      let ringtoneChannel = FlutterMethodChannel(
        name: "com.aprilzz.linu/ringtone",
        binaryMessenger: controller.binaryMessenger
      )
      ringtoneChannel.setMethodCallHandler { call, result in
        self.handleRingtoneMethod(call: call, result: result)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - UNUserNotificationCenterDelegate
  
  /// 当通知在前台显示时调用
  /// 这是系统级别的回调，无论 Extension 是否处理了消息，都会触发
  /// 这确保了当 app 在前台时，Extension 保存的消息能够被及时导入
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // 通知 Flutter 端导入待处理消息
    // 使用异步调用，不等待结果，避免阻塞通知显示
    messagesChannel?.invokeMethod("importPendingMessages", arguments: nil, result: { _ in })
    
    // 调用父类实现，确保 Firebase 的处理逻辑也能执行
    super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
  
  /// 当用户点击通知时调用
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // 通知请求的 identifier 就是服务端生成的消息 ID
    let messageId = response.notification.request.identifier
    messagesChannel?.invokeMethod("handleNotificationTap", arguments: ["id": messageId])
    
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // 应用回到前台时停止响铃
    stopRinging()
  }
  
  // MARK: - 音频会话配置
  
  private func configureAudioSession() {
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try session.setActive(true)
    } catch {
      print("Failed to configure audio session: \(error)")
    }
  }
  
  // MARK: - 响铃控制
  
  private func handleRingtoneMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startRinging":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
        return
      }
      
      let title = args["title"] as? String ?? "紧急消息"
      let body = args["body"] as? String ?? ""
      let sound = args["sound"] as? String
      
      startRinging(title: title, body: body, sound: sound)
      result(true)
      
    case "stopRinging":
      stopRinging()
      result(true)
      
    case "isRinging":
      result(audioPlayer?.isPlaying ?? false)
      
    case "getCustomAudios":
      getCustomAudios(result: result)
      
    case "trimAudio":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
        return
      }
      trimAudio(args: args, result: result)
      
    case "getAudioDuration":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing filePath", details: nil))
        return
      }
      getAudioDuration(filePath: filePath, result: result)
      
default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startRinging(title: String, body: String, sound: String?) {
    stopRinging() // 先停止之前的响铃
    
    // 配置音频会话为后台播放
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [])
      try session.setActive(true)
    } catch {
      print("Audio session error: \(error)")
    }
    
    // 获取音频文件
    var soundURL: URL?
    
    if let soundName = sound, !soundName.isEmpty {
      // 尝试自定义声音
      let cleanName = soundName.replacingOccurrences(of: "\\.(mp3|wav|caf|aiff)$", with: "", options: .regularExpression)
      soundURL = Bundle.main.url(forResource: cleanName, withExtension: "mp3")
        ?? Bundle.main.url(forResource: cleanName, withExtension: "wav")
        ?? Bundle.main.url(forResource: cleanName, withExtension: "caf")
    }
    
    // 回退到默认铃声
    if soundURL == nil {
      // 使用系统铃声
      soundURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/alarm.caf")
    }
    
    guard let url = soundURL else {
      print("No sound file available")
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1 // 无限循环
      audioPlayer?.volume = 1.0
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
      
      print("Ringtone started: \(url)")
      
      // 设置最大响铃时间（60秒后自动停止）
      ringtoneTimer?.invalidate()
      ringtoneTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
        self?.stopRinging()
      }
      
    } catch {
      print("Failed to play sound: \(error)")
    }
  }
  
  private func stopRinging() {
    ringtoneTimer?.invalidate()
    ringtoneTimer = nil
    
    audioPlayer?.stop()
    audioPlayer = nil
    
    print("Ringtone stopped")
  }
  
  // MARK: - 音频管理
  
  private func getCustomAudios(result: @escaping FlutterResult) {
    guard let soundsDirectoryUrl = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.aprilzz.linu"
    )?.appendingPathComponent("Library/Sounds") else {
      result([])
      return
    }
    
    do {
      if !FileManager.default.fileExists(atPath: soundsDirectoryUrl.path) {
        try FileManager.default.createDirectory(
          at: soundsDirectoryUrl,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }
      
      let files = try FileManager.default.contentsOfDirectory(
        at: soundsDirectoryUrl,
        includingPropertiesForKeys: nil,
        options: .skipsHiddenFiles
      )
      
      let audioExtensions = ["mp3", "wav", "caf", "m4a", "aac", "ogg"]
      // 过滤掉自动生成的 30 秒循环音频（以 linu.sounds.30s. 为前缀）
      let audioFiles = files.filter { 
        audioExtensions.contains($0.pathExtension.lowercased()) &&
        !$0.lastPathComponent.hasPrefix("linu.sounds.30s.")
      }
      
      var resultArr: [[String: Any]] = []
      for file in audioFiles {
        let duration = getAudioDurationSync(filePath: file.path)
        
        // 获取文件修改时间
        var modifiedTime: Double = 0
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
           let modificationDate = attributes[.modificationDate] as? Date {
          modifiedTime = modificationDate.timeIntervalSince1970 * 1000 // 转换为毫秒
        }
        
        resultArr.append([
          "path": file.path,
          "name": file.lastPathComponent,
          "duration": duration,
          "modifiedTime": modifiedTime
        ])
      }
      
      result(resultArr)
    } catch {
      print("Failed to get custom audios: \(error)")
      result([])
    }
  }
  
  private func getAudioDuration(filePath: String, result: @escaping FlutterResult) {
    let duration = getAudioDurationSync(filePath: filePath)
    result(duration)
  }
  
  private func getAudioDurationSync(filePath: String) -> Double {
    let url = URL(fileURLWithPath: filePath)
    let asset = AVAsset(url: url)
    return CMTimeGetSeconds(asset.duration)
  }
  
  private func trimAudio(args: [String: Any], result: @escaping FlutterResult) {
    guard let sourcePath = args["sourcePath"] as? String,
          let startTime = args["startTime"] as? Double,
          let endTime = args["endTime"] as? Double,
          let outputPath = args["outputPath"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }
    
    let sourceURL = URL(fileURLWithPath: sourcePath)
    let asset = AVAsset(url: sourceURL)
    
    guard let soundsDirectoryUrl = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.aprilzz.linu"
    )?.appendingPathComponent("Library/Sounds") else {
      result(FlutterError(code: "NO_DIRECTORY", message: "Cannot access sounds directory", details: nil))
      return
    }
    
    do {
      if !FileManager.default.fileExists(atPath: soundsDirectoryUrl.path) {
        try FileManager.default.createDirectory(
          at: soundsDirectoryUrl,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }
    } catch {
      result(FlutterError(code: "CREATE_DIR_FAILED", message: error.localizedDescription, details: nil))
      return
    }
    
    let outputURL = soundsDirectoryUrl.appendingPathComponent(outputPath).appendingPathExtension("m4a")
    
    if FileManager.default.fileExists(atPath: outputURL.path) {
      try? FileManager.default.removeItem(at: outputURL)
    }
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
      result(FlutterError(code: "EXPORT_SESSION_FAILED", message: "Cannot create export session", details: nil))
      return
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .m4a
    
    let start = CMTime(seconds: startTime, preferredTimescale: 600)
    let end = CMTime(seconds: endTime, preferredTimescale: 600)
    let timeRange = CMTimeRange(start: start, end: end)
    exportSession.timeRange = timeRange
    
    exportSession.exportAsynchronously {
      DispatchQueue.main.async {
        switch exportSession.status {
        case .completed:
          result(outputURL.path)
        case .failed:
          result(FlutterError(
            code: "EXPORT_FAILED",
            message: exportSession.error?.localizedDescription ?? "Unknown error",
            details: nil
          ))
        case .cancelled:
          result(FlutterError(code: "EXPORT_CANCELLED", message: "Export cancelled", details: nil))
        default:
          result(FlutterError(code: "EXPORT_UNKNOWN", message: "Unknown export status", details: nil))
        }
      }
    }
  }
  
  // MARK: - App Group 消息处理
  
  private func handleMessagesMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let groupId = args["groupId"] as? String,
          let key = args["key"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing groupId or key", details: nil))
      return
    }
    
    guard let defaults = UserDefaults(suiteName: groupId) else {
      result(FlutterError(code: "APP_GROUP_ERROR", message: "Cannot access App Group", details: nil))
      return
    }
    
    switch call.method {
    case "getPendingMessages":
      let messages = defaults.array(forKey: key) as? [[String: Any]] ?? []
      result(messages)
      
    case "removePendingMessages":
      guard let idsToRemove = args["ids"] as? [String] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing ids", details: nil))
        return
      }
      
      var messages = defaults.array(forKey: key) as? [[String: Any]] ?? []
      messages.removeAll { msg in
        guard let id = msg["id"] as? String else { return false }
        return idsToRemove.contains(id)
      }
      defaults.set(messages, forKey: key)
      defaults.synchronize()
      result(true)
      
    case "clearPendingMessages":
      defaults.removeObject(forKey: key)
      defaults.synchronize()
      result(true)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
