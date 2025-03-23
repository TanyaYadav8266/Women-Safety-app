import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselItem {
  final String image; // Image path (local asset)
  final String heading; // Heading for the card
  final String url; // URL to open when the card is clicked

  CarouselItem({required this.image, required this.heading, required this.url});
}

class SelfDefencePage extends StatelessWidget {
  // Define the color scheme
  final Color primaryColor = Color.fromRGBO(255, 33, 117, 1); // Updated app bar color
  final Color secondaryColor = Color.fromRGBO(248, 7, 89, 1);

  // Define the sections
  final List<String> sections = [
    "Fundamentals of Self-Defense",
    "Situational Awareness & Prevention",
    "Legal Rights & Safety Laws",
    "Emergency Response & First Aid",
    "Myth vs. Reality in Self-Defense",
    "Mental Preparedness & Confidence Building",
  ];

  // Define content for each section
  final List<List<CarouselItem>> sectionContent = [
    // 1️⃣ Fundamentals of Self-Defense
    [
      CarouselItem(
        image: "assets/basic_moves.jpg",
        heading: "Basic Self-Defense Moves",
        url: "https://www.youtube.com/watch?v=KVpxP3ZZtAc",
      ),
      CarouselItem(
        image: "assets/escape_tactics.jpg",
        heading: "Escape Tactics",
        url: "https://www.youtube.com/watch?v=ZNCDqzTtgdI",
      ),
      CarouselItem(
        image: "assets/group_defense.png",
        heading: "Group Defense",
        url: "https://www.youtube.com/watch?v=WCn4GBcs84s",
      ),
      CarouselItem(
        image: "assets/armed_attackers.png",
        heading: "Defense Against Armed Attackers",
        url: "https://www.youtube.com/watch?v=HapjUMYDOAY",
      ),
      CarouselItem(
        image: "assets/everyday_objects.png",
        heading: "Using Everyday Objects for Protection",
        url: "https://www.youtube.com/watch?v=IxhgoElQ5so",
      ),
      CarouselItem(
        image: "assets/de_escalation.png",
        heading: "De-escalation & Conflict Avoidance",
        url: "https://www.youtube.com/watch?v=bJas3YTYaaQ",
      ),
    ],

    // 2️⃣ Situational Awareness & Prevention
    [
      CarouselItem(
        image: "assets/unsafe_situations.jpg",
        heading: "Recognizing Unsafe Situations – Signs of potential threats",
        url: "https://activeshootersurvivaltraining.com/recognizing-early-warning-signs-of-potential-threats/",
      ),
      CarouselItem(
        image: "assets/avoiding_target.jpg",
        heading: "Avoiding Being a Target – Body language, safe walking strategies",
        url: "https://www.girlswhofight.co/post/body-language-victim-selection-how-to-lower-risk-by-walking-confidently",
      ),
      CarouselItem(
        image: "assets/travel_safety.jpg",
        heading: "Travel Safety Tips – Public transport, cabs, and night-time safety",
        url: "https://www.ucl.ac.uk/estates/our-services/security-ucl/staying-safe-ucl/8-top-tips-stay-safe-public-transport",
      ),
      CarouselItem(
        image: "assets/safe_social.jpg",
        heading: "Safe Social Interactions – Handling strangers and public confrontations",
        url: "https://nickwignall.com/confrontations/",
      ),
      CarouselItem(
        image: "assets/home_digital_safety.jpg",
        heading: "Home & Digital Safety – Preventing stalking and online threats",
        url: "https://www.techtarget.com/searchsecurity/definition/cyberstalking",
      ),
    ],

    // 3️⃣ Legal Rights & Safety Laws
    [
      CarouselItem(
        image: "assets/self_defense_laws.jpg",
        heading: "Self-Defense Laws – When force is legally justified",
        url: "https://www.leadindia.law/blog/en/ipc-section-100/",
      ),
      CarouselItem(
        image: "assets/reporting_incident.png",
        heading: "Reporting an Incident – FIR process and contacting authorities",
        url: "https://www.smilefoundationindia.org/blog/important-legal-rights-of-women-in-india/",
      ),
      CarouselItem(
        image: "assets/womens_safety_laws.jpg",
        heading: "Women’s Safety Laws – Key legal protections and rights",
        url: "https://lawchakra.in/blog/laws-protecting-womens-rights-india/",
      ),
      CarouselItem(
        image: "assets/protection_orders.jpg",
        heading: "Protection Orders – Restraining orders and legal measures",
        url: "https://lawlex.org/lex-pedia/what-is-permissible-for-women-to-carry-in-order-to-protect-themselves/21054",
      ),
      CarouselItem(
        image: "assets/legal_help.jpg",
        heading: "Seeking Legal Help – Accessing lawyers and support organizations",
        url: "https://www.lexisnexis.in/blogs/laws-for-women-in-india/",
      ),
    ],

    // 4️⃣ Emergency Response & First Aid
    [
      CarouselItem(
        image: "assets/emergency_steps.jpg",
        heading: "What to Do in an Emergency – Steps for immediate safety",
        url: "https://studylib.net/doc/25496021/nstp-2-module-5--first-aid-and-emergency-management",
      ),
      CarouselItem(
        image: "assets/sos_calls.jpg",
        heading: "Effective SOS Calls – How to communicate distress quickly",
        url: "https://cpr.heart.org/",
      ),
      CarouselItem(
        image: "assets/first_aid.jpg",
        heading: "Basic First Aid – Treating minor injuries and shock",
        url: "https://www.americansti.org/",
      ),
      CarouselItem(
        image: "assets/self_defense_aftermath.jpg",
        heading: "Self-Defense Aftermath – Handling trauma and seeking help",
        url: "https://cprcertificationnow.com/blogs/mycpr-now-blog/empowering-women-through-first-aid-training-and-leadership",
      ),
      CarouselItem(
        image: "assets/bystander_intervention.jpg",
        heading: "Bystander Intervention – How others can safely help",
        url: "https://cprcertificationnow.com/blogs/mycpr-now-blog/empowering-women-in-cpr-and-first-aid-training",
      ),
    ],

    // 5️⃣ Myth vs. Reality in Self-Defense
    [
      CarouselItem(
        image: "assets/fighting_back.jpg",
        heading: "Fighting Back Always Works – Understanding when to resist",
        url: "https://thelegalcrusader.in/self-defense-law-in-context-with-indian-laws/",
      ),
      CarouselItem(
        image: "assets/strength_vs_technique.png",
        heading: "Strength vs. Technique – Why technique matters more",
        url: "https://www.thetimes.co.uk/article/i-used-my-21st-birthday-money-to-patent-an-app-that-protects-women-vf0bkqgt3",
      ),
      CarouselItem(
        image: "assets/pepper_spray.jpg",
        heading: "Pepper Spray is Enough – Evaluating self-defense tools",
        url: "https://lawlex.org/lex-pedia/what-is-permissible-for-women-to-carry-in-order-to-protect-themselves/21054",
      ),
      CarouselItem(
        image: "assets/running_option.jpg",
        heading: "Running Isn’t an Option – When escape is the best defense",
        url: "https://www.theguardian.com/society/2024/oct/16/uk-women-who-suffer-cardiac-arrest-in-public-less-likely-to-get-cpr-study-finds",
      ),
      CarouselItem(
        image: "assets/martial_artists.jpg",
        heading: "Only Martial Artists Can Defend – Simple techniques for everyone",
        url: "https://people.com/most-first-aid-dummies-do-not-have-breasts-which-jeopardizes-women-health-8751320",
      ),
    ],

    // 6️⃣ Mental Preparedness & Confidence Building
    [
      CarouselItem(
        image: "assets/staying_calm.jpg",
        heading: "Staying Calm Under Threat – Managing fear and panic",
        url: "https://cprcertificationnow.com/blogs/mycpr-now-blog/empowering-women-through-first-aid-training-and-leadership",
      ),
      CarouselItem(
        image: "assets/de_escalation_techniques.jpg",
        heading: "De-escalation Techniques – Talking your way out of danger",
        url: "https://cprcertificationnow.com/blogs/mycpr-now-blog/empowering-women-in-cpr-and-first-aid-training",
      ),
      CarouselItem(
        image: "assets/fear_vs_awareness.png",
        heading: "Fear vs. Awareness – Understanding productive caution",
        url: "https://studylib.net/doc/25496021/nstp-2-module-5--first-aid-and-emergency-management",
      ),
      CarouselItem(
        image: "assets/confidence_training.jpg",
        heading: "Confidence Through Training – Practicing moves for real-world use",
        url: "https://cpr.heart.org/",
      ),
      CarouselItem(
        image: "assets/safety_mindset.jpg",
        heading: "Building a Safety Mindset – Making self-defense a habit",
        url: "https://www.americansti.org/",
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Self Defence Training',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Hello,\nReady for today\'s training?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 20),

            // Sections
            for (int i = 0; i < sections.length; i++)
              _buildSection(sections[i], sectionContent[i]),
          ],
        ),
      ),
    );
  }

  // Helper function to build a section
  Widget _buildSection(String title, List<CarouselItem> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        SizedBox(height: 10),
        _buildCarousel(content),
        SizedBox(height: 20),
      ],
    );
  }

  // Helper function to build a carousel
  Widget _buildCarousel(List<CarouselItem> items) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: items.map((item) {
        return Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () async {
              // Open the URL when the card is clicked
              if (await canLaunch(item.url)) {
                await launch(item.url);
              } else {
                throw 'Could not launch ${item.url}';
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(item.image), // Use AssetImage for local images
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.5), // Equivalent to Colors.black.withOpacity(0.5)
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 8),
                    child: Text(
                      item.heading, // Use the heading from the CarouselItem
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}