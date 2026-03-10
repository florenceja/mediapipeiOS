# MediaPipe Landmarks iOS - 开发文档

## 技术架构

本项目基于 iOS 原生开发，采用 MVC 架构，结合 MediaPipe Tasks Vision iOS API 实现实时人脸关键点和手势识别。

### 核心模块

1. **Controllers (控制器层)**
   - `MainViewController`: 应用主入口，提供人脸识别和手势识别的导航。
   - `FaceDetectionViewController`: 负责人脸识别界面的生命周期管理，协调相机和识别服务。
   - `HandGestureViewController`: 负责手势识别界面的生命周期管理，协调相机和识别服务。

2. **Services (服务层)**
   - `CameraManager`: 封装 `AVCaptureSession`，负责相机权限请求、视频流捕获和帧输出。
   - `FaceLandmarkerService`: 封装 MediaPipe `FaceLandmarker`，处理视频帧并输出人脸关键点。
   - `GestureRecognizerService`: 封装 MediaPipe `GestureRecognizer`，处理视频帧并输出手部关键点和手势分类。

3. **Views (视图层)**
   - `FaceOverlayView`: 负责在相机预览上实时绘制人脸关键点和连接线。
   - `HandOverlayView`: 负责在相机预览上实时绘制手部关键点、连接线和手势名称。

4. **Utils (工具层)**
   - `CoordinateTransformer`: 负责将 MediaPipe 输出的归一化坐标转换为屏幕实际坐标，处理视频缩放（`resizeAspectFill`）和镜像问题，防止绘制拉伸变形。

## 完整 API 列表

### CameraManager
- `var delegate: CameraManagerDelegate?`: 相机帧输出代理。
- `var previewLayer: AVCaptureVideoPreviewLayer`: 相机预览图层。
- `func setupCamera()`: 初始化相机配置。
- `func startSession()`: 启动相机流。
- `func stopSession()`: 停止相机流。

### FaceLandmarkerService
- `var delegate: FaceLandmarkerServiceDelegate?`: 人脸识别结果代理。
- `func detectAsync(sampleBuffer: CMSampleBuffer)`: 异步处理视频帧进行人脸检测。

### GestureRecognizerService
- `var delegate: GestureRecognizerServiceDelegate?`: 手势识别结果代理。
- `func recognizeAsync(sampleBuffer: CMSampleBuffer)`: 异步处理视频帧进行手势识别。

### CoordinateTransformer
- `static func offsetsAndScaleFactor(for imageSize: CGSize, in viewSize: CGSize, contentMode: UIView.ContentMode) -> (xOffset: CGFloat, yOffset: CGFloat, scaleFactor: CGFloat)`: 计算缩放比例和偏移量。
- `static func point(from normalizedPoint: CGPoint, imageSize: CGSize, viewSize: CGSize, contentMode: UIView.ContentMode = .scaleAspectFill, isMirrored: Bool = false) -> CGPoint`: 将归一化坐标转换为视图坐标。

### FaceOverlayView
- `func draw(landmarks: [[NormalizedLandmark]], imageSize: CGSize)`: 更新并绘制人脸关键点。

### HandOverlayView
- `func draw(landmarks: [[NormalizedLandmark]], gestures: [[Category]], imageSize: CGSize)`: 更新并绘制手部关键点和手势名称。
