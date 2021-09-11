import 'package:chaatu/helpers/sharedPref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireDatabase {
  Future AddUserToDatabase(String uid, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userInfo);
  }

  Future<Stream<QuerySnapshot>> getUserbyUsernameSearch(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where('username', isGreaterThanOrEqualTo: username)
        .snapshots();
  }

  Future addMessageSend(
      String roomID, String msgID, Map<String, dynamic> msgInput) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(roomID)
        .collection("chats")
        .doc(msgID)
        .set(msgInput);
  }

  Future updateLastMessageSend(
      String roomID, Map<String, dynamic> lastMessageInfo) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(roomID)
        .update(lastMessageInfo);
  }

  creatChatRoom(String chatroomID, Map<String, dynamic> chatRoomInfo) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomID)
        .get();

    if (snapshot.exists) {
      // cat room already exist
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatroomID)
          .set(chatRoomInfo);
    }
  }

  Future<Stream<QuerySnapshot>> getChatroomMessages(String chatroomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedPrefController().getUsername();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("LastMsg_TimeStamp", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

  Future<QuerySnapshot> getUserbyUsername(String username) async {
    var ss = await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();

    return ss;
  }
}
