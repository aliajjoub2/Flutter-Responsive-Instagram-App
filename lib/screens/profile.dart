// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instegram/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../firebase_services/firestore.dart';
import '../provider/user_provider.dart';
import '../shared/colors.dart';
import 'chatingOneToOne.dart';

class Profile extends StatefulWidget {
  final String uiddd;
  final String imagPath;
  final String username;

  const Profile(
      {Key? key,
      required this.uiddd,
      required this.imagPath,
      required this.username})
      : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map userDate = {};
  bool isLoading = true;
  late var snapshotChatMember;

  late int followers;
  late int following;
  late int postCount;
  late bool showFollow;
// get number zhe folower and fowlling and
  getData() async {
    // Get data from DB

    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('userSSS')
          .doc(widget.uiddd)
          .get();

      userDate = snapshot.data()!;

      followers = userDate["followers"].length;
      following = userDate["following"].length;

      showFollow = userDate["followers"]
          .contains(FirebaseAuth.instance.currentUser!.uid);

      //  To get posts length
      var snapshotPosts = await FirebaseFirestore.instance
          .collection('postSSS')
          .where("uid", isEqualTo: widget.uiddd)
          .get();

      postCount = snapshotPosts.docs.length;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    //getChatMembers();
  }

  @override
  Widget build(BuildContext context) {
    // provider of user Data
    final userData = Provider.of<UserProvider>(context).getUser;
    // screen width
    final double widthScreen = MediaQuery.of(context).size.width;
    if (isLoading) {
      return Scaffold(
        backgroundColor: mobileBackgroundColor,
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        )),
      );
    } else {
      return Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: Text(userDate["username"]),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 22),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(125, 78, 91, 110),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userDate["profileImg"]),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            postCount.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Posts",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 17,
                      ),
                      Column(
                        children: [
                          Text(
                            followers.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Followers",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 17,
                      ),
                      Column(
                        children: [
                          Text(
                            following.toString(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Following",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),

            // title
            Container(
                margin: EdgeInsets.fromLTRB(33, 21, 0, 0),
                width: double.infinity,
                child: Text(userDate["title"])),
            SizedBox(
              height: 15,
            ),
            Divider(
              color: Colors.white,
              thickness: widthScreen > 600 ? 0.06 : 0.43,
            ),
            SizedBox(
              height: 9,
            ),
            // chatinh button
            ElevatedButton(
              onPressed: () async {
                try {
                  //To get posts length
                  List itemSingleChat = [
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.uiddd
                  ];
                  itemSingleChat.sort();

                  var snapshotChatMember = await FirebaseFirestore.instance
                      .collection('chating')
                      .where('chatingMembers', isEqualTo: itemSingleChat)
                      .get();
                  print('--------');
                  print(snapshotChatMember.docs.length);

                  print('-------');
                  if (snapshotChatMember.docs.length == 0) {
                    String chatingId = const Uuid().v1();
                    //FirebaseFirestore.instance.collection('chating').add(data)
                    await FirestoreMethods().uploadSingleChat(
                        context: context,
                        chatingMembers: itemSingleChat,
                        chatingId: chatingId);

                   await  FirestoreMethods().uploadChatfriends(
                      chatId: chatingId,
                      userID: widget.uiddd,
                      imagPath: userData!.profileImg,
                      username: userData.username,
                    );
                   await FirestoreMethods().uploadChatfriends(
                      chatId: chatingId,
                      userID: FirebaseAuth.instance.currentUser!.uid,
                      imagPath: widget.imagPath,
                      username: widget.username,
                    );

                    // add chat informationen to user Account
                    // await FirebaseFirestore.instance
                    //     .collection("userSSS")
                    //     .doc(widget.uiddd)
                    //     .update({
                    //   "chatFriends": FieldValue.arrayUnion([
                    //     {
                    //       'chatId': chatingId,
                    //       'username': userData!.username,
                    //       'imagPath': userData.profileImg
                    //     }
                    //   ])
                    // });

                    // await FirebaseFirestore.instance
                    //     .collection("userSSS")
                    //     .doc(FirebaseAuth.instance.currentUser!.uid)
                    //     .update({
                    //   "chatFriends": FieldValue.arrayUnion([
                    //     {
                    //       'chatId': chatingId,
                    //       'username': widget.username,
                    //       'imagPath': widget.imagPath
                    //     }
                    //   ])
                    // });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatingOneToOne(chatingId: chatingId),
                      ),
                    );
                  } else {
                    print('here before ali');
                    await FirebaseFirestore.instance
                        .collection('chating')
                        .where('chatingMembers', isEqualTo: itemSingleChat)
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        var chatingId = doc["chatingId"];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatingOneToOne(chatingId: chatingId),
                          ),
                        );
                      }
                    });
                  }
                } catch (e) {
                  print(e.toString());
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(143, 255, 55, 112)),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 9, horizontal: 66)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              child: Text(
                "Chating",
                style: TextStyle(fontSize: 17),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // Edit profile and Logout
            widget.uiddd == FirebaseAuth.instance.currentUser!.uid
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.edit,
                          color: Colors.grey,
                          size: 24.0,
                        ),
                        label: Text(
                          "Edit profile",
                          style: TextStyle(fontSize: 17),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(0, 90, 103, 223)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: widthScreen > 600 ? 19 : 10,
                                  horizontal: 33)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                              side: BorderSide(
                                  color: Color.fromARGB(109, 255, 255, 255),
                                  // width: 1,
                                  style: BorderStyle.solid),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.logout,
                          size: 24.0,
                        ),
                        label: Text(
                          "Log out",
                          style: TextStyle(fontSize: 17),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(143, 255, 55, 112)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: widthScreen > 600 ? 19 : 10,
                                  horizontal: 33)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )

