# MediaPipeLandmarks 快速开始

## 环境要求

### 硬件要求
- Mac 电脑 (macOS 12.0 或更高版本)
- iPhone 或 iPad (iOS 15.0 或更高版本)，或使用模拟器

### 软件要求
- **Xcode**: 14.0 或更高版本
- **Command Line Tools**: 已安装 Xcode Command Line Tools
- **Git**: 用于克隆项目 (可选)

### 检查环境

```bash
# 检查 Xcode 版本
xcodebuild -version

# 检查 Command Line Tools
xcode-select -p

# 如果未安装，执行以下命令安装
xcode-select --install
```

## 安装步骤

### 1. 获取项目

**方式一：直接使用现有项目**
```bash
# 项目已在当前目录
cd D:\study\mediapipe_iOS
```

**方式二：从 Git 克隆 (如果需要)**
```bash
git clone <repository-url>
cd mediapipe_iOS
```

### 2. 验证项目结构

```bash
# 检查项目文件
ls -la

# 应该看到以下文件和目录：
# MediaPipeLandmarks/              - 项目目录
# face_landmarker.task             - 人脸识别模型 (3.6MB)
# gesture_recognizer.task          - 手势识别模型 (8.4MB)
# DEVELOPMENT.md                   - 开发文档
# QUICKSTART.md                    - 本文档
```

### 3. 打开项目

```bash
# 使用 Xcode 打开项目
open MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj
```

或者：
- 双击 `MediaPipeLandmarks.xcodeproj` 文件
- 在 Xcode 中选择 File → Open，选择 `.xcodeproj` 文件

## 配置项目

### 1. 配置开发团队 (真机调试必需)

1. 在 Xcode 中选择项目根节点 `MediaPipeLandmarks`
2. 选择 `TARGETS` → `MediaPipeLandmarks`
3. 切换到 `Signing & Capabilities` 标签
4. 勾选 `Automatically manage signing`
5. 在 `Team` 下拉菜单中选择你的 Apple ID 或开发团队

### 2. 修改 Bundle Identifier (如果需要)

如果自动签名失败，修改 Bundle Identifier：
1. 在 `Signing & Capabilities` 中找到 `Bundle Identifier`
2. 修改为唯一标识符，例如：`com.yourname.MediaPipeLandmarks`

### 3. 验证模型文件

确保模型文件已正确添加到项目：
1. 在 Xcode 左侧导航栏中展开 `MediaPipeLandmarks` → `Models`
2. 应该看到：
   - `face_landmarker.task`
   - `gesture_recognizer.task`
3. 如果文件显示为红色，右键点击 → `Show in Finder`，确认文件存在
4. 如果文件不存在，从项目根目录拖拽到 `Models` 文件夹

## 运行项目

### 方式一：使用模拟器 (推荐用于快速测试)

1. 在 Xcode 顶部工具栏选择目标设备：
   - 点击设备选择器 (默认显示 "iPhone 15 Pro" 或类似)
   - 选择任意 iOS 15.0+ 模拟器

2. 点击运行按钮 (▶️) 或按快捷键：
   ```
   Command + R
   ```

3. 等待编译完成，模拟器会自动启动应用

**注意**: 模拟器无法使用真实相机，会显示黑屏或模拟画面。

### 方式二：使用真机 (推荐用于完整测试)

1. 使用 USB 线连接 iPhone/iPad 到 Mac

2. 在设备上信任此电脑：
   - 设备会弹出 "信任此电脑？" 提示
   - 点击 "信任"

3. 在 Xcode 顶部工具栏选择你的设备：
   - 点击设备选择器
   - 选择你的 iPhone/iPad (显示设备名称)

4. 点击运行按钮 (▶️) 或按快捷键：
   ```
   Command + R
   ```

5. 首次运行需要在设备上信任开发者：
   - 打开设备 `设置` → `通用` → `VPN与设备管理`
   - 找到你的开发者账号，点击 "信任"

6. 返回 Xcode，再次运行项目

### 使用命令行运行 (高级)

```bash
# 列出可用设备
xcrun xctrace list devices

# 编译项目
xcodebuild -project MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj \
           -scheme MediaPipeLandmarks \
           -configuration Debug \
           build

# 运行到模拟器
xcodebuild -project MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj \
           -scheme MediaPipeLandmarks \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           build
```

## 使用应用

### 主界面

应用启动后会显示主界面，包含两个按钮：
- **Face Detection**: 进入人脸识别界面
- **Hand Gestures**: 进入手势识别界面

### 人脸识别功能

1. 点击 "Face Detection" 按钮
2. 授权相机权限 (首次使用会弹出提示)
3. 将人脸对准相机
4. 应用会实时显示：
   - 468 个人脸关键点 (橙色圆点)
   - 人脸网格连接线 (蓝色线条)

### 手势识别功能

