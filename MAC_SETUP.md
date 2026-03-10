# 从 Windows 迁移到 Mac 运行调试指南

## 概述

本指南帮助你将在 Windows 上创建的 MediaPipeLandmarks iOS 项目迁移到 Mac 上进行开发和调试。

## 前置准备

### 在 Windows 上

#### 1. 打包项目文件

```powershell
# 在 Windows PowerShell 或 CMD 中执行

# 方式一：使用 Git（推荐）
cd D:\study\mediapipe_iOS
git init
git add .
git commit -m "Initial commit"

# 推送到 GitHub/GitLab（如果有远程仓库）
git remote add origin <your-repo-url>
git push -u origin main

# 方式二：压缩整个项目文件夹
# 右键点击 mediapipe_iOS 文件夹 → 发送到 → 压缩文件夹
# 或使用 7-Zip/WinRAR 压缩
```

#### 2. 确认需要传输的文件

确保以下文件都包含在内：
```
mediapipe_iOS/
├── MediaPipeLandmarks/
│   ├── MediaPipeLandmarks.xcodeproj/
│   │   └── project.pbxproj          ← 重要：Xcode 项目配置
│   └── MediaPipeLandmarks/
│       ├── Controllers/
│       ├── Services/
│       ├── Views/
│       ├── Utils/
│       ├── Models/
│       │   ├── face_landmarker.task      ← 重要：3.6MB
│       │   └── gesture_recognizer.task   ← 重要：8.4MB
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       └── Info.plist
├── DEVELOPMENT.md
└── QUICKSTART.md
```

#### 3. 传输文件到 Mac

**方式一：通过 Git（推荐）**
- 推送到 GitHub/GitLab/Gitee
- 在 Mac 上克隆

**方式二：通过云存储**
- 上传到 OneDrive/Google Drive/iCloud Drive
- 在 Mac 上下载

**方式三：通过局域网**
- 使用 SMB 共享文件夹
- 或使用 AirDrop（如果 Mac 和 Windows 在同一网络）

**方式四：通过 U 盘/移动硬盘**
- 复制整个 `mediapipe_iOS` 文件夹到 U 盘
- 插入 Mac 并复制

---

## 在 Mac 上的完整操作流程

### 第一步：安装必要软件

#### 1. 安装 Xcode

```bash
# 方式一：从 App Store 安装（推荐）
# 打开 App Store，搜索 "Xcode"，点击 "获取"
# 下载大小约 12GB，需要等待较长时间

# 方式二：从 Apple Developer 下载
# 访问 https://developer.apple.com/download/
# 下载 Xcode 14.0 或更高版本的 .xip 文件
# 双击解压，拖拽到 Applications 文件夹
```

#### 2. 安装 Command Line Tools

```bash
# 打开终端（Terminal.app）
# 位置：应用程序 → 实用工具 → 终端

# 安装 Command Line Tools
xcode-select --install

# 点击弹出窗口中的 "安装" 按钮
# 等待安装完成（约 5-10 分钟）

# 验证安装
xcode-select -p
# 应该输出：/Applications/Xcode.app/Contents/Developer

xcodebuild -version
# 应该输出：Xcode 14.x 或更高版本
```

#### 3. 安装 Git（如果使用 Git 传输）

```bash
# 检查是否已安装
git --version

# 如果未安装，Command Line Tools 会自动包含 Git
# 或者从 https://git-scm.com/download/mac 下载安装
```

---

### 第二步：获取项目文件

#### 方式一：从 Git 克隆

```bash
# 打开终端

# 创建工作目录
mkdir -p ~/Projects
cd ~/Projects

# 克隆项目
git clone <your-repo-url> mediapipe_iOS
cd mediapipe_iOS

# 验证文件完整性
ls -la
# 应该看到 MediaPipeLandmarks/ 文件夹和 .md 文档
```

#### 方式二：从云存储/U 盘复制

```bash
# 打开终端

# 创建工作目录
mkdir -p ~/Projects
cd ~/Projects

# 从下载文件夹复制（假设文件在 Downloads）
cp -r ~/Downloads/mediapipe_iOS ./

# 或从 U 盘复制（假设 U 盘名为 "USB_DRIVE"）
cp -r /Volumes/USB_DRIVE/mediapipe_iOS ./

# 进入项目目录
cd mediapipe_iOS

# 验证文件完整性
ls -la
```

