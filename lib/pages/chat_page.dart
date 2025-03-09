import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'timer_count.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  ParticleOptions particles = const ParticleOptions(
    baseColor: Color.fromARGB(255, 253, 253, 253),
    spawnOpacity: 0.0,
    opacityChangeRate: 0.1,
    minOpacity: 0.5,
    maxOpacity: 0.9,
    particleCount: 100,
    spawnMaxRadius: 1.5,
    spawnMaxSpeed: 70.0,
    spawnMinSpeed: 20,
    spawnMinRadius: 1.0,
  );

  void sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        messages.add(_controller.text.trim());
      });
      _controller.clear();
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(options: particles),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/image.png",
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
              ),
              title: const Text(
                "Yap Wars Chat",
                style: TextStyle(fontFamily: "Jaro", color: Colors.white),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    height: 40,
                    child: CountUpTimer(maxDuration: Duration(minutes: 3)), // Updated duration
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isLeft = index % 2 == 0;
                  return Row(
                    mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      if (!isLeft)
                        Row(
                          children: [
                            _buildCircle(const Color.fromARGB(255, 214, 237, 255)),
                            SizedBox(width: 10),
                            _buildCircle(const Color.fromARGB(255, 139, 149, 201)),
                            SizedBox(width: 10),
                          ],
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isLeft
                              ? Color.fromARGB(255, 150, 52, 132)
                              : Color.fromARGB(255, 27, 153, 139),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          messages[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "SourceSerif4",
                            color: Colors.white,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      if (isLeft)
                        Row(
                          children: [
                            SizedBox(width: 10),
                            _buildCircle(const Color.fromARGB(255, 214, 237, 255)),
                            SizedBox(width: 10),
                            _buildCircle(const Color.fromARGB(255, 139, 149, 201)),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontFamily: "Jaro"),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.white, fontFamily: "Jaro"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      onSubmitted: (value) {
                        sendMessage();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.mic, color: _isListening ? Colors.red : Colors.blue),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(Color borderColor) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: borderColor, width: 2),
      ),
    );
  }
}
