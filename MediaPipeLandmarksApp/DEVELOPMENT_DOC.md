# MediaPipe Face/Hand/Tongue 开发文档

## 1. 项目目标与范围

本项目实现了一个跨平台（iOS + Android）的实时视觉识别应用，包含三个独立功能页：

- 人脸关键点（Face Landmarks）
- 手势识别（Hand Gestures）
- 舌头估计轮廓（Tongue Estimation，过渡方案，非真实舌部关键点）

目标是统一功能体验与 UI 风格，并保证在前置相机实时场景下具备可用性和稳定性。

---

## 2. 已实现功能

### 2.1 iOS 端（`mediapipe_iOS/MediaPipeLandmarksApp`）

#### 首页
- 三个入口卡片（Face / Hand / Tongue）
- 深色主题视觉，统一按钮风格

#### 人脸关键点页
- 前置相机预览
- 实时 Face Landmarker 推理
- 面部网格叠加绘制（连线 + 点）
- 顶部状态条与底部引导卡

#### 手势识别页
- 前置相机预览
- Gesture Recognizer 实时识别
- 手部骨架与关键点绘制
- 手势中文映射显示（无百分比）

#### 舌头估计页
- 基于 Face Landmarker 口部关键点进行舌体轮廓几何拟合
- 支持 `tongueOut` 分数门控（可用时优先）
- `tongueOut` 不可用时自动回退几何门控（避免功能失效）
- 帧间平滑，降低抖动

---

### 2.2 Android 端（同级项目 `D:/study/mediapipe_Andr`）

#### 首页
- 与 iOS 对齐的三卡片入口布局与视觉风格

#### 人脸关键点页
- CameraX 实时预览
- MediaPipe Face Landmarker 视频模式推理
- 面部网格叠加绘制（已对齐 AspectFill 坐标）

#### 手势识别页
- Gesture Recognizer 视频模式推理
- 手部骨架与关键点绘制
- 手势中文标签显示

#### 舌头估计页
- 与 iOS 一致的几何估计策略
- `tongueOut` 分数门控 + 几何回退双模式
- 实时状态与分数字段显示

---

## 3. 技术架构

### 3.1 分层设计（通用）

1. **UI 层**
   - 页面控制器（iOS `ViewController` / Android `Activity`）
   - 状态栏、引导卡、错误提示

2. **采集层**
   - iOS: `AVCaptureSession` + `AVCaptureVideoDataOutput`
   - Android: CameraX `Preview + ImageAnalysis`

3. **推理层**
   - MediaPipe Tasks Vision
   - FaceLandmarker / GestureRecognizer
   - 视频流模式（timestamp 严格递增）

4. **渲染层**
   - Overlay 视图绘制（关键点、连线、标签、舌头估计轮廓）
   - 坐标映射与镜像处理

---

### 3.2 iOS 核心模块

- `Services/CameraManager.swift`
  - 相机会话管理
  - 帧回调委托

- `Services/FaceLandmarkerService.swift`
  - FaceLandmarker 初始化与异步推理
  - `outputFaceBlendshapes` 支持

- `Services/GestureRecognizerService.swift`
  - GestureRecognizer 初始化
  - 视频帧识别与节流控制

- `Views/*OverlayView.swift`
  - Face / Hand / Tongue 叠加渲染

- `Controllers/*ViewController.swift`
  - 页面逻辑、状态显示、错误弹窗

---

### 3.3 Android 核心模块

- `camera/CameraStreamManager.kt`
  - CameraX 预览与帧分析
  - 旋转/镜像统一处理

- `detection/FaceLandmarkerHelper.kt`
  - FaceLandmarker 初始化与推理
  - `tongueOut` 分数提取

- `detection/GestureRecognizerHelper.kt`
  - 手势推理封装

- `overlay/*OverlayView.kt`
  - Face / Hand / Tongue 渲染
  - AspectFill 坐标对齐

- `ui/*Activity.kt`
  - 页面组织、状态机、权限与生命周期

---

## 4. 关键实现说明

### 4.1 舌头估计轮廓算法（过渡方案）

由于官方 Face Landmarker 不提供真实舌头 landmarks，本项目使用口部关键点进行几何拟合：

- 锚点：外口角、内口角、上下内唇、下内唇侧点、鼻尖、下巴
- 方向：`下巴向量` 与 `鼻尖->唇中心向量` 混合
- 形态：根据 `mouthOpenRatio` 与 `tongueOut`（若可用）联合控制长度与宽度
- 约束：舌尖长度受下巴投影上限限制，避免过冲
- 平滑：轮廓点低通滤波（EMA）减少抖动

> 说明：该方案是“估计轮廓”，用于过渡阶段可视化，不等价于医学级真实舌体分割/关键点。

---

### 4.2 坐标对齐策略

为避免“网格不贴脸”，两端统一采用 AspectFill 映射：

