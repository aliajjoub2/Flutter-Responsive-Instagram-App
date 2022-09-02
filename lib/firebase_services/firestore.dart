import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../models/singleChat.dart';
import '../shared/snackbar.dart';
import 'storage.dart';

class FirestoreMethods {
  uploadPost(
      {required imgName,
      required imgPath,
      required description,
      required profileImg,
      required username,
      required context}) async {
    String message = "ERROR => Not starting the code";

    try {
// ______________________________________________________________________

      String urlll = await getImgURL(
          imgName: imgName,
          imgPath: imgPath,
          folderName: 'imgPosts/${FirebaseAuth.instance.currentUser!.uid}');

// _______________________________________________________________________
// firebase firestore (Database)
      CollectionReference posts =
          FirebaseFirestore.instance.collection('postSSS');

      String newId = const Uuid().v1();

      PostData postt = PostData(
          datePublished: DateTime.now(),
          description: description,
          imgPost: urlll,
          likes: [],
          profileImg: profileImg,
          postId: newId,
          uid: FirebaseAuth.instance.currentUser!.uid,
          username: username);

      message = "ERROR => erroe hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
      posts
          .doc(newId)
          .set(postt.convert2Map())
          .then((value) => print("done................"))
          .catchError((error) => print("Failed to post: $error"));

      message = " Posted successfully ♥ ♥";
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      print(e);
    }

    showSnackBar(context, message);
  }

  //----------------------------------------

  uploadSingleChat(
      {required context, required chatingMembers, required chatingId}) async {
    String message = "ERROR => Not starting the code";

    try {
// firebase firestore (Database)
      CollectionReference singleChatCollection =
          FirebaseFirestore.instance.collection('chating');

      SingleChatData singleChatContent = SingleChatData(
        datePublished: DateTime.now(),
        chatingId: chatingId,
        chatingMembers: chatingMembers,
      );

      message = "ERROR => erroe hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
      singleChatCollection
          .doc(chatingId)
          .set(singleChatContent.convert2ChatMap())
          .then((value) => print("done................"))
          .catchError((error) => print("Failed to post: $error"));

      message = " Chat created successfully ♥ ♥";
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      print(e);
    }

    showSnackBar(context, message);
  }

//-----------------------------------------------------------------
  uploadComment(
      {required commentText,
      required postId,
      required profileImg,
      required username,
      required uid}) async {
    if (commentText.isNotEmpty) {
      String commentId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection("postSSS")
          .doc(postId)
          .collection("commentSSS")
          .doc(commentId)
          .set({
        "profilePic": profileImg,
        "username": username,
        "textComment": commentText,
        "dataPublished": DateTime.now(),
        "uid": uid,
        "commentId": commentId
      });
    } else {
      print("emptyyyyyyyy");
    }
  }
// upload message in chating ont to one page
  uploadMessage(
      {required messsageText,
      required chatingID,
      
      required username,
      required uid}) async {
    if (messsageText.isNotEmpty) {
      String messageID = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection("chating")
          .doc(chatingID)
          .collection("chats_content")
          .doc(messageID)
          .set({
        
        "username": username,
        "message": messsageText,
        "dataPublished": DateTime.now(),
        "uid": uid,
        "messageId": messageID
      });
    } else {
      print("empty message");
    }
  }
// upload chat detaile to user page -----------------------------
 uploadChatfriends(
      {required chatId,
      required username,
      required imagPath,
      required toUserID,
      required userId,
      }) async {
    bool status= false;
      
      await FirebaseFirestore.instance
          .collection("userSSS")
          .doc(toUserID)
          .collection("chatFriends")
          .doc(chatId)
          .set({
        "chatId": chatId,
        "username": username,
        "dataPublished": DateTime.now(),
        "imagPath": imagPath,
        "userId": userId,
        "status": status
        
      });
   
  }
//---------------------------------

 uploadNotivigation(
      {required chatId,
     
      
      required toUserID,
      
       
       required List messsageText,
      }) async {
    
      
      await FirebaseFirestore.instance
          .collection("userSSS")
          .doc(toUserID)
          .collection("chatFriends")
          .doc(chatId)
          .set({
        
        "lastMessage": DateTime.now(),
        
        "unreadMessages": messsageText,
        
      }, SetOptions(merge: true),);
   
  }
//---------------------------------
  toggleLike({required Map postData}) async {
    try {
      if (postData["likes"].contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance
            .collection("postSSS")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await FirebaseFirestore.instance
            .collection("postSSS")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //-------------------
// functoin to get user details from Firestore (Database), we use this function for provider
   getChatID({required itemSingleChat}) async {
     var snap2 = await FirebaseFirestore.instance
        .collection('chating')
        .where('chatingMembers', isEqualTo: itemSingleChat)
        .get() ;
    return SingleChatData.convertSnapChatModel(snap2);
  }
}
