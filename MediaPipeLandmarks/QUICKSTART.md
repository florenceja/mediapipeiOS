# MediaPipe Landmarks iOS - 快速开始

## 环境要求

- **macOS**: 12.0 或更高版本
- **Xcode**: 14.0 或更高版本
- **iOS**: 15.0 或更高版本 (真机或模拟器)
- **MediaPipe Tasks Vision**: 需确保项目中已包含 `MediaPipeTasksVision` 框架（如果未包含，请通过 CocoaPods 或 SPM 添加，本项目代码已适配其 API）。

## 安装步骤

1. **克隆项目**
   将本项目克隆到本地目录：
   ```bash
   git clone <repository_url>
   cd MediaPipeLandmarks
   ```

2. **模型文件**
   确保 `face_landmarker.task` 和 `gesture_recognizer.task` 模型文件已放置在 `MediaPipeLandmarks/Models/` 目录下。本项目已预置这些文件。

3. **打开项目**
   双击 `MediaPipeLandmarks.xcodeproj` 文件，在 Xcode 中打开项目。

## 运行步骤

1. **选择运行目标**
   在 Xcode 顶部工具栏中，选择一个 iOS 模拟器（如 iPhone 14 Pro）或连接的 iOS 真机设备。

2. **配置签名 (仅真机)**
   如果使用真机调试，请在项目设置的 `Signing & Capabilities` 选项卡中，选择您的 Apple Developer 团队，并确保 Bundle Identifier 唯一。

3. **编译并运行**
   点击 Xcode 左上角的 **Run** 按钮（或按 `Cmd + R`）。
   - 首次运行会提示相机权限请求，请点击“允许”。
   - 在主界面选择“Face Landmarks”或“Hand Gestures”进入对应的识别界面。

## 常见问题

### 1. 编译错误：找不到 `MediaPipeTasksVision`
**原因**：本项目代码依赖 MediaPipe Tasks Vision iOS API，但未配置依赖管理工具。
**解决**：请根据您的项目需求，手动将 `MediaPipeTasksVision.framework` 拖入项目中，或使用 CocoaPods/SPM 进行安装。

### 2. 运行时崩溃：找不到模型文件
**原因**：`face_landmarker.task` 或 `gesture_recognizer.task` 未正确打包到 App Bundle 中。
**解决**：在 Xcode 中选中模型文件，确保在右侧的 File Inspector 中勾选了 Target Membership 下的 `MediaPipeLandmarks`。

### 3. 画面拉伸或关键点错位
**原因**：坐标转换逻辑未正确处理视频流的缩放模式。
**解决**：本项目已在 `CoordinateTransformer` 中处理了 `.resizeAspectFill` 的缩放和偏移，确保 `CameraManager` 中的 `videoGravity` 与 `CoordinateTransformer` 中的 `contentMode` 保持一致。

### 4. 相机黑屏
**原因**：未授予相机权限，或在不支持相机的模拟器上运行。
**解决**：请在真机上运行，或在 `Info.plist` 中检查 `NSCameraUsageDescription` 是否配置正确。
