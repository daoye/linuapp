# Mobile App CI/CD Setup Guide

本文档说明如何配置 GitHub Actions 自动构建和发布 iOS/Android 应用到 App Store 和 Google Play。

## 前置要求

### Android 要求
1. Google Play Console 账号
2. 已创建应用并获得包名：`com.aprilzz.linu`
3. 生成 upload keystore（上传密钥库）
4. 创建 Google Play Service Account

### iOS 要求
1. Apple Developer 账号
2. 已在 App Store Connect 创建应用
3. 配置 Distribution Certificate 和 Provisioning Profile
4. 创建 App Store Connect API Key

## GitHub Secrets 配置

在 GitHub 仓库的 Settings → Secrets and variables → Actions 中添加以下 secrets：

### Android Secrets

#### 1. ANDROID_KEYSTORE_BASE64
生成 upload keystore 并转换为 base64：
```bash
# 生成 keystore（如果还没有）
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 转换为 base64
base64 -i upload-keystore.jks | pbcopy  # macOS
base64 -w 0 upload-keystore.jks         # Linux
```

#### 2. ANDROID_KEYSTORE_PASSWORD
keystore 的密码

#### 3. ANDROID_KEY_ALIAS
密钥别名（通常是 `upload`）

#### 4. ANDROID_KEY_PASSWORD
密钥密码

#### 5. GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
Google Play Service Account 的 JSON 密钥文件内容：

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建或选择项目
3. 启用 Google Play Android Developer API
4. 创建 Service Account
5. 下载 JSON 密钥文件
6. 在 Google Play Console 中授予该 Service Account 权限（Settings → API access）
7. 将整个 JSON 文件内容复制到 secret 中

### iOS Secrets

#### 1. IOS_CERTIFICATE_BASE64
Distribution Certificate (.p12) 的 base64 编码：

```bash
# 从 Keychain 导出证书为 .p12 文件
# 然后转换为 base64
base64 -i Certificates.p12 | pbcopy  # macOS
```

#### 2. IOS_CERTIFICATE_PASSWORD
导出 .p12 文件时设置的密码

#### 3. IOS_PROVISION_PROFILE_BASE64
Provisioning Profile (.mobileprovision) 的 base64 编码：

```bash
# 从 Apple Developer 下载 provisioning profile
# 然后转换为 base64
base64 -i YourProfile.mobileprovision | pbcopy
```

#### 3b. IOS_PROVISION_PROFILE_EXT_BASE64
LinuNotificationService 扩展 (bundle id: `com.aprilzz.linu.LinuNotificationService`) 的 Provisioning Profile (.mobileprovision) 的 base64 编码：

```bash
# 从 Apple Developer 为扩展创建 profile 并下载 .mobileprovision
base64 -i YourExtensionProfile.mobileprovision | pbcopy
```

#### 4. APP_STORE_CONNECT_API_KEY_ID
App Store Connect API Key ID

创建步骤：
1. 访问 [App Store Connect](https://appstoreconnect.apple.com/)
2. Users and Access → Keys → App Store Connect API
3. 点击 "+" 创建新 key
4. 记录 Key ID

#### 5. APP_STORE_CONNECT_API_ISSUER_ID
API Key 的 Issuer ID（在 Keys 页面顶部显示）

#### 6. APP_STORE_CONNECT_API_KEY_BASE64
下载的 .p8 API Key 文件的 base64 编码：

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

## iOS 配置文件修改

### 1. 更新 ExportOptions.plist

编辑 `ios/ExportOptions.plist`，替换以下内容：

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- 替换为你的 Team ID -->

<key>provisioningProfiles</key>
<dict>
    <key>com.aprilzz.linu</key>
    <string>YOUR_PROVISIONING_PROFILE_NAME</string>  <!-- 替换为你的 Provisioning Profile 名称 -->
</dict>
```

### 2. 确认 Bundle Identifier

确保 `ios/Runner.xcodeproj/project.pbxproj` 中的 Bundle Identifier 为：
```
PRODUCT_BUNDLE_IDENTIFIER = com.aprilzz.linu;
```

## Android 配置

### 1. 确认 applicationId

确保 `android/app/build.gradle` 中的 applicationId 为：
```gradle
applicationId "com.aprilzz.linu"
```

### 2. 配置签名

确保 `android/app/build.gradle` 包含签名配置：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 触发构建

### 自动触发
- 推送到 `main` 分支：构建但不发布
- 创建 tag（如 `v1.0.1`）：构建并自动发布到 App Store 和 Google Play

### 手动触发
在 GitHub Actions 页面点击 "Run workflow" 按钮

## CI/CD 特性

### 最新更新 (2025)
- ✅ 使用最新的 GitHub Actions (v4/v2)
- ✅ 并发控制：自动取消重复的构建
- ✅ 自动生成 Release Notes
- ✅ 使用 `apple-actions/upload-testflight-build` 上传 iOS
- ✅ 使用 `r0adkll/upload-google-play@v1.1.3` 上传 Android
- ✅ Release 构建强制验证签名密钥

### Android 流程
- ✅ 自动构建 APK（用于测试）
- ✅ 自动构建 AAB（用于 Play Store）
- ✅ 自动上传到 Google Play Internal Testing
- ✅ 上传构建产物到 GitHub Release
- ✅ 支持设置应用内更新优先级

### iOS 流程
- ✅ 自动配置证书和 Provisioning Profile
- ✅ 自动构建 IPA
- ✅ 自动上传到 TestFlight
- ✅ 上传构建产物到 GitHub Release
- ✅ 支持提交审核

## 发布流程

### Android
1. 推送 tag 触发 CI
2. 自动构建 APK 和 AAB
3. 自动上传 AAB 到 Google Play Internal Testing track
4. 在 Google Play Console 中将应用从 Internal Testing 推广到 Production

### iOS
1. 推送 tag 触发 CI
2. 自动构建 IPA
3. 自动上传到 App Store Connect
4. 在 App Store Connect 中提交审核

## 版本号管理

版本号在 `pubspec.yaml` 中定义：
```yaml
version: 1.0.1+2
```
- `1.0.1` 是版本名称（versionName/CFBundleShortVersionString）
- `2` 是构建号（versionCode/CFBundleVersion）

创建 tag 时使用版本名称：
```bash
git tag v1.0.1
git push origin v1.0.1
```

## 故障排查

### Android 构建失败
- 检查 keystore 密码是否正确
- 确认 Google Play Service Account 有正确权限
- 查看 build.gradle 中的签名配置

### iOS 构建失败
- 确认 Certificate 和 Provisioning Profile 匹配
- 检查 Team ID 和 Bundle Identifier
- 确认 API Key 权限正确

### 上传失败
- Android: 确认 Service Account 在 Google Play Console 中已授权
- iOS: 确认 API Key 有 "App Manager" 或 "Admin" 权限

## 环境配置

在 GitHub 仓库中创建 Environment：
1. Settings → Environments → New environment
2. 名称：`MOBILE_RELEASE`
3. 添加保护规则（可选）：
   - Required reviewers（需要审核）
   - Wait timer（等待时间）
   - Deployment branches（限制分支）

## 更新日志

更新 `android/whatsnew/` 目录下的文件来自定义 Google Play 的更新说明：
- `whatsnew-en-US`：英文更新说明
- `whatsnew-zh-CN`：中文更新说明

支持的语言代码参考：[Google Play 支持的语言](https://support.google.com/googleplay/android-developer/answer/9844778)
