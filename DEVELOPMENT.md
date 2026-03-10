# MediaPipeLandmarks 开发文档

## 项目概述

MediaPipeLandmarks 是一个基于 MediaPipe Tasks 的 iOS 应用，实现了实时人脸关键点识别和手势识别功能。项目采用纯 Swift 开发，无需第三方依赖管理工具，直接使用 MediaPipe 官方提供的 .task 模型文件。

## 技术架构

### 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (UIKit)                      │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │ FaceDetection    │         │ HandGesture      │     │
│  │ ViewController   │         │ ViewController   │     │
│  └────────┬─────────┘         └────────┬─────────┘     │
│           │                             │                │
│  ┌────────▼─────────┐         ┌────────▼─────────┐     │
│  │ FaceOverlayView  │         │ HandOverlayView  │     │
│  └──────────────────┘         └──────────────────┘     │
└─────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────┐
│                   Service Layer                          │
│  ┌──────────────────────────────────────────────┐       │
│  │           CameraManager                       │       │
│  │  (AVCaptureSession + VideoDataOutput)        │       │
│  └────────┬─────────────────────────────────────┘       │
│           │                                              │
│  ┌────────▼──────────────┐   ┌──────────────────────┐  │
│  │ FaceLandmarker        │   │ GestureRecognizer    │  │
│  │ Service               │   │ Service              │  │
│  │ (MediaPipe Tasks)     │   │ (MediaPipe Tasks)    │  │
│  └───────────────────────┘   └──────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────┐
│                   Utility Layer                          │
│  ┌──────────────────────────────────────────────┐       │
│  │        CoordinateTransformer                  │       │
│  │  (归一化坐标 → 屏幕坐标转换)                  │       │
│  └──────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
                         │
┌─────────────────────────────────────────────────────────┐
│                   Model Layer                            │
│  ┌──────────────────┐   ┌──────────────────────┐       │
│  │ face_landmarker  │   │ gesture_recognizer   │       │
│  │ .task (3.6MB)    │   │ .task (8.4MB)        │       │
│  └──────────────────┘   └──────────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

### 核心技术栈

- **UI 框架**: UIKit (纯代码布局，无 Storyboard)
- **相机框架**: AVFoundation (AVCaptureSession, AVCaptureVideoDataOutput)
- **视觉识别**: MediaPipe Tasks Vision (FaceLandmarker, GestureRecognizer)
- **图形绘制**: Core Graphics (UIBezierPath, CGContext)
- **并发处理**: GCD (DispatchQueue)
- **最低支持**: iOS 15.0+

## 功能模块说明

### 1. 相机管理模块 (CameraManager)

**职责**: 管理相机会话、视频流采集、预览层渲染

**核心功能**:
- 初始化 AVCaptureSession，配置前置摄像头
- 设置 AVCaptureVideoDataOutput，输出格式为 32BGRA
- 配置 AVCaptureVideoPreviewLayer，videoGravity 为 .resizeAspectFill
- 实时输出 CMSampleBuffer 到 delegate

**关键配置**:
```swift
videoDataOutput.alwaysDiscardsLateVideoFrames = true  // 防止帧堆积
videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCMPixelFormat_32BGRA]
previewLayer.videoGravity = .resizeAspectFill  // 防止画面拉伸
```

### 2. 人脸识别模块 (FaceLandmarkerService)

**职责**: 使用 MediaPipe FaceLandmarker 检测人脸关键点

**核心功能**:
- 初始化 FaceLandmarker，runningMode 设置为 .liveStream
- 将 CMSampleBuffer 转换为 MPImage
- 异步检测人脸，返回 468 个关键点
- 通过 delegate 回调结果到 UI 层

**配置参数**:
- `numFaces`: 最大检测人脸数 (默认 1)
- `minFaceDetectionConfidence`: 人脸检测置信度阈值 (默认 0.5)
- `minFacePresenceConfidence`: 人脸存在置信度阈值 (默认 0.5)
- `minTrackingConfidence`: 跟踪置信度阈值 (默认 0.5)

### 3. 手势识别模块 (GestureRecognizerService)

**职责**: 使用 MediaPipe GestureRecognizer 检测手部关键点和手势

