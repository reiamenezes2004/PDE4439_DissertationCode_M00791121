import 'package:flutter/material.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberPartController = TextEditingController();
  String _plateCode = 'Select';
  bool _isEv = false;

  @override
  void dispose() {
    _numberPartController.dispose();
    super.dispose();
  }

  void _proceedAsGuest() {
    if (_formKey.currentState!.validate()) {
      final plate = '$_plateCode-${_numberPartController.text.trim()}';

      Navigator.pushReplacementNamed(
        context,
        '/booking',
        arguments: {
          'name': 'Guest',
          'numberPlate': plate,
          'isEv': _isEv,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF2C6EC6);

    final inputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(6),
    );

    final focusedBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: mainBlue, width: 2),
      borderRadius: BorderRadius.circular(6),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Access'),
        backgroundColor: mainBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/OCP_logo.png', width: 120),
                  const SizedBox(height: 24),

                  // Plate input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: _plateCode,
                          underline: const SizedBox(),
                          items: [
                            'Select',
                            ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
                          ].map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _plateCode = val!),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DUBAI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            controller: _numberPartController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: InputDecoration(
                              hintText: '12345',
                              counterText: '',
                              border: inputBorder,
                              enabledBorder: inputBorder,
                              focusedBorder: focusedBorder,
                            ),
                            validator: (value) {
                              if (_plateCode == 'Select') {
                                return 'Choose plate code';
                              }
                              if (value == null || value.isEmpty) {
                                return 'Enter number';
                              }
                              if (value.length > 5) {
                                return 'Max 5 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // EV Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.electric_car, color: Colors.black54),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Is this an Electric Vehicle?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Switch(
                          value: _isEv,
                          onChanged: (val) => setState(() => _isEv = val),
                          activeColor: mainBlue,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedAsGuest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Proceed as Guest'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
