# MediaPipe iOS 项目最新修复

## 最新修复（解决 Category 报错）

### 问题
```
Value of type 'Category?' has no member 'categoryName'
```

### 根本原因
1. `GestureRecognizerResult.gestures` 的类型是 `[[[Category]]]`（三层数组）
   - 第一层：多只手
   - 第二层：每只手的可能手势（多个预测）
   - 第三层：每个手势的类别评分（多个可能类别）

2. HandGestureViewController 中存在错误的类型转换：
   ```swift
   // 错误
   result.gestures as! [Category] as! [[Category]]
   
   // 正确
   result.gestures  // 已经是 [[[Category]]]
   ```

### 修复内容

#### 1. HandGestureViewController.swift（第 67 行）
```swift
// 修复前
self.overlayView.draw(landmarks: result.landmarks, gestures: result.gestures as! [Category] as! [[Category]], imageSize: imageSize)

// 修复后
self.overlayView.draw(landmarks: result.landmarks, gestures: result.gestures, imageSize: imageSize)
```

#### 2. HandOverlayView.swift

**属性类型（第 6-7 行）**：
```swift
// 修复前
private var handLandmarks: [[NormalizedLandmark]] = []
private var gestures: [[Category]] = []

// 修复后
private var handLandmarks: [[[NormalizedLandmark]]] = []
private var gestures: [[[Category]]] = []
```

**draw 方法签名（第 20 行）**：
```swift
// 修复前
func draw(landmarks: [[NormalizedLandmark]], gestures: [[Category]], imageSize: CGSize)

// 修复后
func draw(landmarks: [[[NormalizedLandmark]]], gestures: [[[Category]]], imageSize: CGSize)
```

**手势名称获取（第 80-93 行）**：
```swift
// 修复前
if index < gestures.count, let firstGesture = gestures[index].first {
    let text = firstGesture.categoryName ?? "Unknown"
    ...
}

// 修复后
if handIndex < gestures.count, let gestureCategories = gestures[handIndex].first {
    // Get the category with highest score
    if let topCategory = gestureCategories.max(by: { $0.score < $1.score }) {
        let text = topCategory.categoryName ?? "Unknown"
        ...
    }
}
```

### 数据结构说明

```
gestures: [[[Category]]]
│
├─ gestures[0]  // 第一只手的手势预测 [[Category]]
│  ├─ gestures[0][0]  // 第一个预测手势的类别列表 [Category]
│  │  ├─ gestures[0][0][0]  // 第一个类别（如 "Thumb_Up", score: 0.95）
│  │  ├─ gestures[0][0][1]  // 第二个类别（如 "Victory", score: 0.03）
│  │  └─ ...
│  └─ gestures[0][1]  // 第二个预测手势（如果有）
│
└─ gestures[1]  // 第二只手的手势预测
```

### 修复策略
1. 移除所有强制类型转换（`as!`）
2. 使用正确的三层数组类型
3. 对每个手势的类别数组，使用 `max(by:)` 获取最高置信度的类别
4. 访问 `categoryName` 属性获取类别名称

## 之前的修复

### 1. API 修复
- `FaceLandmarksConnections.connections()` → `FaceLandmarker.faceConnections()`
- `HandLandmarksConnections.connections()` → `HandLandmarker.handConnections`

### 2. 项目配置清理
- 移除无效 CocoaPods build phase
- 恢复 CocoaPods 配置文件（Podfile, Podfile.lock, xcworkspace）

### 3. 文档更新
- 添加完整的 CocoaPods 安装流程
- 添加 iOS 16+ 开发者模式说明
- 统一项目路径为 MediaPipeLandmarksApp

## 在 Mac 上运行

```bash
cd MediaPipeLandmarksApp
pod install
open MediaPipeLandmarksApp.xcworkspace
```

然后在 Xcode 中：
1. Command + Shift + K（清理构建）
2. Command + B（编译）
3. 选择设备并运行
