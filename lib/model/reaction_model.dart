class Reaction {
  Reaction({
    this.id,
    this.storyId,
    this.reactionType,
  });

  String id;
  String storyId;
  String reactionType;

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json["id"],
    storyId: json["StoryId"],
    reactionType: json["ReactionType"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "StoryId": storyId,
    "ReactionType": reactionType,
  };
}