// ________________________________________________________________

                : showFollow
                    ?

// ____________________________________________________________
// unfollow buttom
                    ElevatedButton(
                        onPressed: () async {
                          followers--;
                          setState(() {
                            showFollow = false;
                          });

                          // widget.uiddd ==> الشخص الغريب

                          await FirebaseFirestore.instance
                              .collection("userSSS")
                              .doc(widget.uiddd)
                              .update({
                            "followers": FieldValue.arrayRemove(
                                [FirebaseAuth.instance.currentUser!.uid])
                          });

                          await FirebaseFirestore.instance
                              .collection("userSSS")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "following": FieldValue.arrayRemove([widget.uiddd])
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(143, 255, 55, 112)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 66)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                        child: Text(
                          "unfollow",
                          style: TextStyle(fontSize: 17),
                        ),
                      )
// Follow buttom
                    : ElevatedButton(
                        onPressed: () async {
                          followers++;
                          setState(() {
                            showFollow = true;
                          });

                          // widget.uiddd ==> الشخص الغريب

                          await FirebaseFirestore.instance
                              .collection("userSSS")
                              .doc(widget.uiddd)
                              .update({
                            "followers": FieldValue.arrayUnion(
                                [FirebaseAuth.instance.currentUser!.uid])
                          });

                          await FirebaseFirestore.instance
                              .collection("userSSS")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "following": FieldValue.arrayUnion([widget.uiddd])
                          });
                        },
                        style: ButtonStyle(
                          // backgroundColor: MaterialStateProperty.all(
                          //     Color.fromARGB(0, 90, 103, 223)),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 77)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                        child: Text(
                          "Follow",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
            SizedBox(
              height: 9,
            ),
            Divider(
              color: Colors.white,
              thickness: widthScreen > 600 ? 0.06 : 0.43,
            ),
            SizedBox(
              height: 19,
            ),
            // posts of user
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('postSSS')
                  .where("uid", isEqualTo: widget.uiddd)
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: Padding(
                      padding: widthScreen > 600
                          ? const EdgeInsets.all(66.0)
                          : const EdgeInsets.all(3.0),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                // snapshot.data!.docs  = [  {"imgPost": 000000000}, {"imgPost": 0000000}    ]

                                snapshot.data!.docs[index]["imgPost"],
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : Center(
                                          child: CircularProgressIndicator());
                                },

                                // "https://cdn1-m.alittihad.ae/store/archive/image/2021/10/22/6266a092-72dd-4a2f-82a4-d22ed9d2cc59.jpg?width=1300",
                                // height: 333,
                                // width: 100,

                                fit: BoxFit.cover,
                              ),
                            );
                          }),
                    ),
                  );
                }

                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ));
              },
            )
          ],
        ),
      );
    }
  }
}