- 计算 `scale = max(viewW/imageW, viewH/imageH)`
- 计算居中偏移 `xOffset / yOffset`
- 最终坐标：`x = nx * imageW * scale + xOffset`，`y = ny * imageH * scale + yOffset`

该策略与预览层（`resizeAspectFill` / `FILL_CENTER`）保持一致。

---

## 5. 遇到的主要困难与解决方案

### 问题 A：运行后只有相机预览，识别无结果

**现象拆解**
- 现象 1：预览正常，但人脸/手势完全无绘制，控制台几乎无报错。
- 现象 2：预览正常，偶发有结果，但大多数帧没有回调。
- 现象 3：有推理结果但覆盖层位置明显异常，用户误以为“没有识别”。

**根因（不止模型）**
- **资源层**：模型文件缺失、命名不一致、未勾选 Target Membership，导致 landmarker 初始化失败后直接 `guard return`。
- **输入帧层**：相机输出像素格式未固定（部分设备默认 YUV），MediaPipe 在 live/video 路径下处理不稳定，出现“只有预览”。
- **时间戳/模式层**：live stream 对 timestamp 单调递增与回调链路要求严格；帧堆积或回调阻塞会造成看似“无结果”。
- **门控阈值层**：阈值过高（尤其手势/舌头）会把有效结果过滤掉，表现为“长期未检测到”。
- **坐标映射层**：预览是 AspectFill，但 overlay 使用线性映射，结果绘制偏移，主观上像“没识别”。
- **环境层（跨平台）**：Windows 提交到 Mac 后若未重新 `pod install`、未用 `.xcworkspace`、或 CocoaPods 编码异常，会导致依赖链异常。

**定位过程**
- 先确认模型是否真的打入包内（而非仅在 project.pbxproj 引用）。
- 再检查服务初始化是否有可见错误提示（弹窗/日志），避免静默失败。
- 验证相机帧格式、旋转镜像、timestamp 是否符合 Tasks 要求。
- 对比推理结果数量与 overlay 坐标映射，排除“有结果但画错位置”。

**最终解决方案**
- 补齐并打包 `face_landmarker.task`、`gesture_recognizer.task`，增加模型路径多候选查找。
- 相机输出统一为 BGRA；Android 统一 `PreviewView.FILL_CENTER` 与 overlay AspectFill 映射。
- 手势链路由不稳定的 live 回调路径改为更稳的 video 同步推理（并加节流/防重入）。
- 增加初始化错误与运行时错误弹窗，避免“静默 return”。
- 阈值分级：先放宽保证可检出，再逐步收紧以控制误报。
- 完善文档与部署步骤（`MODEL_SETUP.md`、Mac 端 `pod install`/`.xcworkspace`）。

---

### 问题 B：Android 人脸网格不贴脸 / 视觉差异大

**原因**
- Overlay 使用了简单归一化映射，未考虑预览裁剪
- 连线策略与 iOS 不一致

**解决**
- 统一 AspectFill 坐标变换
- `PreviewView` 统一 `FILL_CENTER`
- 优化人脸连线绘制策略，弱化点绘制

---

### 问题 C：舌头检测误判、偏移或完全不触发

**原因**
- 纯几何门控在复杂姿态下不稳
- 部分设备/模型 `tongueOut` 可能为空

**解决**
- 引入双模式门控：
  - 有 `tongueOut`：分数 + 几何联合
  - 无 `tongueOut`：自动几何回退
- 增加轮廓几何约束与时序平滑
- 降低过严阈值，避免“永不触发”

---

### 问题 D：跨平台依赖与环境差异

**原因**
- Windows 开发 / Mac 构建
- CocoaPods 终端编码、依赖一致性问题

**解决**
- Mac 端重新 `pod install` 并使用 `.xcworkspace`
- 修复 UTF-8 环境变量
- 以 lock 文件保证依赖版本一致

---

## 6. 当前限制

- 舌头页面仍是“估计轮廓”，非真实舌体像素级分割
- 在低光、强遮挡、大姿态角下，估计轮廓仍可能偏移
- Android 与 iOS 虽已高度对齐，但 UI 渲染细节仍受平台控件差异影响

---

## 7. 后续优化建议

1. 增加调试面板（实时显示 `mouthOpenRatio` / `tongueOut` / 当前模式）
2. 引入口部质量评分（光照、清晰度、姿态）控制输出可信度
3. 舌头功能升级到专用模型（分割 + 关键点）以接近医学级精度
4. 完善自动化测试（阈值回归、帧率监控、异常路径）

---

## 8. 结论

当前版本已完成跨平台核心功能闭环，并在可用性、稳定性、UI 一致性上进行了多轮迭代。  
其中舌头模块采用“分数门控 + 几何回退”的工程化过渡方案，兼顾了可运行性与可解释性，为后续升级到专用舌头模型提供了清晰路径。
