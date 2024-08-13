import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:ourchat/API/api.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Models/messages_model.dart';
import 'package:ourchat/Widgets/dialogs.dart';
import 'package:ourchat/utils.dart';

import '../Controllers/ThemeController.dart';
import '../Screens/chat_screen.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUserModel user;
  final Function(bool, ChatUserModel) longPressCallback;

  const ChatUserCard({
    Key? key,
    required this.user,
    required this.longPressCallback,
  }) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _msg;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      id: "0",
      builder: (theme) {
        return Container(
          color: theme.transparentColor,
          child: InkWell(
            onLongPress: () {
              setState(() {
                isLongPress = !isLongPress;
              });
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(user: widget.user,),
                ),
              );
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data
                    ?.map((e) => MessageModel.fromJson(e.data()))
                    .toList() ??
                    [];

                if (list.isNotEmpty) {
                  _msg = list[0];
                }

                return Column(
                  children: [
                    ListTile(
                      leading: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .3),
                          child: CachedNetworkImage(
                            height: mq.height * .055,
                            width: mq.height * .055,
                            imageUrl: widget.user.image,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        widget.user.name,
                        style: TextStyle(color: theme.textColor),
                      ),
                      subtitle: Text(
                        _msg != null
                            ? _msg!.type == Type.image
                            ? 'Image'
                            : _msg!.msg
                            : widget.user.about,
                        maxLines: 1,
                        style: TextStyle(color: theme.textColor),
                      ),
                      trailing: _msg == null
                          ? null
                          : _msg!.read.isEmpty &&
                          _msg!.fromId != APIs.user.uid
                          ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.appbarNeg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                          : _msg != null && isLongPress == true?
                      IconButton(onPressed: ()async{
                        String chatId = APIs.getConversationID(widget.user.id);
                        await APIs.deleteEntireChat(chatId);
                        setState(() {
                          isLongPress = false;
                        });
                      }, icon: Icon(Icons.delete_forever, color: theme.redColor,)):
                      Text(
                        Utils.getLastMessageTime(
                          context: context,
                          time: _msg!.sent,
                        ),
                        style: TextStyle(color: theme.textColor),
                      )
                    ),
                    Divider(thickness: 2),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

}
