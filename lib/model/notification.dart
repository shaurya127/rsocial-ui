class NotificationModel {
  final String senderId;
  final String id;
  final String text;
  bool readFlag;
  // final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
  // final txt = timeago.format(DateTime.now().subtract(diff), locale: locale);

  NotificationModel({this.senderId, this.id, this.text, this.readFlag});

  factory NotificationModel.fromJson(final json) {
    return NotificationModel(
        senderId: json['SenderUUID'],
        id: json['NotificationUUID'],
        text: json['NotificationText'],
        readFlag: json['ReadFlag']);
  }
}
