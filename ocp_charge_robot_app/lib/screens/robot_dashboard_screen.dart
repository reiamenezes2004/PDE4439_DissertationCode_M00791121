import 'package:flutter/material.dart';

class RobotDashboardScreen extends StatefulWidget {
  const RobotDashboardScreen({super.key});

  @override
  State<RobotDashboardScreen> createState() => _RobotDashboardScreenState();
}

class _RobotDashboardScreenState extends State<RobotDashboardScreen> {
  Map<String, dynamic>? currentBooking;

  @override
  void initState() {
    super.initState();

    // Simulate incoming booking data (for now)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentBooking = {
          'name': 'Reia',
          'numberPlate': 'D-12345',
          'destination': 'Mall Parking A',
          'arrivalTime': '08:30 AM',
          'chargeLevel': 40,
          'estimatedChargingTime': '60 mins',
          'status': 'Pending',
        };
      });
    });
  }

  void updateStatus(String newStatus) {
    if (currentBooking == null) return;
    setState(() {
      currentBooking!['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCP Robot Dashboard'),
        backgroundColor: const Color(0xFF2C6EC6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: currentBooking == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incoming Booking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C6EC6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildDetailRow('Name', currentBooking!['name']),
                  buildDetailRow('Plate', currentBooking!['numberPlate']),
                  buildDetailRow('Destination', currentBooking!['destination']),
                  buildDetailRow('Arrival Time', currentBooking!['arrivalTime']),
                  buildDetailRow('EV Charge', '${currentBooking!['chargeLevel']}%'),
                  buildDetailRow('Charging Duration', currentBooking!['estimatedChargingTime']),
                  buildDetailRow('Status', currentBooking!['status']),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateStatus('En Route'),
                          child: const Text('Start Journey'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateStatus('Cancelled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentBooking!['status'] == 'En Route')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => updateStatus('Arrived & Charging'),
                        icon: const Icon(Icons.ev_station),
                        label: const Text('Mark as Arrived'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
