import 'dart:convert';

FetchCoinPlanModel fetchCoinPlanModelFromJson(String str) => FetchCoinPlanModel.fromJson(json.decode(str));
String fetchCoinPlanModelToJson(FetchCoinPlanModel data) => json.encode(data.toJson());

class FetchCoinPlanModel {
  FetchCoinPlanModel({
    bool? status,
    String? message,
    List<Data>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchCoinPlanModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<Data>? _data;
  FetchCoinPlanModel copyWith({
    bool? status,
    String? message,
    List<Data>? data,
  }) =>
      FetchCoinPlanModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    String? id,
    int? coin,
    int? amount,
    String? icon,
    String? productKey,
    bool? isPopular,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _coin = coin;
    _amount = amount;
    _icon = icon;
    _productKey = productKey;
    _isPopular = isPopular;
    _isActive = isActive;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _coin = json['coin'];
    _amount = json['amount'];
    _icon = json['icon'];
    _productKey = json['productKey'];
    _isPopular = json['isPopular'];
    _isActive = json['isActive'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  String? _id;
  int? _coin;
  int? _amount;
  String? _icon;
  String? _productKey;
  bool? _isPopular;
  bool? _isActive;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    String? id,
    int? coin,
    int? amount,
    String? icon,
    String? productKey,
    bool? isPopular,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        coin: coin ?? _coin,
        amount: amount ?? _amount,
        icon: icon ?? _icon,
        productKey: productKey ?? _productKey,
        isPopular: isPopular ?? _isPopular,
        isActive: isActive ?? _isActive,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  String? get id => _id;
  int? get coin => _coin;
  int? get amount => _amount;
  String? get icon => _icon;
  String? get productKey => _productKey;
  bool? get isPopular => _isPopular;
  bool? get isActive => _isActive;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['coin'] = _coin;
    map['amount'] = _amount;
    map['icon'] = _icon;
    map['productKey'] = _productKey;
    map['isPopular'] = _isPopular;
    map['isActive'] = _isActive;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}