1. 点击 "Hand Gestures" 按钮
2. 授权相机权限 (如果尚未授权)
3. 将手掌对准相机
4. 应用会实时显示：
   - 21 个手部关键点 (橙色圆点)
   - 手部骨架连接线 (蓝色线条)
   - 识别到的手势名称 (红色文字)

### 支持的手势

MediaPipe 预设手势包括：
- **Thumb_Up**: 竖起大拇指
- **Thumb_Down**: 大拇指向下
- **Victory**: V 字手势 (剪刀手)
- **Open_Palm**: 张开手掌
- **Closed_Fist**: 握拳
- **Pointing_Up**: 食指指向上方
- **ILoveYou**: 我爱你手势

## 常见问题

### 1. 编译错误：找不到 MediaPipeTasksVision

**问题**: `import MediaPipeTasksVision` 报错

**解决方案**:
```bash
# 方案一：清理构建缓存
Command + Shift + K (Clean Build Folder)

# 方案二：重置 Xcode 派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 方案三：检查是否需要安装 MediaPipe framework
# 本项目应该已包含，如果缺失，需要从 MediaPipe 官方下载
```

### 2. 相机权限被拒绝

**问题**: 应用无法访问相机

**解决方案**:
1. 打开设备 `设置` → `隐私与安全性` → `相机`
2. 找到 `MediaPipeLandmarks`，开启权限
3. 重启应用

### 3. 模型文件找不到

**问题**: 运行时报错 "gesture_recognizer.task not found in bundle"

**解决方案**:
1. 确认模型文件在项目根目录：
   ```bash
   ls -la face_landmarker.task gesture_recognizer.task
   ```

2. 在 Xcode 中重新添加文件：
   - 右键点击 `Models` 文件夹 → `Add Files to "MediaPipeLandmarks"`
   - 选择 `face_landmarker.task` 和 `gesture_recognizer.task`
   - 勾选 `Copy items if needed`
   - 勾选 `MediaPipeLandmarks` target
   - 点击 `Add`

### 4. 真机运行失败：开发者证书问题

**问题**: "Failed to code sign" 或 "Untrusted Developer"

**解决方案**:
1. 确保在 Xcode 中配置了开发团队
2. 在设备上信任开发者证书 (见上文 "使用真机" 步骤 5)
3. 如果使用免费 Apple ID，每 7 天需要重新签名

### 5. 画面拉伸或关键点不准

**问题**: 人脸被拉长/压扁，关键点位置不对

**解决方案**:
- 这是坐标转换问题，已在代码中处理
- 如果仍有问题，检查 `CoordinateTransformer.swift` 中的 `scaleFactor` 计算
- 确保使用 `max(widthScale, heightScale)` 匹配 `.resizeAspectFill`

### 6. 性能问题：帧率低或卡顿

**解决方案**:
1. 使用真机测试 (模拟器性能较差)
2. 降低检测频率：
   ```swift
   // 在 ViewController 中添加帧率限制
   guard currentTimestamp - lastTimestamp >= 33 else { return }  // ~30fps
   ```
3. 减少同时检测的人脸/手数：
   ```swift
   service.numFaces = 1  // 只检测一张人脸
   service.numHands = 1  // 只检测一只手
   ```

## 调试技巧

### 查看日志

在 Xcode 底部的控制台 (Console) 中查看日志输出：
```
Command + Shift + Y (显示/隐藏控制台)
```

### 断点调试

1. 在代码行号左侧点击，添加断点
2. 运行应用，触发断点时会暂停
3. 使用调试工具栏：
   - Continue (F6): 继续执行
   - Step Over (F7): 单步跳过
   - Step Into (F8): 单步进入

### 性能分析

```bash
# 使用 Instruments 分析性能
Command + I (Profile)

# 选择分析模板：
# - Time Profiler: CPU 使用率
# - Allocations: 内存分配
# - Leaks: 内存泄漏
```

## 下一步

### 学习资源

- **MediaPipe 官方文档**: https://developers.google.com/mediapipe
- **iOS 开发文档**: https://developer.apple.com/documentation/
- **项目开发文档**: 查看 `DEVELOPMENT.md`

### 自定义开发

1. 修改 UI 样式：编辑 `ViewController` 和 `OverlayView`
2. 调整检测参数：修改 `Service` 类中的置信度阈值
3. 添加新功能：参考 `DEVELOPMENT.md` 中的扩展开发章节

## 技术支持

如遇到问题：
1. 查看 `DEVELOPMENT.md` 中的常见问题章节
2. 检查 Xcode 控制台的错误日志
3. 确认 iOS 版本和 Xcode 版本符合要求

## 更新日志

- **v1.0.0** (2026-03-10): 初始版本
  - 实现人脸关键点识别 (468 点)
  - 实现手势识别 (21 点 + 预设手势)
  - 支持 iOS 15.0+
