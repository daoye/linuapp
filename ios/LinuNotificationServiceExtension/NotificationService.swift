//
//  NotificationService.swift
//  LinuNotificationService
//
//  加密消息解密 + 富媒体通知处理 + 消息持久化
//

import UserNotifications
import CryptoKit
import Security
import Foundation

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private let appGroupId = "group.com.aprilzz.linu"
    private let keychainKeyId = "e2ee_aes_key"
    private let pendingMessagesKey = "pending_messages"
    
    // MARK: - 入口
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let content = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        let userInfo = content.userInfo
        let messageId = request.identifier
        let priority = extractPriority(from: content)
        // ringing 和 critical 都需要持续响铃
        let isRinging = priority == "ringing" || priority == "critical"
        
        if let zPayload = userInfo["z"] as? String {
            processEncryptedMessage(
                messageId: messageId,
                zPayload: zPayload,
                content: content,
                priority: priority,
                isRinging: isRinging
            )
            return
        }
        
        if let xPayload = userInfo["x"] as? String {
            processPlainMessage(
                messageId: messageId,
                xPayload: xPayload,
                content: content,
                priority: priority,
                isRinging: isRinging
            )
            return
        }
        
        // 未知格式，直接投递
        // 从自定义字段 "s" 中读取声音名称
        let sound = content.userInfo["s"] as? String
        deliverNotification(content: content, sound: sound, isRinging: isRinging)
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let handler = contentHandler, let content = bestAttemptContent {
            handler(content)
        }
    }
    
    // MARK: - 明文消息处理
    
    private func processPlainMessage(
        messageId: String,
        xPayload: String,
        content: UNMutableNotificationContent,
        priority: String,
        isRinging: Bool
    ) {
        let media = extractMediaFromArray(from: xPayload)
        // 从自定义字段 "s" 中读取声音名称
        let sound = content.userInfo["s"] as? String
        
        var messageData: [String: Any] = [
            "x": xPayload,
            "title": content.title,
            "text": content.body,
            "priority": priority
        ]
        
        if let sound = sound {
            messageData["sound"] = sound
        }
        
        saveMessage(id: messageId, data: messageData)
        
        deliverNotificationWithMedia(content: content, media: media, sound: sound, isRinging: isRinging)
    }
    
    // MARK: - 加密消息处理
    
    private func processEncryptedMessage(
        messageId: String,
        zPayload: String,
        content: UNMutableNotificationContent,
        priority: String,
        isRinging: Bool
    ) {
        guard let payload = decryptAndParse(zPayload) else {
            // 解密失败，显示本地化的友好提示（不设置标题）
            content.title = ""
            content.body = NSLocalizedString("encrypted_message_body", comment: "Encrypted message notification body")
            
            // 保存未解密的消息到待处理队列，Flutter 端会重试解密
            saveMessage(id: messageId, data: [
                "z": zPayload,
                "priority": priority
            ])
            
            // 投递通知
            deliverNotification(content: content, sound: nil, isRinging: isRinging)
            return
        }
        
        // 使用解密后的内容
        let decryptedTitle = payload["title"] as? String ?? ""
        let decryptedText = payload["text"] as? String ?? ""
        content.title = decryptedTitle
        content.body = decryptedText
        
        // 检查解密后的消息中的 priority（可能覆盖外层 priority）
        let msgPriority = (payload["priority"] as? String)?.lowercased() ?? priority
        // ringing 和 critical 都需要持续响铃
        let shouldRing = msgPriority == "ringing" || msgPriority == "critical"
        let sound = payload["sound"] as? String
        
        var messageData = payload
        messageData["_decrypted"] = true
        messageData["title"] = decryptedTitle
        messageData["text"] = decryptedText
        messageData["priority"] = msgPriority
        saveMessage(id: messageId, data: messageData)
        
        let media = extractMediaFromJson(payload)
        deliverNotificationWithMedia(content: content, media: media, sound: sound, isRinging: shouldRing)
    }
    
    // MARK: - 通知投递
    
    private func deliverNotification(content: UNMutableNotificationContent, sound: String?, isRinging: Bool) {
        deliverNotificationWithMedia(content: content, media: nil, sound: sound, isRinging: isRinging)
    }
    
    private func deliverNotificationWithMedia(
        content: UNMutableNotificationContent,
        media: MediaInfo?,
        sound: String?,
        isRinging: Bool
    ) {
        guard let handler = contentHandler else {
            return
        }
        
        // 设置通知声音
        // - 如果指定了 sound，查找匹配的音频文件
        // - ringing/critical 使用长铃声（30s），其他使用原始音频
        if let soundName = sound, !soundName.isEmpty {
            if let soundFileName = findSoundFile(named: soundName) {
                if isRinging {
                    // ringing/critical: 生成并使用 30s 长铃声
                    _ = LongSoundGenerator.shared.setLongSound(for: content, soundFileName: soundFileName)
                } else {
                    // 普通消息: 使用原始音频
                    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
                }
            }
        } else if isRinging {
            // 没有指定 sound 但是 ringing/critical，使用系统默认的长铃声
            _ = LongSoundGenerator.shared.setLongSound(for: content, soundFileName: nil)
        } else {
            // 普通消息没有指定 sound，使用系统默认声音
            content.sound = .default
        }
        
        guard let media = media else {
            handler(content)
            return
        }
        
        // 对于视频消息：
        // - 如果有缩略图，下载缩略图作为附件
        // - 如果没有缩略图，不下载任何附件（避免下载大视频文件导致延迟）
        if media.isVideo {
            if let thumbnailUrl = media.thumbnailUrl,
               !thumbnailUrl.isEmpty,
               let thumbnailURL = URL(string: thumbnailUrl) {
                // 有缩略图，下载缩略图
                let ext = getFileExtension(from: thumbnailURL)
                downloadFile(from: thumbnailURL, ext: ext) { localURL in
                    if let local = localURL, let attachment = try? UNNotificationAttachment(identifier: "", url: local) {
                        content.attachments = [attachment]
                    }
                    handler(content)
                }
            } else {
                // 没有缩略图，不下载任何附件，直接投递通知
                handler(content)
            }
            return
        }
        
        // 对于图片消息，下载图片作为附件
        guard let url = URL(string: media.url) else {
            handler(content)
            return
        }
        
        let ext = getFileExtension(from: url)
        downloadFile(from: url, ext: ext) { localURL in
            if let local = localURL, let attachment = try? UNNotificationAttachment(identifier: "", url: local) {
                content.attachments = [attachment]
            }
            handler(content)
        }
    }
    
    // MARK: - 数据提取
    
    private struct MediaInfo {
        let url: String
        let thumbnailUrl: String?
        let isVideo: Bool
    }
    
    /// 从 x 数组格式提取媒体信息
    /// 格式: [version, group_id, media, actions, detail, group_config]
    /// media: [type(0/1), url, thumbnail]
    private func extractMediaFromArray(from xPayload: String) -> MediaInfo? {
        guard let data = xPayload.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [Any],
              array.count > 2,
              let mediaArray = array[2] as? [Any],
              mediaArray.count > 1,
              let url = mediaArray[1] as? String, !url.isEmpty else {
            return nil
        }
        
        let isVideo = (mediaArray[0] as? Int) == 1
        let thumbnailUrl = mediaArray.count > 2 ? mediaArray[2] as? String : nil
        return MediaInfo(url: url, thumbnailUrl: thumbnailUrl, isVideo: isVideo)
    }
    
    /// 从 JSON 对象提取媒体信息
    private func extractMediaFromJson(_ json: [String: Any]) -> MediaInfo? {
        guard let mediaObj = json["media"] as? [String: Any],
              let url = mediaObj["url"] as? String, !url.isEmpty else {
            return nil
        }
        
        let isVideo = (mediaObj["type"] as? String) == "video"
        let thumbnailUrl = mediaObj["thumbnail_url"] as? String
        return MediaInfo(url: url, thumbnailUrl: thumbnailUrl, isVideo: isVideo)
    }
    
    /// 从通知内容提取优先级
    /// 优先从 userInfo["p"] 读取（数值），否则通过 content 属性推断
    private func extractPriority(from content: UNMutableNotificationContent) -> String {
        let userInfo = content.userInfo
        
        // 优先从 p 字段读取（数值：0=normal, 1=silent, 2=ringing, 3=critical）
        if let pValue = userInfo["p"] as? Int {
            switch pValue {
            case 1: return "silent"
            case 2: return "ringing"
            case 3: return "critical"
            default: return "normal"
            }
        }

        return "normal"
    }
    
    /// 从 URL 获取文件扩展名
    private func getFileExtension(from url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        return pathExtension.isEmpty ? "jpg" : pathExtension
    }
    
    /// 根据声音名称查找匹配的音频文件
    /// - Parameter soundName: 声音名称（不含扩展名）
    /// - Returns: 找到的声音文件名（包含扩展名），用于 UNNotificationSound
    private func findSoundFile(named soundName: String) -> String? {
        // 支持的音频格式（按优先级排序）
        let supportedExtensions = ["m4a", "caf", "wav", "aiff", "mp3"]
        
        // 移除可能存在的扩展名，只保留基础名称
        var baseName = soundName
        let parts = soundName.split(separator: ".")
        if parts.count >= 2 {
            let ext = String(parts.last!).lowercased()
            if supportedExtensions.contains(ext) {
                baseName = parts.dropLast().joined(separator: ".")
            }
        }
        
        // 获取 App Group 的 Library/Sounds 目录
        guard let soundsDirectoryUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        )?.appendingPathComponent("Library/Sounds") else {
            return nil
        }
        
        // 按优先级查找匹配的声音文件
        for ext in supportedExtensions {
            let fileName = "\(baseName).\(ext)"
            
            // 1. 在 App Group 的 Library/Sounds 目录中查找（用户自定义声音）
            let sharedSoundPath = soundsDirectoryUrl.appendingPathComponent(fileName).path
            if FileManager.default.fileExists(atPath: sharedSoundPath) {
                return fileName
            }
            
            // 2. 在 Bundle 中查找
            if Bundle.main.path(forResource: baseName, ofType: ext) != nil {
                return fileName
            }
        }
        
        return nil
    }
    
    // MARK: - 消息持久化
    
    private func saveMessage(id: String, data: [String: Any]) {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        
        var pending = defaults.array(forKey: pendingMessagesKey) as? [[String: Any]] ?? []
        if pending.contains(where: { ($0["id"] as? String) == id }) { return }
        
        var message = data
        message["id"] = id
        message["receivedAt"] = Date().timeIntervalSince1970
        
        pending.append(message)
        defaults.set(pending, forKey: pendingMessagesKey)
        defaults.synchronize()
    }
    
    // MARK: - 文件下载
    
    private func downloadFile(from url: URL, ext: String, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: url) { downloadedUrl, _, _ in
            guard let downloadedUrl = downloadedUrl else {
                completion(nil)
                return
            }
            
            do {
                let tmpFolder = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
                try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true)
                
                let fileURL = tmpFolder.appendingPathComponent("file.\(ext)")
                try FileManager.default.moveItem(at: downloadedUrl, to: fileURL)
                completion(fileURL)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - 解密
    
    private func decryptAndParse(_ encryptedBase64: String) -> [String: Any]? {
        guard let keyData = getEncryptionKey() else {
            return nil
        }
        
        guard let encryptedData = Data(base64Encoded: encryptedBase64),
              encryptedData.count >= 28 else {
            return nil
        }
        
        let nonce = encryptedData.prefix(12)
        let ciphertextWithTag = encryptedData.dropFirst(12)
        let ciphertext = ciphertextWithTag.dropLast(16)
        let tag = ciphertextWithTag.suffix(16)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(
                nonce: AES.GCM.Nonce(data: nonce),
                ciphertext: ciphertext,
                tag: tag
            )
            let decrypted = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
            return try JSONSerialization.jsonObject(with: decrypted) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    private func getEncryptionKey() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "flutter_secure_storage_service",
            kSecAttrAccount as String: keychainKeyId,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyBase64Data = result as? Data,
              let keyBase64 = String(data: keyBase64Data, encoding: .utf8),
              let keyData = Data(base64Encoded: keyBase64) else {
            return nil
        }
        
        return keyData
    }
    
}