**核心功能**:
- 初始化 GestureRecognizer，runningMode 设置为 .liveStream
- 检测手部 21 个关键点
- 识别预设手势 (Thumb_Up, Victory, Open_Palm, Closed_Fist, Pointing_Up 等)
- 支持同时检测多只手 (最多 2 只)

**配置参数**:
- `numHands`: 最大检测手数 (默认 2)
- `minHandDetectionConfidence`: 手部检测置信度阈值 (默认 0.5)
- `minHandPresenceConfidence`: 手部存在置信度阈值 (默认 0.5)
- `minTrackingConfidence`: 跟踪置信度阈值 (默认 0.5)

### 4. 坐标转换模块 (CoordinateTransformer)

**职责**: 将 MediaPipe 返回的归一化坐标 (0.0-1.0) 转换为屏幕坐标

**核心算法**:
```swift
// 1. 计算缩放因子 (根据 videoGravity)
let widthScale = viewSize.width / imageSize.width
let heightScale = viewSize.height / imageSize.height
let scaleFactor = max(widthScale, heightScale)  // .resizeAspectFill

// 2. 计算偏移量 (居中对齐)
let scaledWidth = imageSize.width * scaleFactor
let scaledHeight = imageSize.height * scaleFactor
let xOffset = (viewSize.width - scaledWidth) / 2
let yOffset = (viewSize.height - scaledHeight) / 2

// 3. 转换坐标
let screenX = normalizedX * imageSize.width * scaleFactor + xOffset
let screenY = normalizedY * imageSize.height * scaleFactor + yOffset
```

**关键点**:
- 使用 `max(widthScale, heightScale)` 匹配 `.resizeAspectFill`
- 计算偏移量确保关键点与画面对齐
- 防止人脸/手部拉伸变形

### 5. 绘制模块 (OverlayView)

**FaceOverlayView 职责**:
- 绘制 468 个人脸关键点
- 绘制人脸网格连接线 (使用 FaceLandmarker.faceLandmarksConnections())
- 实时更新绘制内容

**HandOverlayView 职责**:
- 绘制 21 个手部关键点
- 绘制手部骨架连接线 (使用 GestureRecognizer.handLandmarksConnections())
- 显示识别到的手势名称
- 支持多只手同时绘制

**绘制优化**:
- 使用 `setNeedsDisplay()` 触发重绘
- 在 `draw(_:)` 中使用 CGContext 批量绘制
- 关键点使用圆形，连接线使用直线

## 完整 API 文档

### CameraManager

```swift
class CameraManager: NSObject

// 属性
var previewLayer: AVCaptureVideoPreviewLayer { get }
weak var delegate: CameraManagerDelegate? { get set }

// 方法
func setupCamera()                    // 初始化相机会话
func startSession()                   // 启动相机会话
func stopSession()                    // 停止相机会话
```

**CameraManagerDelegate**:
```swift
protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer)
}
```

### FaceLandmarkerService

```swift
class FaceLandmarkerService: NSObject

// 属性
weak var delegate: FaceLandmarkerServiceDelegate? { get set }
var numFaces: Int                              // 最大检测人脸数
var minFaceDetectionConfidence: Float          // 检测置信度阈值
var minFacePresenceConfidence: Float           // 存在置信度阈值
var minTrackingConfidence: Float               // 跟踪置信度阈值

// 方法
init()                                         // 初始化服务
func detectAsync(sampleBuffer: CMSampleBuffer) // 异步检测人脸
```

**FaceLandmarkerServiceDelegate**:
```swift
protocol FaceLandmarkerServiceDelegate: AnyObject {
    func faceLandmarkerService(
        _ service: FaceLandmarkerService,
        didFinishDetection result: FaceLandmarkerResult?,
        imageSize: CGSize,
        error: Error?
    )
}
```

### GestureRecognizerService

```swift
class GestureRecognizerService: NSObject

// 属性
weak var delegate: GestureRecognizerServiceDelegate? { get set }
var numHands: Int                              // 最大检测手数
var minHandDetectionConfidence: Float          // 检测置信度阈值
var minHandPresenceConfidence: Float           // 存在置信度阈值
var minTrackingConfidence: Float               // 跟踪置信度阈值

// 方法
init()                                         // 初始化服务
func recognizeAsync(sampleBuffer: CMSampleBuffer) // 异步识别手势
```

