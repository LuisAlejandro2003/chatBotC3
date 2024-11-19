import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función para abrir el enlace del repositorio en el navegador
  void _launchURL() async {
    const url = 'https://github.com/AlexisJuarez2227/Chat_Bot.git'; // Cambia este URL por el de tu repositorio
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Fondo rosado claro como en el diseño
      appBar: AppBar(
        backgroundColor: Colors.pink, // Color principal
        title: Text(
          'Split Bill App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Luis Alejandro Martínez Montoya',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800],
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                '9-A de Ingeniería en Software',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
            Center(
              child: Text(
                'UP Chiapas',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: <Widget>[
                  _buildFeatureCard(
                    context,
                    icon: Icons.chat,
                    title: 'Chatbot',
                    onTap: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.location_on,
                    title: 'Ubicación Actual',
                    onTap: () {
                      Navigator.pushNamed(context, '/gps');
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: 'Escanear QR',
                    onTap: () {
                      Navigator.pushNamed(context, '/qr');
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.mic,
                    title: 'Micrófono',
                    onTap: () {
                      Navigator.pushNamed(context, '/micro');
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.sensors,
                    title: 'Sensores',
                    onTap: () {
                      Navigator.pushNamed(context, '/sensores');
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.link,
                    title: 'Repositorio',
                    onTap: _launchURL,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
      required IconData icon,
      required String title,
      required Function() onTap,
    }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: Colors.pink),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
