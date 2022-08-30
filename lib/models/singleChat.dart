import 'package:cloud_firestore/cloud_firestore.dart';

class SingleChatData {
  final String chatingId;
  
  final DateTime datePublished;
  final List chatingMembers;

  SingleChatData(
      {
      required this.chatingId,
      required this.datePublished,
      required this.chatingMembers,
     });

// To convert the UserData(Data type) to   Map<String, Object>
  Map<String, dynamic> convert2ChatMap() {
    return {
        "chatingId": chatingId,
        "chatingMembers": chatingMembers,
        "datePublished": datePublished
 
    };
  }

  // function that convert "DocumentSnapshot" to a User
// function that takes "DocumentSnapshot" and return a User

  static convertSnapChatModel( snap) {
    var snapshot = snap.data() ;
    return SingleChatData(
      chatingId: snapshot["chatingId"],
      chatingMembers: snapshot["chatingMembers"],
      datePublished: snapshot["datePublished"],
      
 
    );
  }
}