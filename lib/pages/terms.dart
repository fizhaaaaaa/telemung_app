import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: Colors.blue,
        elevation: 4, // Memberikan sedikit bayangan pada AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Justifikasi kiri
            children: [
              const Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16), // Spasi antar elemen
              Text(
                'Welcome to TELEMUNG App. By using this application, you agree to the following terms and conditions:',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87, // Warna teks yang mudah dibaca
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Collection and Ownership',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. By using the TELEMUNG app, you agree that all data collected by the application, including water level measurements, locations, and related information, become the property of TELEMUNG. This data may be used for research, analysis, and other purposes to improve flood mitigation efforts.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'User Conduct and Responsibilities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '2. Users are expected to use the app in a lawful manner and must not misuse, manipulate, or alter the data. Any such actions could result in account suspension or termination.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Disclaimer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3. TELEMUNG does not guarantee that the app will always function without errors or interruptions. We are not responsible for any damage or loss arising from the use of the application.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'If you have any questions or concerns about these terms, please contact our support team at support@telemung.com.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
