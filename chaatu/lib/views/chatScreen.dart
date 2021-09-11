import 'package:chaatu/helpers/sharedPref.dart';
import 'package:chaatu/helpers/sysController.dart';
import 'package:chaatu/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;

  const ChatScreen(
      {Key? key, required this.chatWithUsername, required this.name})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomID = "";
  String messageID = "";
  Stream<QuerySnapshot>? messageStream;
  late String _Myusername;

  TextEditingController txtMsg = new TextEditingController();

  Future getMyInfo() async {
    _Myusername = (await SharedPrefController().getUsername())!;

    chatRoomID = fetchChatroomID(widget.chatWithUsername, _Myusername);
  }

  getAndSetMessages() async {
    messageStream = await FireDatabase().getChatroomMessages(chatRoomID);
  }

  processOnInitialize() async {
    await getMyInfo();
    setState(() {});
    getAndSetMessages();
  }

  @override
  void initState() {
    processOnInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatWithUsername),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.65),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      onChanged: (val) {
                        addMesage(false);
                      },
                      controller: txtMsg,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                          hintText: "Type message here",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none),
                    )),
                    GestureDetector(
                      onTap: () {
                        addMesage(true);
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessages() {
    if (messageStream == null)
      return Container();
    else
      return StreamBuilder<QuerySnapshot>(
          stream: messageStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else
              return ListView.builder(
                  padding: EdgeInsets.only(bottom: 60, top: 8),
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return MessageBubble(
                        (ds["sendBy"].toString() == _Myusername) ? true : false,
                        ds["message"]);
                  });
          });
  }

  addMesage(bool sendClicked) {
    if (txtMsg.text != "") {
      String message = txtMsg.text;
      var lastmsgTimeStamp = Timestamp.now();
      Map<String, dynamic> msginfoMap = {
        "message": message,
        "sendBy": _Myusername,
        "timestamp": lastmsgTimeStamp,
      };

      if (messageID == "") {
        messageID = randomAlphaNumeric(12);
      }

      FireDatabase()
          .addMessageSend(chatRoomID, messageID, msginfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "LastMessage": message,
          "LastMsg_TimeStamp": lastmsgTimeStamp,
          "LastMsg_SentBy": _Myusername
        };
        FireDatabase().updateLastMessageSend(chatRoomID, lastMessageInfoMap);
      });

      if (sendClicked) {
        // rmeove text iput from textfield
        txtMsg.text = "";

        // msgiid will be blacked for new msg
        messageID = "";
      }
    }
  }
}

class MessageBubble extends StatelessWidget {
  final bool isMine;
  final String message;
  MessageBubble(this.isMine, this.message);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          IntrinsicWidth(
              child: Container(
            constraints: BoxConstraints(
                minWidth: 50,
                maxWidth: MediaQuery.of(context).size.width / 1.3),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: isMine ? Colors.blue : Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: isMine ? Radius.circular(20) : Radius.circular(0),
                bottomLeft: isMine ? Radius.circular(20) : Radius.circular(10),
                bottomRight: isMine ? Radius.circular(10) : Radius.circular(20),
                topRight: isMine ? Radius.circular(0) : Radius.circular(20),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
          )),
        ]);
  }
}
