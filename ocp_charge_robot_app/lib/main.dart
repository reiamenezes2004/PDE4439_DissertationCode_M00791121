import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(const OcpRobotApp());
  } catch (e, st) {
    debugPrint("❌ Firebase init failed: $e\n$st");
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Firebase init failed", style: TextStyle(fontSize: 20)),
        ),
      ),
    ));
  }
}

class OcpRobotApp extends StatelessWidget {
  const OcpRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCP Robot Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RobotDashboardScreen(),
    );
  }
}

class RobotDashboardScreen extends StatefulWidget {
  const RobotDashboardScreen({super.key});

  @override
  State<RobotDashboardScreen> createState() => _RobotDashboardScreenState();
}

class _RobotDashboardScreenState extends State<RobotDashboardScreen> {
  Map<String, dynamic>? currentBooking;
  String? bookingId;
  final DatabaseReference bookingsRef =
      FirebaseDatabase.instance.ref("bookings");

  @override
  void initState() {
    super.initState();

    // Listen for new bookings
    bookingsRef.onChildAdded.listen((event) {
      final booking = event.snapshot.value as Map?;
      if (booking != null) {
        setState(() {
          bookingId = event.snapshot.key;
          currentBooking = Map<String, dynamic>.from(booking);
        });
      }
    });
  }

  Future<void> updateStatus(String newStatus) async {
    if (bookingId == null) return;

    await bookingsRef.child(bookingId!).child("status").set(newStatus);

    setState(() {
      currentBooking!['status'] = newStatus;
    });

    debugPrint("✅ Booking $bookingId status updated to $newStatus");
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
            ? const Center(child: Text("Waiting for bookings..."))
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
                  buildDetailRow('User', currentBooking?['user'] ?? 'N/A'),
                  buildDetailRow('Plate', currentBooking?['plate'] ?? 'N/A'),
                  buildDetailRow(
                      'Destination', currentBooking?['destination'] ?? 'N/A'),
                  buildDetailRow(
                      'Arrival Time', currentBooking?['arrivalTime'] ?? 'N/A'),
                  buildDetailRow('EV Charge',
                      '${currentBooking?['currentCharge'] ?? '--'}%'),
                  buildDetailRow(
                      'Status', currentBooking?['status'] ?? 'Unknown'),
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
                  if (currentBooking?['status'] == 'En Route')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => updateStatus('Arrived & Charging'),
                        icon: const Icon(Icons.ev_station),
                        label: const Text('Mark as Arrived'),
                      ),
                    ),
                  if (currentBooking?['status'] == 'Arrived & Charging')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => updateStatus('Completed'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Complete'),
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
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
