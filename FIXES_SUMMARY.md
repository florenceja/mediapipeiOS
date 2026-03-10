# MediaPipe iOS 项目修复完成总结

## 已修复的问题

### 1. 代码错误修复

#### FaceOverlayView.swift
- **第 38 行**：`FaceLandmarksConnections.connections()` → `FaceLandmarker.faceConnections()`
  - 根据 MediaPipe Tasks Vision v0.10.0+ API，连接常量现由 Task 类直接提供

#### HandOverlayView.swift
- **第 40 行**：`HandLandmarksCo()` → `HandLandmarker.handConnections`
  - 修复了不完整的函数名，使用正确的 API
- **第 87 行**：`Category.categoryName` → `Category.displayName`
  - 修复了获取类别名称的属性名

### 2. 项目配置修复
- 移除了无效的 `[CP] Check Pods Manifest.lock` build phase
- 移除了 `Pods-MediaPipeLandmarksApp.debug/release.xcconfig` 引用
- 清理了所有与 CocoaPods 相关的配置（项目实际应使用 SPM 或 CocoaPods，但配置需一致）

### 3. 文档更新

#### QUICKSTART.md
- 添加了完整的 MediaPipe SPM 安装流程（方案三）
- 添加了 CocoaPods 安装说明（官方推荐方式）
- 添加了常见问题 Q&A（网络超时、No such module、版本冲突）
- 更新了调试工具说明（View Hierarchy、Memory Graph、LLDB 命令）

#### MAC_SETUP.md
- 添加了 iOS 16+ 开发者模式开启步骤
- 统一了项目路径为 `MediaPipeLandmarksApp/`
- 更新了 Bundle Identifier 为 `com.example.MediaPipeLandmarksApp`

#### README.md
- 添加了 iOS 16+ 开发者模式注意事项

## 在 Mac 上运行项目的完整步骤

### 步骤 1：打开项目
```bash
cd MediaPipeLandmarksApp
```

### 步骤 2：安装 CocoaPods 依赖（官方推荐）

```bash
# 如果未安装 CocoaPods
sudo gem install cocoapods

# 安装依赖
pod install

# 打开 workspace（注意：必须使用 .xcworkspace）
open MediaPipeLandmarksApp.xcworkspace
```

**重要**：使用 CocoaPods 后，必须打开 `.xcworkspace` 文件，而不是 `.xcodeproj` 文件！

### 步骤 3：配置签名
1. 选择项目根节点 → Signing & Capabilities
2. 勾选 Automatically manage signing
3. 选择 Team（Apple ID）

### 步骤 4：编译运行
1. Command + Shift + K（清理构建）
2. Command + B（编译）
3. 选择设备/模拟器
4. Command + R（运行）

### 步骤 5：iOS 16+ 真机调试（如使用真机）
1. 设备上开启开发者模式：设置 → 隐私与安全性 → 开发者模式
2. 信任开发者证书：设置 → 通用 → VPN 与设备管理

### 备选方案：Swift Package Manager

如果 CocoaPods 遇到问题，可以使用 SPM：

1. 删除 CocoaPods 相关文件：
   ```bash
   rm -rf Pods Podfile Podfile.lock MediaPipeLandmarksApp.xcworkspace
   ```

2. 在 Xcode 中添加 SPM 依赖：
   - File → Add Package Dependencies...
   - 输入：`https://github.com/google-ai-edge/mediapipe.git`
   - 版本：`0.10.0`
   - 勾选：`MediaPipeTasksVision`
   - 点击 Add Package

3. 清理并编译：
   - Command + Shift + K
   - Command + B

## API 对照表

| 旧 API（错误） | 新 API（正确） |
| :--- | :--- |
| `FaceLandmarksConnections.connections()` | `FaceLandmarker.faceConnections()` |
| `HandLandmarksConnections.connections()` | `HandLandmarker.handConnections` |
| `Category.categoryName` | `Category.displayName` |

## 参考文档
- [MediaPipe Face Landmarker iOS](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker/ios)
- [MediaPipe Hand Landmarker API](https://ai.google.dev/edge/api/mediapipe/swift/vision/Classes/HandLandmarkerResult)
- [MediaPipe Tasks Vision CocoaPods](https://cocoapods.org/pods/MediaPipeTasksVision)
