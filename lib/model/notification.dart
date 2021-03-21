class NotificationModel {
  final String senderId;
  final String id;
  final String text;
  bool readFlag;
  final DateTime dateTime;
  // final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
  // final txt = timeago.format(DateTime.now().subtract(diff), locale: locale);

  NotificationModel({
    this.senderId,
    this.id,
    this.text,
    this.readFlag,
    this.dateTime,
  });

  factory NotificationModel.fromJson(final json) {
    double datetime = json["ReceivedTime"];

    return NotificationModel(
        senderId: json['SenderUUID'],
        id: json['NotificationUUID'],
        text: json['NotificationText'],
        readFlag: json['ReadFlag'],
        dateTime: DateTime.fromMillisecondsSinceEpoch(datetime.toInt() * 1000));
  }
}
