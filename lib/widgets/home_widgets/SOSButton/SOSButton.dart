import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  final Future<void> Function() onPressed;

  const SOSButton({super.key, required this.onPressed});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSending 
          ? null 
          : () async {
              setState(() => _isSending = true);
              try {
                await widget.onPressed();
              } finally {
                setState(() => _isSending = false);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[900],
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: _isSending
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              '🚨 SOS EMERGENCY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
    );
  }
}