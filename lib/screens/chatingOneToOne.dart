import 'package:cloud_firestore/cloud_firestore.dart';
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
  const ChatingOneToOne(
      {Key? key, required  this.chatingId})
      : super(key: key);

  @override
  State<ChatingOneToOne> createState() => _ChatingOneToOneState();
}

class _ChatingOneToOneState extends State<ChatingOneToOne> {
  
  final commentController = TextEditingController();

    @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// provider
 final userData = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title:  Text(
          widget.chatingId,
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
                      child: Text(widget.chatingId),
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
                            controller: commentController,
                            keyboardType: TextInputType.text,
                            
                      maxLines: 4,
                            obscureText: false,
                            decoration: decorationTextfield.copyWith(
                                hintText: "Message as  ${userData.username}  ",
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      // await FirestoreMethods().uploadComment(
                                      //     );

                                      commentController.clear();
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
