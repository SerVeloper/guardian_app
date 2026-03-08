import 'dart:async';
import 'package:flutter/material.dart';

class EmergenciaPage extends StatefulWidget {
  const EmergenciaPage({super.key});

  @override
  State<EmergenciaPage> createState() => _EmergenciaPageState();
}

class _EmergenciaPageState extends State<EmergenciaPage> {
  int counter = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter > 1) {
        setState(() {
          counter--;
        });
      } else {
        timer.cancel();
        // Aquí puedes ejecutar la acción SOS
      }
    });
  }

  void cancelarSOS() {
    timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE50914),
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            const Spacer(),

            /// CIRCULO CONTADOR
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white38,
                  width: 6,
                ),
              ),
              child: Center(
                child: Text(
                  "$counter",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// TEXTO PRINCIPAL
            const Text(
              "Activando SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// DESCRIPCIÓN
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Se enviará alerta a tus contactos y servicios de emergencia",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// BOTÓN CANCELAR
            ElevatedButton(
              onPressed: cancelarSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}