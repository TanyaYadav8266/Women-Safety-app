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
    final screenSize = MediaQuery.of(context).size;
    final buttonWidth = screenSize.width * 0.7;
    final buttonHeight = screenSize.height * 0.12;

    return GestureDetector(
      onTap: _isSending
          ? null
          : () async {
              setState(() => _isSending = true);
              try {
                await widget.onPressed();
              } finally {
                setState(() => _isSending = false);
              }
            },
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(255, 0, 0, 1),     // Bright red
              Color.fromRGBO(200, 0, 0, 1),     // Darker red
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Emergency icon
            Positioned(
              left: 16,
              top: buttonHeight * 0.2,
              child: Icon(
                Icons.emergency,
                color: Colors.white.withOpacity(0.8),
                size: buttonHeight * 0.4,
              ),
            ),
            // Main content
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: buttonHeight * 0.5),
                child: _isSending
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    : Text(
                        'SOS EMERGENCY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: buttonWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            // Alert symbol
            if (!_isSending)
              Positioned(
                right: 16,
                top: buttonHeight * 0.25,
                child: Text(
                  '🚨',
                  style: TextStyle(
                    fontSize: buttonHeight * 0.3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}