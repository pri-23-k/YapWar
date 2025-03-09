import 'dart:ui';
import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:yap/pages/chat_page.dart';

class MyAnimatedBackground extends StatefulWidget {
  const MyAnimatedBackground({super.key});

  @override
  State<MyAnimatedBackground> createState() => _MyAnimatedBackgroundState();
}

class _MyAnimatedBackgroundState extends State<MyAnimatedBackground>
    with SingleTickerProviderStateMixin {
  ParticleOptions particles = const ParticleOptions(
    baseColor: Color.fromARGB(255, 27, 153, 139),
    spawnOpacity: 0.0,
    opacityChangeRate: 0.1,
    minOpacity: 0.3,
    maxOpacity: 0.5,
    particleCount: 5,
    spawnMaxRadius: 200,
    spawnMaxSpeed: 70.0,
    spawnMinSpeed: 50,
    spawnMinRadius: 100.0,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(options: particles),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 25.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glass effect
                        ClipRRect(
                          borderRadius: BorderRadius.circular(250),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(250),
                               
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                        // Profile Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(250),
                          child: Image.asset(
                            'assets/images/image.png',
                            height: 260,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Yap Wars',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'PressStart2p',
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const Text(
                    'Where Arguments Go to War!',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'glitch',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 120),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white, width: 2),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Play',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
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