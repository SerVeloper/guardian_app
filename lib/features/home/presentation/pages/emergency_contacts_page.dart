import 'package:flutter/material.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F6B6E),
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contactos de emergencia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Agrega hasta 5 contactos de confianza",
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// CONTACTO
            contactCard(),

            const SizedBox(height: 12),

            /// CONTACTO
            contactCard(),

            const SizedBox(height: 20),

            /// BOTON AGREGAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF0F6B6E),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1, color: Color(0xFF0F6B6E)),
                  SizedBox(width: 8),
                  Text(
                    "Agregar contacto (2/5)",
                    style: TextStyle(
                      color: Color(0xFF0F6B6E),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0F6B6E)),
              ),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Importante: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          "Tus contactos de emergencia recibirán un SMS para verificar tu número. "
                          "Serán notificados automáticamente si activas una alerta.",
                    )
                  ],
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F6B6E),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// TARJETA DE CONTACTO
  Widget contactCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// NOMBRE + VERIFICADO
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Ros Icela Pinedo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF3E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "Verificado",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(Icons.edit, color: Colors.grey),
              const SizedBox(width: 10),
              const Icon(Icons.delete, color: Colors.red),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Madre",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: const [
              Icon(Icons.phone, color: Color(0xFF0F6B6E)),
              SizedBox(width: 8),
              Text(
                "+591 74747567",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}