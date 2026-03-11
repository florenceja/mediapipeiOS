# MediaPipe Model Setup

This project requires two `.task` model files to run face and hand recognition.

## Required Files

- `face_landmarker.task`
- `gesture_recognizer.task`

## Official Download URLs

- `https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task`
- `https://storage.googleapis.com/mediapipe-models/gesture_recognizer/gesture_recognizer/float16/1/gesture_recognizer.task`

## Place Files In Xcode

1. In Xcode, right click `MediaPipeLandmarksApp` group -> **New Group** -> name it `Models`.
2. Drag both `.task` files into the `Models` group.
3. In the add-file dialog, make sure:
   - **Copy items if needed** is checked.
   - Target `MediaPipeLandmarksApp` is checked.
4. Build and run again.

## Notes

- Current Pod version in this repo: `MediaPipeTasksVision 0.10.21` (compatible with these models).
- If files are not included in the target, camera preview works but no recognition result is produced.
