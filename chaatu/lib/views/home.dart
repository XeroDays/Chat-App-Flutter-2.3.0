import 'package:chaatu/helpers/sharedPref.dart';
import 'package:chaatu/helpers/sysController.dart';
import 'package:chaatu/services/auth.dart';
import 'package:chaatu/services/database.dart';
import 'package:chaatu/views/chatScreen.dart';
import 'package:chaatu/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchBar = "";
  Stream<QuerySnapshot>? userStream;

  late String _Myusername;
  bool isSearching = false;
  Stream<QuerySnapshot>? chatroomsStream;
  processOnInitialize() async {
    await getMyInfo();
    setState(() {});
    updateChatrooms();
  }

  @override
  void initState() {
    processOnInitialize();
    super.initState();
  }

  Future getMyInfo() async {
    _Myusername = (await SharedPrefController().getUsername())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: Colors.grey, width: 2, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        onChanged: (val) {
                          if (val == "") isSearching = false;

                          searchBar = val;
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search username"),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        onSearchUsername();
                      },
                      child: Icon(Icons.search))
                ],
              ),
            ),
            isSearching ? searchUserList() : chatroomsList(),
          ],
        ),
      ),
    );
  }

  onSearchUsername() async {
    isSearching = true;
    userStream = await FireDatabase().getUserbyUsernameSearch(searchBar);
    setState(() {});
  }

  Widget searchUserList() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return getListItem(
                      doc['photoURL'], doc['username'], doc['name']);
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }

  getListItem(String url, String username, String name) {
    return InkWell(
      onTap: () {
        onUserItemClicked(username, name);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Container(
                width: 40,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(url))),
            SizedBox(
              width: 10,
            ),
            Text(
              username,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("Chaatuu App"),
      actions: [
        InkWell(
          onTap: () async {
            Authentication().SignOut().then((value) =>
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SignIn())));
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.logout),
          ),
        ),
      ],
    );
  }

  onUserItemClicked(String username, String name) async {
    var chatroomID = fetchChatroomID(username, _Myusername);

    Map<String, dynamic> chatRoomInfo = {
      "users": [_Myusername, username]
    };

    await FireDatabase().creatChatRoom(chatroomID, chatRoomInfo);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatWithUsername: username, name: name)));
  }

  updateChatrooms() async {
    chatroomsStream = await FireDatabase().getChatRooms();
    setState(() {});
  }

  Widget chatroomsList() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: chatroomsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return ChatroomListTilee(
                      doc.id, doc["LastMessage"], _Myusername);
                },
              );
            } else {
              return Container(
                child: Text("Something Went Wrong"),
              );
            }
          }),
    );
  }
}

class ChatroomListTilee extends StatefulWidget {
  final String chatroomID, lastmsg, myUsername;
  ChatroomListTilee(this.chatroomID, this.lastmsg, this.myUsername);

  @override
  _ChatroomListTileeState createState() => _ChatroomListTileeState();
}

class _ChatroomListTileeState extends State<ChatroomListTilee> {
  String profilPic = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatroomID.replaceAll(widget.myUsername, "").replaceAll("_", "");

    QuerySnapshot user = await FireDatabase().getUserbyUsername(username);
    print(user.docs[0].id.toString());

    name = user.docs[0]["name"].toString();
    profilPic = user.docs[0]["photoURL"].toString();
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return profilPic == ""
        ? Container()
        : InkWell(
            onTap: () {
              onUserItemClicked(username, name);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    profilPic,
                    height: 50,
                    width: 50,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  name,
                  style: TextStyle(fontSize: 16),
                )
              ]),
            ),
          );
  }

  onUserItemClicked(String username, String name) async {
    var chatroomID = widget.chatroomID;

    Map<String, dynamic> chatRoomInfo = {
      "users": [widget.myUsername, username]
    };

    await FireDatabase().creatChatRoom(chatroomID, chatRoomInfo);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatWithUsername: username, name: name)));
  }
}
