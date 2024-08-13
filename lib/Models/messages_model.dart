class MessageModel {
  late final String toId;
  late final String msg;
  late final String read;
  late final String sent;
  late final String fromId;
  late final Type type;
  late final String lastMessageTime;

  MessageModel({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
    required this.lastMessageTime,
  });

  MessageModel.fromJson(Map<String, dynamic> json)
      : toId = json['toId'].toString(),
        msg = json['msg'].toString(),
        read = json['read'].toString(),
        type = json['type'].toString() == Type.image.name ? Type.image : Type.text,
        sent = json['sent'].toString(),
        fromId = json['fromId'].toString(),
        lastMessageTime = json['lastMessageTime'] ?? "";

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    data['lastMessageTime'] = lastMessageTime;
    return data;
  }
}


enum Type { text, image }
