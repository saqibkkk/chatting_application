import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Screens/settings.dart';
import 'package:ourchat/Widgets/chatusercard.dart';
import 'package:ourchat/utils.dart';
import '../API/api.dart';
import '../Auth/login_screen.dart';
import '../Controllers/ThemeController.dart';
import '../Controllers/chatreplycontroller.dart';
import '../main.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUserModel> _list = [];
  final List<ChatUserModel> _searchList = [];
  bool _isSearching = false;
  final ThemeController themeController = Get.find();
  bool _isLongPressActive = false;



  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  void updateLongPressState(bool isActive, [ChatUserModel? chatUser]) {
    setState(() {
      _isLongPressActive = isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      id: "0",
      builder: (theme) {
        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.appbar,
              title: _isSearching
                  ? TextField(
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: theme.textColor),
                  border: InputBorder.none,
                  hintText: 'Search with Name or Email',
                ),
                autofocus: true,
                style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.5,
                  color: theme.textColor,
                ),
                onChanged: (val) {
                  _searchList.clear();
                  for (var i in _list) {
                    if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                        i.email.toLowerCase().contains(val.toLowerCase())) {
                      _searchList.add(i);
                    }
                  }
                  setState(() {});
                },
              )
                  : Text(
                'Hi👋, ${APIs.me.name} ',
                style: TextStyle(color: theme.textColor),
              ),
              actions: _isLongPressActive
                  ? [
                IconButton(
                  onPressed: () async {},
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.textColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    updateLongPressState(false);
                  },
                  icon: Icon(
                    Icons.archive_outlined,
                    color: theme.textColor,
                  ),
                ),
              ]
                  : [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,
                    color: theme.textColor,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: PopupMenuButton<String>(
                    iconColor: theme.textColor,
                    color: theme.appbar,
                    offset: Offset(0, 45),
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Text('Settings',
                            style: TextStyle(color: theme.textColor)),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout',
                            style: TextStyle(color: theme.textColor)),
                      ),
                    ],
                    onSelected: (String value) async {
                      if (value == 'settings') {
                        Get.to(Settings());
                      } else if (value == 'logout') {
                        // Show progress dialog
                        Utils.showProgressBar(context);

                        // Update active status (if needed)
                        await APIs.updateActiveStatus(false);

                        // Sign out from Firebase auth
                        await APIs.auth.signOut();

                        // Sign out from Google if using Google sign-in
                        await GoogleSignIn().signOut();

                        // Dismiss progress dialog
                        Navigator.of(context).pop();

                        // Navigate to login screen
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => LoginScreen()),
                                (route) => false);
                      }
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: theme.appbar,
              onPressed: _addChatUserDialog,
              child: Icon(Icons.add, color: theme.appbarNeg,),
            ),

            body: Container(
              color: theme.backgroundColor2,
              child: StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: CircularProgressIndicator());

                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return Center(child: CircularProgressIndicator());

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                  ?.map((e) =>
                                  ChatUserModel.fromJson(e.data()))
                                  .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _list.length,
                                  padding: EdgeInsets.only(top: mq.height * .01),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index],
                                      longPressCallback: updateLongPressState,
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(
                                      color: theme.textColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              }
                          }
                        },
                      );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => GetBuilder<ThemeController>(
          id: "0",
          builder: (theme) {
            return AlertDialog(
              backgroundColor: theme.appbar,
              contentPadding: const EdgeInsets.only(
                  left: 15, right: 15, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: theme.textColor,
                    size: 28,
                  ),
                  Text(
                    '  Add User',
                    style: TextStyle(color: theme.textColor),
                  )
                ],
              ),
              content: TextFormField(
                style: TextStyle(color: theme.textColor),
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: theme.textColor),
                  hintText: 'Email Id',
                  prefixIcon: Icon(Icons.email, color: theme.textColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: theme.textColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: theme.textColor),
                  ),
                ),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel',
                        style: TextStyle(
                            color: theme.textColor, fontSize: 16))),
                MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Utils.showSnackbar(
                                'Error', 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                          color: theme.textColor, fontSize: 16),
                    ))
              ],
            );
          },
        ));
  }
}
