import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../../services/s3_service.dart';

class EmergencyActivePage extends StatefulWidget {
  const EmergencyActivePage({super.key});

  @override
  State<EmergencyActivePage> createState() => _EmergencyActivePageState();
}

class _EmergencyActivePageState extends State<EmergencyActivePage> {

  CameraController? _cameraController;
  final _audioRecorder = AudioRecorder();

  bool recordingVideo = false;
  bool recordingAudio = false;

  String? videoPath;
  String? audioPath;

  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initCamera();
    startTimer();
    startAudioRecording();
  }

  Future<void> initCamera() async {

    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await _cameraController!.initialize();

    await _cameraController!.startVideoRecording();

    setState(() {
      recordingVideo = true;
    });
  }

  Future<void> startAudioRecording() async {

    final dir = await getApplicationDocumentsDirectory();
    audioPath = "${dir.path}/emergency_audio.m4a";

    await _audioRecorder.start(
      const RecordConfig(),
      path: audioPath!,
    );

    setState(() {
      recordingAudio = true;
    });
  }

  void startTimer() {

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        seconds++;
      });
    });

  }

  String formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> stopAll() async {

    timer?.cancel();

    /// detener video
    if (_cameraController != null && recordingVideo) {

      final videoFile = await _cameraController!.stopVideoRecording();
      videoPath = videoFile.path;

    }

    /// detener audio
    if (recordingAudio) {

      audioPath = await _audioRecorder.stop();

    }

    /// subir video
    if (videoPath != null) {

      await S3Service.uploadFile(
        File(videoPath!),
        "video_${DateTime.now().millisecondsSinceEpoch}.mp4",
      );

    }

    /// subir audio
    if (audioPath != null) {

      await S3Service.uploadFile(
        File(audioPath!),
        "audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
      );

    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFE50914),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 40),

              const Text(
                "Ayuda en camino",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                formatTime(seconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: stopAll,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),

                child: const Text(
                  "Estoy a salvo - Cancelar alerta",
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}