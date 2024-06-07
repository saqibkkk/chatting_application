import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Widgets/message_card.dart';

import '../API/api.dart';
import '../Models/messages_model.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    // Set the system UI overlay style for this screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
        statusBarIconBrightness:
            Brightness.dark, // Ensure icons are visible on a light background
      ),
    );
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);

            }else{
              return Future.value(true);

            }
          },
          child: Scaffold(
            backgroundColor: Colors.blue.shade50,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
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
                                  ?.map((e) => MessageModel.fromJson(e.data()))
                                  .toList() ??
                              [];
                
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _list.length,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    top: mq.height * .01, bottom: mq.height * .02),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            return Center(
                                child: Text(
                              "Say Hi! 👋",
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    },
                  ),
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                          emojiViewConfig: EmojiViewConfig(
                        backgroundColor: Colors.blue.shade50,
                        columns: 5,
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                      )),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black54,
              )),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              height: mq.height * .05,
              width: mq.height * .05,
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
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
                'Name',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 2),
              Text(
                'Last seen not available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus;
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(Icons.emoji_emotions,
                          color: Colors.blue, size: 24)),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if(_showEmoji)
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (image != null) {

                          await APIs.sendChatImage(widget.user, File(image.path));

                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blue,
                        size: 24,
                      )),
                  IconButton(
                      onPressed: () {
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image =
                              await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                          if (image != null) {

                            await APIs.sendChatImage(widget.user, File(image.path));

                          }
                        };
                      },
                      icon:
                          Icon(Icons.camera_alt, color: Colors.blue, size: 24))
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessages(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            shape: CircleBorder(),
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, right: 5, bottom: 10, left: 10),
            color: Colors.grey,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 26,
            ),
          )
        ],
      ),
    );
  }
}
