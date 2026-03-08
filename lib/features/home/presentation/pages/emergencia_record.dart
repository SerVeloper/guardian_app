import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/emergency_video.mp4";

    await _cameraController!.startVideoRecording();
    
    setState(() {
      recordingVideo = true;
    });
  }

  Future<void> startAudioRecording() async {

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/emergency_audio.m4a";

    await _audioRecorder.start(
      const RecordConfig(),
      path: path,
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

    if (_cameraController != null && recordingVideo) {
      await _cameraController!.stopVideoRecording();
    }

    if (recordingAudio) {
      await _audioRecorder.stop();
    }

    Navigator.pop(context);
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

              /// HEADER
              Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.warning, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Emergencia",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Activando...",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 40),

              /// ICONO CENTRAL
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Ayuda en camino",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Mantén la calma, estás protegida",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              /// TIEMPO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tiempo transcurrido",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      formatTime(seconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// AUDIO / VIDEO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Grabando evidencia",
                      style: TextStyle(color: Colors.white),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.mic,
                          color: recordingAudio
                              ? Colors.green
                              : Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.videocam,
                          color: recordingVideo
                              ? Colors.green
                              : Colors.white,
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const Spacer(),

              /// BOTON CANCELAR
 ElevatedButton(
  onPressed: () {
    stopAll();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  },
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

              const Text(
                "La alerta se mantendrá activa hasta que la canceles",
                style: TextStyle(
                  color: Colors.white70,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}