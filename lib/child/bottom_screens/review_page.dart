import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';

const Color kColorDarkRed = Colors.redAccent; // Define missing color

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  TextEditingController searchController = TextEditingController(); // Search controller
  bool isSaving = false;
  double? ratings;
  String searchQuery = ''; // Variable to store search query

  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(2.0),
            title: Text("Review your place"),
            content: Form(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    hintText: 'Enter location',
                    controller: locationC,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: viewsC,
                    hintText: 'Enter your views',
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 15),
                RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  unratedColor: Colors.grey.shade300,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: kColorDarkRed),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratings = rating;
                    });
                  },
                ),
              ],
            )),
            actions: [
              PrimaryButton(
                  title: "SAVE",
                  onPressed: () {
                    saveReview();
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance.collection('reviews').add({
      'location': locationC.text.isNotEmpty ? locationC.text : "Unknown",
      'views': viewsC.text.isNotEmpty ? viewsC.text : "No comments",
      "ratings": ratings ?? 1.0, // Default to 1.0 if null
    }).then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Review uploaded successfully');
      });
    });
  }

  // Method to update the search query and filter results
  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Recent Reviews by Others",
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: updateSearchQuery, // Update search query as user types
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        // Filter reviews based on search query
                        var filteredDocs = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>?;
                          var location = data?["location"] ?? "Unknown";
                          return location.toLowerCase().contains(searchQuery); // Filter based on location
                        }).toList();

                        return ListView.separated(
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final doc = filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>? ?? {};

                            // ✅ Check if fields exist, otherwise use default values
                            String location = data["location"] ?? "Unknown";
                            String views = data["views"] ?? "No comments";
                            double rating = (data["ratings"] as num?)?.toDouble() ?? 1.0;

                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location: $location",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      ),
                                      Text(
                                        "Comments: $views",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      RatingBar.builder(
                                        initialRating: rating,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        itemCount: 5,
                                        ignoreGestures: true,
                                        unratedColor: Colors.grey.shade300,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => const Icon(
                                            Icons.star,
                                            color: kColorDarkRed),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            ratings = rating;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
