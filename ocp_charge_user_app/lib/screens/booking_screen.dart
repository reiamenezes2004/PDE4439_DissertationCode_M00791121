import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDestination;
  int? _currentCharge;
  TimeOfDay? _arrivalTime;
  bool _showNextStep = false;
  bool _bookingConfirmed = false;
  String _estimatedTime = '';
  List<String> _availableRobots = [];

  late AnimationController _animationController;
  Timer? _countdownTimer;
  String _countdownText = '';
  bool _robotDeployed = false;
  bool _robotArrived = false;

  late String userName;
  late String numberPlate;
  late bool isEv;

  // Firebase
  final DatabaseReference bookingsRef =
      FirebaseDatabase.instance.ref("bookings");
  String? _currentBookingId;
  String _robotStatus = "pending";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  Future<void> sendBookingToFirebase(String userName, String plateNumber,
      String destination, String arrivalTime, int currentCharge) async {
    DatabaseReference newBookingRef = bookingsRef.push();

    await newBookingRef.set({
      "user": userName,
      "plate": plateNumber,
      "destination": destination,
      "arrivalTime": arrivalTime,
      "currentCharge": currentCharge,
      "status": "pending",
      "createdAt": DateTime.now().toIso8601String(),
    });

    setState(() {
      _currentBookingId = newBookingRef.key;
    });

    newBookingRef.child("status").onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _robotStatus = event.snapshot.value.toString();
        });
      }
    });

    debugPrint("✅ Booking sent to Firebase for $plateNumber");
  }

  Future<void> _pickArrivalTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _arrivalTime = picked);
    }
  }

  void _nextStep() {
    if (_selectedDestination != null &&
        _currentCharge != null &&
        _currentCharge! >= 0 &&
        _currentCharge! <= 100 &&
        _arrivalTime != null) {
      setState(() {
        _showNextStep = true;
        _availableRobots = ['Robot A', 'Robot B', 'Robot C'];
        int timeRequired = (100 - _currentCharge!) * 1;
        _estimatedTime = '$timeRequired minutes';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
    }
  }

  void _confirmBooking() async {
    if (_selectedDestination == null ||
        _currentCharge == null ||
        _arrivalTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all booking details')),
      );
      return;
    }

    setState(() {
      _bookingConfirmed = true;
    });

    final arrivalTimeFormatted = _arrivalTime!.format(context);

    await sendBookingToFirebase(
      userName,
      numberPlate,
      _selectedDestination!,
      arrivalTimeFormatted,
      _currentCharge!,
    );

    _animationController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    if (_arrivalTime == null) return;
    final now = TimeOfDay.now();
    final arrival = _arrivalTime!;
    final nowMinutes = now.hour * 60 + now.minute;
    final arrivalMinutes = arrival.hour * 60 + arrival.minute;
    int diff = arrivalMinutes - nowMinutes;

    if (diff <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = diff * 60 - timer.tick;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _countdownText = 'Arrived';
          _robotArrived = true;
        });
      } else {
        final minutes = (remaining ~/ 60);
        final seconds = (remaining % 60);
        setState(() {
          _countdownText =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
        if (remaining <= 300 && !_robotDeployed) {
          setState(() {
            _robotDeployed = true;
          });
        }
      }
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel the booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetBooking();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _resetBooking() {
    if (_currentBookingId != null) {
      bookingsRef.child(_currentBookingId!).remove(); // remove booking from Firebase
    }

    setState(() {
      _selectedDestination = null;
      _currentCharge = null;
      _arrivalTime = null;
      _showNextStep = false;
      _bookingConfirmed = false;
      _estimatedTime = '';
      _availableRobots = [];
      _countdownText = '';
      _robotDeployed = false;
      _robotArrived = false;
      _robotStatus = "pending";
      _currentBookingId = null;
    });
    _countdownTimer?.cancel();
    _animationController.reset();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userName = args?['name'] ?? 'Guest';
    numberPlate = args?['numberPlate'] ?? 'Unknown';
    isEv = args?['isEv'] == 1 || args?['isEv'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCP Booking Portal'),
        backgroundColor: const Color(0xFF2C6EC6),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/account',
              arguments: {
                'name': userName,
                'numberPlate': numberPlate,
                'isEv': isEv,
                'bookingConfirmed': _bookingConfirmed,
                'destination': _selectedDestination,
                'robot':
                    _availableRobots.isNotEmpty ? _availableRobots.first : null,
                'time': _estimatedTime,
                'arrivalTime': _arrivalTime?.format(context),
              },
            );
          },
        ),
      ),
      body: _bookingConfirmed
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                    child: const Icon(Icons.check_circle,
                        size: 130, color: Colors.green),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  if (_arrivalTime != null) ...[
                    const SizedBox(height: 10),
                    Text('Arrival Time: ${_arrivalTime!.format(context)}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                  if (_countdownText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Time until arrival: $_countdownText',
                        style: const TextStyle(fontSize: 18)),
                  ],
                  if (_robotDeployed) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Robot is being deployed and finding a parking zone...',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Robot Status: $_robotStatus',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600),
                  ),
                  if (_robotArrived) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Robot has reached your parking zone!',
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening directions...')),
                        );
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Show Directions'),
                    ),
                  ],
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, $userName',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Plate: $numberPlate'),
                          Text('EV Vehicle: ${isEv ? "Yes" : "No"}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: !_showNextStep
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select your destination',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedDestination,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'City Centre Mirdif',
                                        child: Text('City Centre Mirdif')),
                                    DropdownMenuItem(
                                        value: 'Dubai Mall',
                                        child: Text('Dubai Mall')),
                                    DropdownMenuItem(
                                        value: 'Mall of the Emirates',
                                        child: Text('Mall of the Emirates')),
                                    DropdownMenuItem(
                                        value: 'City Center Deira',
                                        child: Text('City Center Deira')),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _selectedDestination = value),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Choose location',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Current EV Charge (%)',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 45',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    _currentCharge = int.tryParse(val);
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _pickArrivalTime,
                                  icon: const Icon(Icons.access_time),
                                  label: Text(_arrivalTime != null
                                      ? 'Arrival: ${_arrivalTime!.format(context)}'
                                      : 'Select Time of Arrival'),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text(
                                      'Next',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Available Robots:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                ..._availableRobots.map((robot) => Row(
                                      children: [
                                        const Icon(Icons.smart_toy,
                                            color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Text(robot,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ],
                                    )),
                                const SizedBox(height: 20),
                                Text('Estimated charging time: $_estimatedTime',
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _confirmBooking,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                        ),
                                        child: const Text(
                                          'Confirm Booking',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _showCancelDialog,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
