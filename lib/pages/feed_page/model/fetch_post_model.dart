import 'package:Wow/pages/feed_page/model/post_image_model.dart';

class FetchPostModel {
  bool? status;
  dynamic? message;
  List<Post>? post;

  FetchPostModel({this.status, this.message, this.post});

  FetchPostModel.fromJson( json) {
    status = json['status'];
    message = json['message'];
    if (json['post'] != null) {
      post = <Post>[];
      json['post'].forEach((v) {
        post!.add(Post.fromJson(v));
      });
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = {};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.post != null) {
      data['post'] = this.post!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Post {
  dynamic? id;
  dynamic? caption;
  int? shareCount;
  bool? isFake;
  List<PostImage>? postImage;
  dynamic? createdAt;
  dynamic? userId;
  bool? isProfileImageBanned;
  dynamic? name;
  dynamic? userName;
  dynamic? userImage;
  bool? isVerified;
  List<dynamic>? hashTag;
  bool? isLike;
  bool? isFollow;
  int? totalLikes;
  int? totalComments;
  dynamic? time;

  Post({
    this.id,
    this.caption,
    this.shareCount,
    this.isFake,
    this.postImage,
    this.createdAt,
    this.userId,
    this.isProfileImageBanned,
    this.name,
    this.userName,
    this.userImage,
    this.isVerified,
    this.hashTag,
    this.isLike,
    this.isFollow,
    this.totalLikes,
    this.totalComments,
    this.time,
  });

  Post.fromJson(dynamic json) {
    id = json['_id'];
    caption = json['caption'];
    shareCount = json['shareCount'];
    isFake = json['isFake'];
    if (json['postImage'] != null) {
      postImage = <PostImage>[];
      json['postImage'].forEach((v) {
        postImage!.add(PostImage.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    userId = json['userId'];
    isProfileImageBanned = json['isProfileImageBanned'];
    name = json['name'];
    userName = json['userName'];
    userImage = json['userImage'];
    isVerified = json['isVerified'];
    hashTag = json['hashTag']?.cast<dynamic>();
    isLike = json['isLike'];
    isFollow = json['isFollow'];
    totalLikes = json['totalLikes'];
    totalComments = json['totalComments'];
    time = json['time'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = {};
    data['_id'] = this.id;
    data['caption'] = this.caption;
    data['shareCount'] = this.shareCount;
    data['isFake'] = this.isFake;
    if (this.postImage != null) {
      data['postImage'] = this.postImage!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['userId'] = this.userId;
    data['isProfileImageBanned'] = this.isProfileImageBanned;
    data['name'] = this.name;
    data['userName'] = this.userName;
    data['userImage'] = this.userImage;
    data['isVerified'] = this.isVerified;
    data['hashTag'] = this.hashTag;
    data['isLike'] = this.isLike;
    data['isFollow'] = this.isFollow;
    data['totalLikes'] = this.totalLikes;
    data['totalComments'] = this.totalComments;
    data['time'] = this.time;
    return data;
  }
}
