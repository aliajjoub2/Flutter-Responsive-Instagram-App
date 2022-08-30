import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Chatshome extends StatefulWidget {
  const Chatshome({Key? key}) : super(key: key);

  @override
  State<Chatshome> createState() => _ChatshomeState();
}

class _ChatshomeState extends State<Chatshome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Comments',
        ),
      ),
      body: Text('Chats Home'),
    );
  }
}
