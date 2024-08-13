import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:ourchat/API/api.dart';
import 'package:ourchat/constants.dart';
import 'package:ourchat/utils.dart';

import '../Controllers/ThemeController.dart';
import '../Models/messages_model.dart';
import '../main.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard(
      {Key? key,
      required this.message,})
      : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {


  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showMessageDetails(isMe);
      },
      child: isMe ? _senderMessage() : _receiverMessage(),
    );
  }

  Widget _receiverMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print('Message read update');
    }

    return GetBuilder<ThemeController>(
      id: "0",
      builder: (theme) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * 0.03
                    : mq.width * 0.04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.width * .005),
                decoration: BoxDecoration(
                    color: theme.appbar,
                    border: Border.all(color: theme.appbar),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(fontSize: 18, color: theme.appbarNeg),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GestureDetector(
                          onTap: () {
                            _showFullImage(context, widget.message.msg);
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            width: 250, // Fixed width for receiver's image
                            height: 350,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: mq.width * .03),
              child: Text(
                Utils.getFormatedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 14, color: theme.appbarNeg),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _senderMessage() {
    return GetBuilder<ThemeController>(
      id: "0",
      builder: (theme) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: mq.width * .04),
                if (widget.message.read.isNotEmpty)
                  Icon(Icons.done_all_rounded,
                      color: theme.textColor, size: 20),
                const SizedBox(width: 2),
                Text(
                  Utils.getFormatedTime(
                      context: context, time: widget.message.sent),
                  style: TextStyle(fontSize: 13, color: theme.appbarNeg),
                ),
              ],
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .03
                    : mq.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .005),
                decoration: BoxDecoration(
                    color: theme.appbar,
                    border: Border.all(color: theme.appbar),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(fontSize: 18, color: theme.appbarNeg),
                      )
                    : GestureDetector(
                        onTap: () {
                          _showFullImage(context, widget.message.msg);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            width: 250,
                            height: 350,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder<ThemeController>(
          id: "0",
          builder: (theme) {
            return GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) =>
                      Center(child: const CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMessageDetails(bool isMe) {
    ThemeController theme = Get.find();
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return Container(
            color: theme.backgroundColor,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 10,
                ),
                widget.message.type == Type.text
                    ?
                    // Copy to clipboard
                    _OptionItems(
                        icon: Icon(
                          Icons.copy_all_outlined,
                          color: theme.textColor,
                        ),
                        name: 'Copy to Clipboard',
                        onTap: () async {
                          await Clipboard.setData(
                                  ClipboardData(text: widget.message.msg))
                              .then((value) {
                            Get.back();
                            Utils.showSnackbar(
                                'Saved', 'Message saved to Clipboard');
                          });
                        },
                      )
                    :
                    //     Save Image
                    _OptionItems(
                        icon: Icon(
                          Icons.download,
                          color: theme.textColor,
                        ),
                        name: 'Save Image',
                        onTap: () {
                          try {
                            GallerySaver.saveImage(widget.message.msg,
                                    albumName: 'Family Time')
                                .then((success) {
                              Get.back();
                              if (success != null && success) {
                                Utils.showSnackbar(
                                    'Successful!', 'Image saved successfully!');
                              }
                            });
                          } catch (e) {
                            print('Error downloding image: $e');
                          }
                        },
                      ),
                if (isMe)
                  Divider(
                    color: theme.textColor,
                    endIndent: mq.width * .04,
                    indent: mq.width * .04,
                  ),
                // Edit Message
                if (widget.message.type == Type.text && isMe)
                  _OptionItems(
                    icon: Icon(
                      Icons.edit,
                      color: theme.textColor,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      Get.back();
                      _showMessageUpdateDialog();
                    },
                  ),
                // Delete Message
                if (isMe)
                  _OptionItems(
                    icon: Icon(
                      Icons.delete_forever,
                      color: theme.redColor,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Get.back();
                      });
                    },
                  ),
                Divider(
                  color: theme.textColor,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
                // Message Sent time
                _OptionItems(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: theme.textColor,
                  ),
                  name:
                      'Sent At: ${Utils.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {},
                ),
                // Message Receive Time
                _OptionItems(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: theme.greenColor,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet.'
                      : 'Read At: ${Utils.getFormatedTime(context: context, time: widget.message.read)}',
                  onTap: () {},
                ),
              ],
            ),
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    ThemeController theme = Get.find();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: theme.appbar,
              contentPadding:
                  EdgeInsets.only(bottom: 10, top: 20, left: 15, right: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: theme.textColor,
                  ),
                  Text(
                    '  Update Message',
                    style: TextStyle(color: theme.textColor),
                  )
                ],
              ),
              content: TextFormField(
                style: TextStyle(color: theme.textColor),
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.textColor),
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.textColor),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Get.back();
                    APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: theme.textColor),
                  ),
                )
              ],
            ));
  }
}

class _OptionItems extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  _OptionItems(
      {Key? key, required this.icon, required this.name, required this.onTap})
      : super(key: key);

  ThemeController theme = Get.find();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '   $name',
                style: TextStyle(color: theme.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