#### 方式三：解压压缩包

```bash
# 如果是 .zip 文件
unzip ~/Downloads/mediapipe_iOS.zip -d ~/Projects/

# 如果是 .tar.gz 文件
tar -xzf ~/Downloads/mediapipe_iOS.tar.gz -C ~/Projects/

cd ~/Projects/mediapipe_iOS
```

---

### 第三步：验证项目结构

```bash
# 在项目根目录执行
cd ~/Projects/mediapipe_iOS

# 检查目录结构
tree -L 3
# 如果没有 tree 命令，使用：
find . -maxdepth 3 -type d

# 检查关键文件
ls -lh MediaPipeLandmarks/MediaPipeLandmarks/Models/
# 应该看到：
# face_landmarker.task (约 3.6MB)
# gesture_recognizer.task (约 8.4MB)

# 检查 Xcode 项目文件
ls -la MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj/
# 应该看到 project.pbxproj 文件
```

---

### 第四步：打开项目

#### 方式一：使用命令行

```bash
# 在项目根目录执行
cd ~/Projects/mediapipe_iOS

# 打开 Xcode 项目
open MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj
```

#### 方式二：使用 Finder

1. 打开 Finder
2. 导航到 `~/Projects/mediapipe_iOS/MediaPipeLandmarks/`
3. 双击 `MediaPipeLandmarks.xcodeproj` 文件
4. Xcode 会自动启动并打开项目

---

### 第五步：配置项目

#### 1. 首次打开项目

Xcode 打开后，你会看到项目导航器（左侧边栏）。

#### 2. 配置开发团队（真机调试必需）

```
步骤：
1. 点击左侧导航器中的项目根节点 "MediaPipeLandmarks"（蓝色图标）
2. 在中间区域选择 TARGETS → MediaPipeLandmarks
3. 点击顶部的 "Signing & Capabilities" 标签
4. 勾选 "Automatically manage signing"
5. 在 "Team" 下拉菜单中：
   - 如果已登录 Apple ID：选择你的账号
   - 如果未登录：点击 "Add an Account..."
```

#### 3. 添加 Apple ID（如果需要）

```
步骤：
1. Xcode 菜单栏 → Xcode → Settings (或 Preferences)
2. 点击 "Accounts" 标签
3. 点击左下角的 "+" 按钮
4. 选择 "Apple ID"
5. 输入你的 Apple ID 和密码
6. 点击 "Continue"
```

**注意**：
- 免费 Apple ID 可以用于真机调试，但每 7 天需要重新签名
- 付费开发者账号（$99/年）无此限制

#### 4. 修改 Bundle Identifier（如果签名失败）

```
步骤：
1. 在 "Signing & Capabilities" 中找到 "Bundle Identifier"
2. 当前值：com.example.MediaPipeLandmarks
3. 修改为唯一标识符，例如：
   com.yourname.MediaPipeLandmarks
   com.yourdomain.MediaPipeLandmarks
```

#### 5. 验证模型文件

```
步骤：
1. 在左侧导航器中展开：
   MediaPipeLandmarks → MediaPipeLandmarks → Models
2. 应该看到两个文件：
   - face_landmarker.task
   - gesture_recognizer.task
3. 如果文件显示为红色（找不到）：
   a. 右键点击 Models 文件夹 → Add Files to "MediaPipeLandmarks"
   b. 导航到项目根目录，选择两个 .task 文件
   c. 勾选 "Copy items if needed"
   d. 勾选 "MediaPipeLandmarks" target
   e. 点击 "Add"
```

---

### 第六步：运行项目

#### 方式一：使用模拟器（快速测试）

```
步骤：
1. 在 Xcode 顶部工具栏，找到设备选择器
   （默认显示 "iPhone 15 Pro" 或类似）
2. 点击设备选择器，选择任意 iOS 15.0+ 模拟器
   推荐：iPhone 14 Pro 或 iPhone 15 Pro
3. 点击左上角的运行按钮（▶️）
   或按快捷键：Command + R
4. 等待编译完成（首次编译需要 2-5 分钟）
5. 模拟器会自动启动并运行应用
```

