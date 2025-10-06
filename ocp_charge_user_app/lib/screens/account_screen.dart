import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final userName = args?['name'] ?? 'Guest';
    final numberPlate = args?['numberPlate'] ?? 'Unknown';
    final isEv = args?['isEv'] == 1 || args?['isEv'] == true;

    final isBooked = args?['bookingConfirmed'] ?? false;
    final destination = args?['destination'] ?? '';
    final robot = args?['robot'] ?? '';
    final time = args?['time'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: const Color(0xFF2C6EC6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $userName',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Plate: $numberPlate'),
            Text('EV Vehicle: ${isEv ? "Yes" : "No"}'),
            const SizedBox(height: 24),

            if (isBooked) ...[
              Card(
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Destination: $destination'),
                      Text('Robot Assigned: $robot'),
                      Text('Charging Duration: $time'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