**GestureRecognizerServiceDelegate**:
```swift
protocol GestureRecognizerServiceDelegate: AnyObject {
    func gestureRecognizerService(
        _ service: GestureRecognizerService,
        didFinishRecognition result: GestureRecognizerResult?,
        imageSize: CGSize,
        error: Error?
    )
}
```

### CoordinateTransformer

```swift
class CoordinateTransformer

// 静态方法
static func point(
    from normalizedPoint: CGPoint,  // 归一化坐标 (0.0-1.0)
    imageSize: CGSize,              // 相机分辨率
    viewSize: CGSize                // 视图尺寸
) -> CGPoint                        // 返回屏幕坐标
```

### FaceOverlayView

```swift
class FaceOverlayView: UIView

// 方法
func draw(
    landmarks: [[NormalizedLandmark]],  // 人脸关键点数组
    imageSize: CGSize                   // 相机分辨率
)
```

### HandOverlayView

```swift
class HandOverlayView: UIView

// 方法
func draw(
    landmarks: [[NormalizedLandmark]],  // 手部关键点数组
    gestures: [[Category]],             // 识别到的手势
    imageSize: CGSize                   // 相机分辨率
)
```

## 数据流

### 人脸识别数据流

```
1. CameraManager 采集视频帧 (CMSampleBuffer)
   ↓
2. FaceDetectionViewController 接收帧
   ↓
3. FaceLandmarkerService 转换为 MPImage 并检测
   ↓
4. MediaPipe 返回 FaceLandmarkerResult (468 个关键点)
   ↓
5. Delegate 回调到 ViewController
   ↓
6. CoordinateTransformer 转换坐标
   ↓
7. FaceOverlayView 绘制关键点和连接线
```

### 手势识别数据流

```
1. CameraManager 采集视频帧 (CMSampleBuffer)
   ↓
2. HandGestureViewController 接收帧
   ↓
3. GestureRecognizerService 转换为 MPImage 并识别
   ↓
4. MediaPipe 返回 GestureRecognizerResult (21 个关键点 + 手势类别)
   ↓
5. Delegate 回调到 ViewController
   ↓
6. CoordinateTransformer 转换坐标
   ↓
7. HandOverlayView 绘制关键点、连接线和手势名称
```

## 性能优化

### 1. 帧率控制
- `alwaysDiscardsLateVideoFrames = true`: 丢弃延迟帧，防止堆积
- 推理在后台串行队列执行，避免阻塞主线程

### 2. 绘制优化
- 使用 `setNeedsDisplay()` 而非实时绘制
- 批量绘制关键点和连接线，减少 draw call

### 3. 内存管理
- 使用 `weak` 引用 delegate，避免循环引用
- CMSampleBuffer 及时释放

## 常见问题

### 1. 人脸/手部被拉伸变形
**原因**: 坐标转换未考虑 videoGravity 和屏幕宽高比
**解决**: 使用 CoordinateTransformer 正确计算 scaleFactor 和 offset

### 2. 关键点不贴合
**原因**: 相机分辨率与视图尺寸不匹配
**解决**: 传入正确的 imageSize (从 CMSampleBuffer 获取)

### 3. 模型文件找不到
**原因**: .task 文件未添加到 Xcode 项目的 Resources
**解决**: 在 project.pbxproj 中确认文件已添加到 PBXResourcesBuildPhase

### 4. 前置摄像头画面镜像
**原因**: 前置摄像头默认镜像
**解决**: 设置 `connection.isVideoMirrored = true`

## 扩展开发

### 添加新手势
1. 训练自定义 MediaPipe 手势模型
2. 替换 gesture_recognizer.task 文件
3. 无需修改代码，自动识别新手势

### 添加新功能
1. 物体检测: 使用 MediaPipe ObjectDetector
2. 姿态估计: 使用 MediaPipe PoseLandmarker
3. 图像分割: 使用 MediaPipe ImageSegmenter

## 许可证

本项目使用 MediaPipe Tasks，遵循 Apache 2.0 许可证。