**注意**：模拟器无法使用真实相机，会显示黑屏或模拟画面。

#### 方式二：使用真机（完整测试）

##### 1. 连接 iPhone/iPad

```
步骤：
1. 使用 USB 线连接 iPhone/iPad 到 Mac
2. 在设备上会弹出 "信任此电脑？" 提示
3. 点击 "信任"
4. 输入设备密码（如果需要）
```

##### 2. 选择设备

```
步骤：
1. 在 Xcode 顶部工具栏，点击设备选择器
2. 在列表中找到你的设备名称（例如 "张三的 iPhone"）
3. 点击选择
```

##### 3. 运行到真机

```
步骤：
1. 点击运行按钮（▶️）或按 Command + R
2. 等待编译和安装
3. 如果出现 "Untrusted Developer" 错误，继续下一步
```

##### 4. 信任开发者证书（首次运行必需）

```
在 iPhone/iPad 上操作：
1. 打开 "设置" 应用
2. 滚动到 "通用" → "VPN与设备管理"
   （iOS 15+）或 "通用" → "描述文件与设备管理"（旧版本）
3. 在 "开发者 App" 部分，找到你的 Apple ID
4. 点击进入，点击 "信任 <你的 Apple ID>"
5. 在弹出的确认对话框中点击 "信任"
```

##### 5. 重新运行

```
步骤：
1. 返回 Xcode
2. 再次点击运行按钮（▶️）
3. 应用会成功安装并启动
```

---

### 第七步：测试应用

#### 1. 授权相机权限

```
首次运行时：
1. 应用会弹出 "MediaPipeLandmarks 想访问您的相机" 提示
2. 点击 "允许"
```

#### 2. 测试人脸识别

```
步骤：
1. 在主界面点击 "Face Detection" 按钮
2. 将人脸对准相机
3. 应该看到：
   - 468 个橙色关键点
   - 蓝色人脸网格连接线
   - 关键点精确贴合人脸，无拉伸变形
```

#### 3. 测试手势识别

```
步骤：
1. 返回主界面，点击 "Hand Gestures" 按钮
2. 将手掌对准相机
3. 应该看到：
   - 21 个橙色关键点
   - 蓝色手部骨架连接线
   - 红色手势名称（如 "Open_Palm"）
4. 尝试不同手势：
   - 竖起大拇指 → "Thumb_Up"
   - V 字手势 → "Victory"
   - 握拳 → "Closed_Fist"
```

---

## 常见问题排查

### 问题 1：Xcode 无法打开项目

**症状**：双击 .xcodeproj 文件没有反应

**解决方案**：
```bash
# 检查 Xcode 是否正确安装
xcodebuild -version

# 如果未安装，重新安装 Xcode
# 如果已安装，尝试从命令行打开
open MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj
```

---

### 问题 2：编译错误 "No such module 'MediaPipeTasksVision'"

**症状**：代码中 `import MediaPipeTasksVision` 报错

**原因**：MediaPipe framework 未正确链接

**解决方案**：

**方案一：清理构建缓存**
```
步骤：
1. Xcode 菜单栏 → Product → Clean Build Folder
   或按快捷键：Command + Shift + K
2. 重新编译：Command + B
```

**方案二：重置派生数据**
```bash
# 在终端执行
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**方案三：手动添加 MediaPipe framework**

由于项目使用 MediaPipe Tasks，需要通过 Swift Package Manager 添加：

```
步骤：
1. 在 Xcode 中选择项目根节点
2. 选择 TARGETS → MediaPipeLandmarks
3. 点击 "General" 标签
4. 滚动到 "Frameworks, Libraries, and Embedded Content"
5. 点击 "+" 按钮
6. 点击 "Add Other..." → "Add Package Dependency..."
7. 输入 MediaPipe URL：
   https://github.com/google/mediapipe
8. 选择版本：0.10.0 或更高
9. 点击 "Add Package"
10. 勾选 "MediaPipeTasksVision"
11. 点击 "Add Package"
```

---

### 问题 3：模型文件找不到

**症状**：运行时报错 "gesture_recognizer.task not found in bundle"

**解决方案**：

```bash
# 1. 确认文件存在
cd ~/Projects/mediapipe_iOS
ls -lh MediaPipeLandmarks/MediaPipeLandmarks/Models/

