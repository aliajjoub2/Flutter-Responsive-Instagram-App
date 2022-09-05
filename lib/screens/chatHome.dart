import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../shared/colors.dart';
import 'chatingOneToOne.dart';

class Chatshome extends StatefulWidget {
  const Chatshome({Key? key}) : super(key: key);

  @override
  State<Chatshome> createState() => _ChatshomeState();
}

class _ChatshomeState extends State<Chatshome> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Chats',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userSSS')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('chatFriends')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
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
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                          title: Text(data['username']),
                          leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                data['imagPath'],
                                loadingBuilder: (context, child, progress) {
                                  return progress == null
                                      ? child
                                      : Center(
                                          child: CircularProgressIndicator());
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                Text(data['unreadMessages'] != null &&
                                        data['unreadMessages'].length != 0
                                    ? data['unreadMessages'].length.toString()
                                    : ''),
                                Text(data['unreadMessages'] != null &&
                                        data['unreadMessages'].length != 0
                                    ? '-- ${(data['lastMessage'] as Timestamp).toDate().hour.toString()}:${(data['lastMessage'] as Timestamp).toDate().minute.toString()}'
                                    : ''),

                                // ((data['lastMessage'].toString().isNotEmpty)) ?
                                // Text('${(data['lastMessage'][0] as Timestamp).toDate().hour.toString()}:')
                                // : Text('')
                              ],
                            ),
                          ),
                          onTap: () async {
                            List unreadMessages = [];
                            // print(
                            //     '-----------------------kkkkkkkkkkkkkkkkkkkk');
                            // print(data['lastMessage']);
                            // here muss delete the unread Number
                            await FirebaseFirestore.instance
                                .collection("userSSS")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection("chatFriends")
                                .doc(data['chatId'])
                                .update({"unreadMessages": unreadMessages});

                            // remove the latst message date
                            // await FirebaseFirestore.instance
                            //     .collection("userSSS")
                            //     .doc(FirebaseAuth.instance.currentUser!.uid)
                            //     .collection("chatFriends")
                            //     .doc(data['chatId'])
                            //     .update({"lastMessage": FieldValue.delete()});
                            // change status to true
                            await FirebaseFirestore.instance
                                .collection("userSSS")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection("chatFriends")
                                .doc(data['chatId'])
                                .update({"status": true});

                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatingOneToOne(
                                          chatingId: data['chatId'],
                                          uiddd: data['userId'],
                                          username: data['username'],
                                        ) // another username for chat memeber
                                    )).then((context) async {
                              // change status to true
                              await FirebaseFirestore.instance
                                  .collection("userSSS")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection("chatFriends")
                                  .doc(data['chatId'])
                                  .update({"status": false});
                            });

                            // muss send the statue will true and send userid for another user with data back
                          }),
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
