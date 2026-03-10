# MediaPipe Landmarks iOS App

基于 MediaPipe Tasks 的 iOS 实时人脸和手势识别应用。

## 项目结构

```
MediaPipeLandmarksApp/
├── MediaPipeLandmarksApp.xcodeproj/   # Xcode 项目文件
│   └── project.pbxproj
└── MediaPipeLandmarksApp/             # 源代码目录
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    ├── Info.plist
    ├── Controllers/                   # 视图控制器
    │   ├── MainViewController.swift
    │   ├── FaceDetectionViewController.swift
    │   └── HandGestureViewController.swift
    ├── Services/                      # MediaPipe 服务
    │   ├── CameraManager.swift
    │   ├── FaceLandmarkerService.swift
    │   └── GestureRecognizerService.swift
    ├── Views/                         # 自定义视图
    │   ├── FaceOverlayView.swift
    │   └── HandOverlayView.swift
    ├── Utils/                         # 工具类
    │   └── CoordinateTransformer.swift
    └── Models/                        # ML 模型文件
        ├── face_landmarker.task       # 3.6MB
        └── gesture_recognizer.task    # 8.4MB
```

## 功能特性

- ✅ 实时人脸关键点检测（468个关键点）
- ✅ 实时手势识别（21个关键点 + 预设手势）
- ✅ 精确的坐标转换（无拉伸变形）
- ✅ 支持 iOS 15.0+
- ✅ 纯 Swift 实现，无第三方依赖

## 快速开始

### 在 Mac 上运行

1. **打开项目**
   ```bash
   cd MediaPipeLandmarksApp
   open MediaPipeLandmarksApp.xcodeproj
   ```

2. **配置签名**
   - 在 Xcode 中选择项目 → Signing & Capabilities
   - 添加你的 Apple ID
   - 选择开发团队

3. **运行**
   - 选择目标设备（模拟器或真机）
   - 点击运行按钮（⌘R）

### 从 Windows 传输到 Mac

详见 [MAC_SETUP.md](../MAC_SETUP.md)

## 文档

- [开发文档](../DEVELOPMENT.md) - 技术架构、API 文档
- [快速开始](../QUICKSTART.md) - 安装和运行指南
- [Mac 迁移指南](../MAC_SETUP.md) - Windows 到 Mac 的完整迁移流程

## 系统要求

- **开发环境**: macOS 12.0+, Xcode 14.0+
- **运行环境**: iOS 15.0+
- **硬件**: iPhone/iPad 或模拟器

## 支持的手势

- Thumb_Up（竖起大拇指）
- Victory（V字手势）
- Open_Palm（张开手掌）
- Closed_Fist（握拳）
- Pointing_Up（食指指向上方）
- ILoveYou（我爱你手势）

## 许可证

本项目使用 MediaPipe Tasks，遵循 Apache 2.0 许可证。