# 2. 如果文件不存在，从项目根目录复制
cp face_landmarker.task MediaPipeLandmarks/MediaPipeLandmarks/Models/
cp gesture_recognizer.task MediaPipeLandmarks/MediaPipeLandmarks/Models/
```

在 Xcode 中重新添加：
```
步骤：
1. 右键点击 Models 文件夹 → Add Files to "MediaPipeLandmarks"
2. 选择两个 .task 文件
3. 勾选 "Copy items if needed"
4. 勾选 "MediaPipeLandmarks" target
5. 点击 "Add"
6. 重新编译运行
```

---

### 问题 4：真机运行失败 "Failed to code sign"

**症状**：编译成功但无法安装到设备

**解决方案**：

**步骤一：检查开发团队配置**
```
1. 确认已在 Signing & Capabilities 中选择 Team
2. 确认 Bundle Identifier 是唯一的
```

**步骤二：清理并重新签名**
```
1. Product → Clean Build Folder (Command + Shift + K)
2. 断开设备连接
3. 重新连接设备
4. 重新运行
```

**步骤三：手动信任证书**
```
在设备上：
设置 → 通用 → VPN与设备管理 → 信任开发者
```

---

### 问题 5：相机权限被拒绝

**症状**：应用启动后相机黑屏

**解决方案**：

```
在 iPhone/iPad 上：
1. 打开 "设置" 应用
2. 滚动到 "隐私与安全性" → "相机"
3. 找到 "MediaPipeLandmarks"
4. 开启权限开关
5. 返回应用，重新启动
```

---

### 问题 6：性能问题（卡顿、帧率低）

**解决方案**：

1. **使用真机测试**（模拟器性能较差）
2. **降低检测频率**：
   ```swift
   // 在 ViewController 中添加
   guard currentTimestamp - lastTimestamp >= 33 else { return }  // ~30fps
   ```
3. **减少检测数量**：
   ```swift
   faceLandmarkerService.numFaces = 1  // 只检测一张人脸
   gestureRecognizerService.numHands = 1  // 只检测一只手
   ```

---

## 调试技巧

### 1. 查看控制台日志

```
步骤：
1. 在 Xcode 底部点击控制台按钮（或按 Command + Shift + Y）
2. 运行应用
3. 查看实时日志输出
```

### 2. 设置断点

```
步骤：
1. 在代码行号左侧点击，添加蓝色断点
2. 运行应用
3. 当执行到断点时会暂停
4. 使用调试工具栏：
   - Continue (F6): 继续执行
   - Step Over (F7): 单步跳过
   - Step Into (F8): 单步进入
   - Step Out (F9): 跳出函数
```

### 3. 查看变量值

```
步骤：
1. 在断点暂停时
2. 将鼠标悬停在变量上，查看当前值
3. 或在底部 "Variables View" 中查看所有变量
```

### 4. 性能分析

```
步骤：
1. Xcode 菜单栏 → Product → Profile
   或按快捷键：Command + I
2. 选择分析模板：
   - Time Profiler: CPU 使用率
   - Allocations: 内存分配
   - Leaks: 内存泄漏
3. 点击红色录制按钮开始分析
```

---

## 快速参考命令

```bash
# 打开项目
cd ~/Projects/mediapipe_iOS
open MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj

# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData

# 查看项目结构
tree -L 3

# 检查模型文件
ls -lh MediaPipeLandmarks/MediaPipeLandmarks/Models/

# 使用命令行编译（高级）
xcodebuild -project MediaPipeLandmarks/MediaPipeLandmarks.xcodeproj \
           -scheme MediaPipeLandmarks \
           -configuration Debug \
           build

# 列出可用设备
xcrun xctrace list devices
```

---

## 总结

完整流程回顾：

1. **Windows 端**：打包项目（Git/压缩包/云存储）
2. **Mac 端**：安装 Xcode + Command Line Tools
3. **传输**：通过 Git/云存储/U 盘传输项目
4. **打开**：`open MediaPipeLandmarks.xcodeproj`
5. **配置**：添加 Apple ID，配置开发团队
6. **运行**：选择模拟器或真机，点击运行按钮
7. **测试**：授权相机权限，测试人脸和手势识别

如遇到问题，参考上方 "常见问题排查" 章节。
