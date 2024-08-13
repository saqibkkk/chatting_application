import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/instance_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Screens/view_profile_screen.dart';
import 'package:ourchat/Widgets/message_card.dart';
import 'package:ourchat/utils.dart';

import '../API/api.dart';
import '../Controllers/ThemeController.dart';
import '../Controllers/chatreplycontroller.dart';
import '../Models/messages_model.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  final MessageModel? message;

  const ChatScreen({
    Key? key,
    required this.user,
    this.message,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  String _doubleTappedMessage = '';
  bool isReplying = false;
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  bool _messageCardBool = false;
  ThemeController theme = Get.find();
  ReplyingController reply = Get.find();

  void _handleMessageDoubleTap(String message) {
    setState(() {
      _doubleTappedMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: theme.appbar,
        statusBarColor: theme.appbar,
      ),
    );
    return GetBuilder<ThemeController>(
        id: "0",
        builder: (theme) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: () {
                  if (_showEmoji) {
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                    return Future.value(false);
                  } else {
                    return Future.value(true);
                  }
                },
                child: Scaffold(
                  backgroundColor: theme.backgroundColor2,
                  appBar: AppBar(
                    backgroundColor: theme.appbar,
                    automaticallyImplyLeading: false,
                    flexibleSpace: _appBar(),
                  ),
                  body: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      children: [
                        Image.asset(
                          'images/preview.png',
                          fit: BoxFit.cover,
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: StreamBuilder(
                                stream: APIs.getAllMessages(widget.user),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                    case ConnectionState.none:
                                      return SizedBox();
                                    case ConnectionState.active:
                                    case ConnectionState.done:
                                      final data = snapshot.data?.docs;
                                      _list = data
                                              ?.map((e) =>
                                                  MessageModel.fromJson(
                                                      e.data()))
                                              .toList() ??
                                          [];

                                      if (_list.isNotEmpty) {
                                        return ListView.builder(
                                            reverse: true,
                                            itemCount: _list.length,
                                            physics: BouncingScrollPhysics(),
                                            padding: EdgeInsets.only(
                                                top: mq.height * .01,
                                                bottom: mq.height * .02),
                                            itemBuilder: (context, index) {
                                              return MessageCard(
                                                message: _list[index],

                                              );
                                            });
                                      } else {
                                        return Center(
                                            child: Text(
                                          "Say Hi! 👋",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: theme.textColor),
                                        ));
                                      }
                                  }
                                },
                              ),
                            ),
                            if (_isUploading)
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )),
                            _chatInput(),
                            if (_showEmoji)
                              SizedBox(
                                height: mq.height * .31,
                                child: EmojiPicker(
                                  textEditingController: _textController,
                                  config: Config(
                                      emojiViewConfig: EmojiViewConfig(
                                    backgroundColor: theme.backgroundColor,
                                    columns: 10,
                                  )),
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _appBar() {
    return GetBuilder<ThemeController>(
        id: '0',
        builder: (theme) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: widget.user)));
            },
            child: StreamBuilder(
                stream: APIs.getUserInfo(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list = data
                          ?.map((e) => ChatUserModel.fromJson(e.data()))
                          .toList() ??
                      [];
                  return Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: theme.textColor,
                          )),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          height: mq.height * .05,
                          width: mq.height * .05,
                          imageUrl: list.isNotEmpty
                              ? list[0].image
                              : widget.user.image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.isNotEmpty ? list[0].name : widget.user.name,
                            style: TextStyle(
                                fontSize: 20,
                                color: theme.textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : Utils.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : widget.user.isOnline
                                    ? 'Online'
                                    : Utils.getLastActiveTime(
                                        context: context,
                                        lastActive: widget.user.lastActive),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textColor,
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }),
          );
        });
  }

  Widget _chatInput() {
    return GetBuilder<ReplyingController>(
      id: "0",
      builder: (reply) {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: mq.height * .01, horizontal: mq.width * .025),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.appbar,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [

                        // Container(
                        //   child: Padding(
                        //     padding:
                        //         const EdgeInsets.only(top: 8, left: 8, right: 8),
                        //     child: Card(
                        //         color: theme.grayColor,
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Text(
                        //             _doubleTappedMessage,
                        //             style: TextStyle(color: theme.textColor),
                        //           ),
                        //         )),
                        //   ),
                        // ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          // IconButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         FocusScope.of(context).unfocus;
                          //         _showEmoji = !_showEmoji;
                          //       });
                          //     },
                          //     icon: Icon(Icons.emoji_emotions,
                          //         color: theme.appbarNeg, size: 24)),
                          Expanded(
                              child: TextField(
                            style: TextStyle(color: theme.appbarNeg),
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onTap: () {
                              if (_showEmoji)
                                setState(() {
                                  _showEmoji = !_showEmoji;
                                });
                            },
                            decoration: InputDecoration(
                                hintText: 'Type Something...',
                                hintStyle: TextStyle(color: theme.appbarNeg),
                                border: InputBorder.none),
                          )),
                          IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> images =
                                    await picker.pickMultiImage(imageQuality: 70);
                                for (var i in images) {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  await APIs.sendChatImage(
                                      widget.user, File(i.path));
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.image,
                                color: theme.appbarNeg,
                                size: 24,
                              )),
                          IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera, imageQuality: 70);
                                if (image != null) {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  await APIs.sendChatImage(
                                      widget.user, File(image.path));
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                              },
                              icon: Icon(Icons.camera_alt,
                                  color: theme.appbarNeg, size: 24))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    APIs.sendMessage(widget.user, _textController.text, Type.text);
                    _textController.text = '';
                  }
                },
                shape: CircleBorder(),
                minWidth: 0,
                padding: EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 10),
                color: theme.appbarNeg,
                child: Icon(
                  Icons.send,
                  color: theme.appbar,
                  size: 26,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
