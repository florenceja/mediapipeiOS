# MediaPipe Landmarks iOS 项目

基于 MediaPipe Tasks 的 iOS 实时人脸和手势识别应用。

## 📁 项目说明

本仓库包含一个完整的 iOS 项目，实现了：
- 实时人脸关键点检测（468个关键点）
- 实时手势识别（21个关键点 + 预设手势识别）
- 精确的坐标转换（防止拉伸变形）

## 🚀 快速开始

### 项目位置

**正确的项目目录**: `MediaPipeLandmarksApp/`

```
MediaPipeLandmarksApp/
├── MediaPipeLandmarksApp.xcodeproj/   ← 在 Mac 上打开这个文件
└── MediaPipeLandmarksApp/             ← 源代码
```

### 在 Mac 上运行

```bash
# 1. 打开项目
cd MediaPipeLandmarksApp
open MediaPipeLandmarksApp.xcodeproj

# 2. 在 Xcode 中配置签名（Signing & Capabilities）
# 3. 选择设备并运行（⌘R）
```

### 从 Windows 传输到 Mac

如果你在 Windows 上开发，需要传输到 Mac：

1. **打包项目**
   ```bash
   # 压缩整个 MediaPipeLandmarksApp 文件夹
   # 或使用 Git 推送到远程仓库
   ```

2. **在 Mac 上获取**
   ```bash
   # 方式一：从 Git 克隆
   git clone <your-repo-url>
   
   # 方式二：解压缩文件
   unzip MediaPipeLandmarksApp.zip
   ```

3. **打开并运行**
   ```bash
   cd MediaPipeLandmarksApp
   open MediaPipeLandmarksApp.xcodeproj
   ```

详细步骤请查看 [MAC_SETUP.md](MAC_SETUP.md)

## 📚 文档

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 技术架构、API 文档、模块说明
- **[QUICKSTART.md](QUICKSTART.md)** - 安装和运行指南
- **[MAC_SETUP.md](MAC_SETUP.md)** - Windows 到 Mac 的完整迁移流程

## ✨ 功能特性

### 人脸识别
- 检测 468 个人脸关键点
- 实时绘制人脸网格
- 精确贴合，无拉伸变形

### 手势识别
- 检测 21 个手部关键点
- 识别预设手势：
  - Thumb_Up（竖起大拇指）
  - Victory（V字手势）
  - Open_Palm（张开手掌）
  - Closed_Fist（握拳）
  - Pointing_Up（食指指向上方）
  - ILoveYou（我爱你手势）
- 支持同时检测多只手

## 🛠️ 技术栈

- **语言**: Swift 5.0
- **框架**: UIKit, AVFoundation, MediaPipe Tasks Vision
- **最低支持**: iOS 15.0+
- **开发工具**: Xcode 14.0+

## 📋 系统要求

### 开发环境
- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- Command Line Tools

### 运行环境
- iOS 15.0 或更高版本
- iPhone 或 iPad（推荐真机测试）

## 🔧 常见问题

### 1. Xcode 无法打开项目

**解决方案**：
```bash
# 确保打开的是 .xcodeproj 文件
open MediaPipeLandmarksApp/MediaPipeLandmarksApp.xcodeproj
```

### 2. 编译错误：找不到 MediaPipeTasksVision

**解决方案**：
- 清理构建缓存：Product → Clean Build Folder (⌘⇧K)
- 需要通过 Swift Package Manager 添加 MediaPipe

### 3. 模型文件找不到

**解决方案**：
- 确认 `Models/` 目录下有两个 .task 文件
- 在 Xcode 中重新添加文件到项目

### 4. 真机运行失败

**解决方案**：
- 配置开发团队（Signing & Capabilities）
- 在设备上信任开发者证书：设置 → 通用 → VPN与设备管理

详细故障排查请查看 [MAC_SETUP.md](MAC_SETUP.md)

## 📂 项目结构

```
MediaPipeLandmarksApp/
├── MediaPipeLandmarksApp.xcodeproj/
│   └── project.pbxproj              # Xcode 项目配置
└── MediaPipeLandmarksApp/
    ├── AppDelegate.swift            # 应用入口
    ├── SceneDelegate.swift          # 场景管理
    ├── Info.plist                   # 配置文件（包含相机权限）
    ├── Controllers/                 # 视图控制器
    │   ├── MainViewController.swift
    │   ├── FaceDetectionViewController.swift
    │   └── HandGestureViewController.swift
    ├── Services/                    # MediaPipe 服务
    │   ├── CameraManager.swift
    │   ├── FaceLandmarkerService.swift
    │   └── GestureRecognizerService.swift
    ├── Views/                       # 自定义视图
    │   ├── FaceOverlayView.swift
    │   └── HandOverlayView.swift
    ├── Utils/                       # 工具类
    │   └── CoordinateTransformer.swift
    └── Models/                      # ML 模型
        ├── face_landmarker.task     # 3.6MB
        └── gesture_recognizer.task  # 8.4MB
```

## 🎯 使用说明

1. **启动应用**：在真机或模拟器上运行
2. **授权相机**：首次运行时允许相机访问
3. **选择功能**：
   - 点击 "Face Detection" 进入人脸识别
   - 点击 "Hand Gestures" 进入手势识别
4. **测试识别**：将人脸或手掌对准相机

## 📝 开发说明

### 关键技术点

1. **坐标转换**：使用 `CoordinateTransformer` 将归一化坐标转换为屏幕坐标
2. **相机管理**：`AVCaptureSession` + `AVCaptureVideoDataOutput`
3. **实时处理**：后台队列处理帧，主线程更新 UI
4. **性能优化**：帧率限制、丢弃延迟帧

### 扩展开发

- 添加新手势：替换 `gesture_recognizer.task` 模型
- 添加新功能：参考 MediaPipe Tasks 文档
- 自定义 UI：修改 `OverlayView` 绘制逻辑

## 📄 许可证

本项目使用 MediaPipe Tasks，遵循 Apache 2.0 许可证。

## 🙋 技术支持

遇到问题？
1. 查看 [DEVELOPMENT.md](DEVELOPMENT.md) 中的常见问题章节
2. 查看 [MAC_SETUP.md](MAC_SETUP.md) 中的故障排查指南
3. 检查 Xcode 控制台的错误日志

---

**注意**：旧的 `MediaPipeLandmarks/` 目录已废弃，请使用 `MediaPipeLandmarksApp/`。
