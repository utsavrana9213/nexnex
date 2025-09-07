class PostImage {
  dynamic? url;
  bool? isBanned;
  dynamic? id;

  PostImage({this.url, this.isBanned = false, this.id});

  /// Accepts either a String (url) or a full JSON Map
  factory PostImage.fromJson(dynamic json) {
    if (json is String) {
      return PostImage(url: json, isBanned: false, id: "");
    } else if (json is Map) {
      return PostImage(
        url: json['url'] ?? "",
        isBanned: json['isBanned'] ?? false,
        id: json['_id'] ?? "",
      );
    } else {
      return PostImage(url: "", isBanned: false, id: "");
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = {};
    data['url'] = this.url;
    data['isBanned'] = this.isBanned;
    data['_id'] = this.id;
    return data;
  }
}
