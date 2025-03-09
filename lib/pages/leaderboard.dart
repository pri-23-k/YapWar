import 'package:flutter/material.dart';

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> profileImages = [
    "assets/lion.png",
    "assets/zebra.png",
    "assets/panda.png",
    "assets/ele.png",
  ];
  int currentIndex = 0; 

  void changeProfilePic(bool next) {
    setState(() {
      if (next) {
        currentIndex = (currentIndex + 1) % profileImages.length;
      } else {
        currentIndex =
            (currentIndex - 1 + profileImages.length) % profileImages.length; 
      }
    });
  }

  final List<Map<String, dynamic>> leaderboard = [
    {"rank": "1st", "username": "Alice"},
    {"rank": "2nd", "username": "Bob"},
    {"rank": "3rd", "username": "Charlie"},
    {"rank": "4th", "username": "You"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: () => changeProfilePic(false), // Move back
                ),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(profileImages[currentIndex]),
                  backgroundColor: Colors.grey[800],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                  onPressed: () => changeProfilePic(true), // Move forward
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "Your Username",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Leaderboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(
                          leaderboard[index]["rank"],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey[400]
                                    : index == 2
                                        ? Colors.brown
                                        : Colors.white,
                          ),
                        ),
                        title: Text(
                          leaderboard[index]["username"],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}