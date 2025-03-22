import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';  // For picking photos from gallery
import 'package:location/location.dart';  // For getting location

class MessagesPage extends StatefulWidget {
  final String parentEmail;  // The parent's email
  final String childEmail;   // The child's email

  const MessagesPage({super.key, required this.parentEmail, required this.childEmail});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  Location _location = Location();

  // Function to send message
  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      _firestore.collection('messages').add({
        'sender': widget.parentEmail,  // Parent sends the message
        'receiver': widget.childEmail,  // Receiver is the child
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),  // Timestamp of the message
      });

      _controller.clear();  // Clear the text field after sending the message
    }
  }

  // Function to get location
  Future<void> _shareLocation() async {
    // Request permission and get the current location
    var locationData = await _location.getLocation();
    _sendMessage('Location: Lat: ${locationData.latitude}, Lon: ${locationData.longitude}');
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendMessage('Image: ${pickedFile.path}');  // You can send the image URL or path to Firestore
    }
  }

  // Function to capture photo
  Future<void> _captureImage() async {
    final XFile? capturedFile = await _picker.pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      _sendMessage('Image: ${capturedFile.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.childEmail}"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('sender', isEqualTo: widget.parentEmail)
                  .where('receiver', isEqualTo: widget.childEmail)
                  .orderBy('timestamp')  // Order by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['message'];
                  final messageSender = message['sender'];
                  messageWidgets.add(
                    ListTile(
                      title: Text(messageText),
                      subtitle: Text(messageSender),
                    ),
                  );
                }
                return ListView(
                  children: messageWidgets,  // Display messages here
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Location Icon Button
                IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: _shareLocation,  // Share the current location
                ),
                // Camera Icon Button (for capturing photos)
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _captureImage,  // Capture an image using the camera
                ),
                // Photo Gallery Icon Button (for selecting photos)
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: _pickImage,  // Pick an image from the gallery
                ),
                // Text Field to type the message
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                // IconButton for sending the message
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_controller.text);  // Send the typed message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
