import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../shared/colors.dart';

class ChatingOneToOne extends StatefulWidget {
  final itemSingleChat;
  final chatingId;
  const ChatingOneToOne(
      {Key? key, required this.itemSingleChat, this.chatingId})
      : super(key: key);

  @override
  State<ChatingOneToOne> createState() => _ChatingOneToOneState();
}

class _ChatingOneToOneState extends State<ChatingOneToOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title:  Text(
          '$widget.chatingId',
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chating')
                .doc(widget.chatingId)
                .collection('chats_content')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading Data");
              }

              return Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text('ali: ${data['chat_message']}'),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
