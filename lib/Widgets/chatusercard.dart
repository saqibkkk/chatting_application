import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ourchat/API/api.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Models/messages_model.dart';
import 'package:ourchat/utils.dart';

import '../Screens/chat_screen.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUserModel user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  MessageModel? _msg;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey,
      elevation: 3,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
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

                return ListTile(
                  leading: ClipRRect(
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
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _msg != null ? _msg!.msg : widget.user.about,
                    maxLines: 1,
                  ),
                  // trailing: Text('12:00 PM'),
                  trailing: _msg == null ? null :
                  _msg!.read.isEmpty && _msg!.fromId != APIs.user.uid
                      ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.shade700,
                        borderRadius: BorderRadius.circular(10)),
                  ):
                      Text(Utils.getLastMessageTime(context: context, time: _msg!.sent))
                );
              })),
    );
  }
}
