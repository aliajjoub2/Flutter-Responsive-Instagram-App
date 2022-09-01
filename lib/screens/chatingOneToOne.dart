import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../firebase_services/firestore.dart';
import '../provider/user_provider.dart';
import '../shared/colors.dart';
import '../shared/contants.dart';

class ChatingOneToOne extends StatefulWidget {
  final chatingId;
  final uiddd;
  const ChatingOneToOne({Key? key, required this.chatingId, this.uiddd})
      : super(key: key);

  @override
  State<ChatingOneToOne> createState() => _ChatingOneToOneState();
}

class _ChatingOneToOneState extends State<ChatingOneToOne> {
  Map userDate = {};
  
  final messageController = TextEditingController();
  
   bool status= false;

  getDataFromcahtFriends() async {
    // Get data from DB
    var collection = FirebaseFirestore.instance.collection('userSSS');
    var docSnapshot = await collection
        .doc(widget.uiddd)
        .collection('chatFriends')
        .doc(widget.chatingId)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
       status = data!['status'];
      print('here status ------------');
      print(status); // <-- The value you want to retrieve.
      // Call setState if needed.
    }
    setState(() {
      
    });

    // try {
    //   DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
    //       .instance
    //       .collection('userSSS')
    //       .doc(widget.uiddd)
    //       .collection('chatFriends')
    //       .doc(widget.chatingId)
    //       .get();
    //   print('here 1');
    //   status = snapshot.get('status');
    //   print('here 2');

    //   print('here 3');
    //   following = userDate["following"].length;

    //   showFollow = userDate["followers"]
    //       .contains(FirebaseAuth.instance.currentUser!.uid);

    //   //  To get posts length
    //   var snapshotPosts = await FirebaseFirestore.instance
    //       .collection('postSSS')
    //       .where("uid", isEqualTo: widget.uiddd)
    //       .get();

    //   postCount = snapshotPosts.docs.length;
    // } catch (e) {
    //   print(e.toString());
    // }

    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  void dispose() {
    messageController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromcahtFriends();
    //getChatMembers();
  }

  @override
  Widget build(BuildContext context) {
// provider
    final userData = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          //userData!.username,
          status.toString()
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
                      child: Text(data['message']),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // start input text message
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                
                
                Container(
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(125, 78, 91, 110),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userData!.profileImg),
                    radius: 26,
                  ),
                ),
                Expanded(
                  child: TextField(
                      controller: messageController,
                      keyboardType: TextInputType.text,
                      maxLines: 4,
                      obscureText: false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Message as  ${userData.username}  ",
                          suffixIcon: IconButton(
                              onPressed: () async {
                                await FirestoreMethods().uploadMessage(
                                    chatingID: widget.chatingId,
                                    messsageText: messageController.text,
                                    username: userData.username,
                                    uid: userData.uid);

                                // add unreadNumber(); if statue is not true make function to increase the unreadNumber

                                messageController.clear();
                              },
                              icon: Icon(Icons.send)))),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
