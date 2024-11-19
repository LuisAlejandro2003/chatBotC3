import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiKey = "AIzaSyCSODG2Bohy9_tSYKXAtrL6s3KEEk-smeI";

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isListening = false;
  bool _isConnected = true;
  String _speechText = '';
  String _selectedLanguage = "en-US";
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chatSession = _model.startChat();

    await _requestMicrophonePermission();
    await _checkInternetConnection();
    await _loadMessages();
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://google.com'));
      if (response.statusCode == 200) {
        setState(() {
          _isConnected = true;
        });
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            _stopListening();
          }
        },
        onError: (val) => print('Error: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _speechText = val.recognizedWords;
              _controller.text = _speechText;
            });
          },
          localeId: _selectedLanguage,
        );
      }
    } else {
      print("Permisos de micrófono denegados");
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _sendMessage() async {
    await _checkInternetConnection();
    if (!_isConnected) {
      setState(() {
        _messages.add(ChatMessage(
            text: "No se puede enviar el mensaje. Conéctate a Internet.", isUser: false));
      });
      return;
    }

    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isUser: true));
      });
      String userMessage = _controller.text;
      _controller.clear();

      setState(() {
        _messages.add(ChatMessage(text: "Analizando...", isUser: false));
      });

      try {
        final response = await _chatSession.sendMessage(Content.text(userMessage));
        final botResponse = response.text ?? "No se recibió respuesta";

        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: botResponse, isUser: false));
        });

        await _saveMessages();
        await _speak(botResponse);
      } catch (e) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(text: "Error: $e", isUser: false));
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(text);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave = _messages
        .take(40)
        .map((msg) => "${msg.isUser ? 'user:' : 'bot:'}${msg.text}")
        .toList();
    await prefs.setStringList('chatMessages', messagesToSave);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList('chatMessages');

    if (savedMessages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(savedMessages.map((msg) {
          bool isUser = msg.startsWith('user:');
          String text = msg.replaceFirst(isUser ? 'user:' : 'bot:', '');
          return ChatMessage(text: text, isUser: isUser);
        }).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text(
          'Chatbot AI',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.pink,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: _messages[index].isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    color: _messages[index].isUser ? Colors.pink[100] : Colors.white,
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _messages[index].text,
                        style: TextStyle(
                          color: _messages[index].isUser ? Colors.pink[800] : Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.pink,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pink),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
