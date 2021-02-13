class Connection {
  Connection({
    this.id,
    this.friendId,
  });

  String id;
  String friendId;

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json["id"],
        friendId: json["friendId"],
      );

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "friendId": this.friendId,
      };
}
