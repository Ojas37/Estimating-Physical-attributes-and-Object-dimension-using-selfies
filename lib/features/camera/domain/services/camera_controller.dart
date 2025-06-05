// lib/features/camera/domain/camera_controller.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraController {
  CameraController? controller;
  bool isInitialized = false;
  List<CameraDescription> cameras = [];
  int currentCameraIndex = 0;
  bool _isFlashOn = false;

  bool get isFlashOn => _isFlashOn;

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      await _initializeCamera(cameras[currentCameraIndex]);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller!.initialize();
      isInitialized = true;
      await setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      isInitialized = false;
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    currentCameraIndex = (currentCameraIndex + 1) % cameras.length;
    await _initializeCamera(cameras[currentCameraIndex]);
  }

  Future<void> toggleFlash() async {
    if (!isInitialized || controller == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized || controller == null) return;

    try {
      await controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (!isInitialized || controller == null) return null;

    try {
      final image = await controller!.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  bool get isBackCamera =>
      currentCameraIndex < cameras.length &&
      cameras[currentCameraIndex].lensDirection == CameraLensDirection.back;

  void dispose() {
    controller?.dispose();
  }
}
