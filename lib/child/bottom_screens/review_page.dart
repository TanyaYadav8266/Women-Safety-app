import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0; // Rating will be between 1 to 5
  String _place = ''; // The selected or entered place

  // Function to submit review
  void _submitReview() {
    if (_place.isNotEmpty && _rating > 0) {
      _firestore.collection('reviews').add({
        'place': _place,
        'rating': _rating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _placeController.clear();
      _reviewController.clear();
      setState(() {
        _rating = 0; // Reset rating
      });
    }
  }

  // Function to display reviews for a specific place
  Stream<List<Map<String, dynamic>>> _getReviews(String place) {
    return _firestore
        .collection('reviews')
        .where('place', isEqualTo: place)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'place': doc['place'],
                  'rating': doc['rating'],
                  'review': doc['review'],
                  'timestamp': doc['timestamp'],
                })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Safety Review"),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Place input field (text or dropdown)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _placeController,
                decoration: InputDecoration(
                  labelText: 'Enter or Select a Place',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _place = value;
                  });
                },
              ),
            ),
            // Rating system (1 to 5 stars)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
            ),
            // Review TextField
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Leave a Review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            // Submit Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _submitReview,
                child: Text("Submit Review"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Button color
                ),
              ),
            ),
            // Display Reviews for the place
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Reviews for $_place',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getReviews(_place),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No reviews yet"));
                }

                final reviews = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rating: ${review['rating']} ⭐',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              review['review'] ?? 'No review',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Posted on: ${review['timestamp'].toDate().toString()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
