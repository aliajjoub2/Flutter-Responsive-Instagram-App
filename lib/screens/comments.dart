
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:uuid/uuid.dart';

import '../firebase_services/firestore.dart';
import '../provider/user_provider.dart';
import '../shared/colors.dart';
import '../shared/contants.dart';

class CommentsScreen extends StatefulWidget {
  // data of clicked post
  final Map data;
  bool showTextField = true;
  CommentsScreen({Key? key, required this.data, required this.showTextField})
      : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Comments',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('postSSS')
                .doc(widget.data["postId"])
                .collection("commentSSS")
                .orderBy("dataPublished", descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Colors.white,
                );
              }

              return Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(125, 78, 91, 110),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            data["profilePic"]
                                            // "https://cdn1-m.zahratalkhaleej.ae/store/archive/image/2020/11/4/813126b3-4c9d-4a7b-b8d9-83f46749fa26.jpg?format=jpg&preset=w1900"
                      
                                            ),
                                        radius: 26,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(data["username"],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17)),
                                            SizedBox(
                                              width: 11,
                                            ),
                                          
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                            DateFormat('MMM d, ' 'y').format(
                                                data["dataPublished"].toDate()),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {}, icon: Icon(Icons.favorite))
                              ],
                            ),
                              SizedBox(
                                          width: 250,
                                          child: Text(data["textComment"],
                                              style: const TextStyle(fontSize: 16)),
                                        )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          widget.showTextField
              ? Container(
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
                                hintText: "Comment as  ${userData.username}  ",
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      await FirestoreMethods().uploadComment(
                                          commentText: commentController.text,
                                          postId: widget.data["postId"],
                                          profileImg: userData.profileImg,
                                          username: userData.username,
                                          uid: userData.uid);

                                      commentController.clear();
                                    },
                                    icon: Icon(Icons.send)))),
                      ),
                    ],
                  ),
                )
              : Text("")
        ],
      ),
    );
  }
}