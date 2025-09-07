import 'dart:convert';
FetchCoinHistoryModel fetchCoinHistoryModelFromJson(String str) => FetchCoinHistoryModel.fromJson(json.decode(str));
String fetchCoinHistoryModelToJson(FetchCoinHistoryModel data) => json.encode(data.toJson());
class FetchCoinHistoryModel {
  FetchCoinHistoryModel({
      bool? status, 
      String? message, 
      List<Data>? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  FetchCoinHistoryModel.fromJson(dynamic json) {
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
FetchCoinHistoryModel copyWith({  bool? status,
  String? message,
  List<Data>? data,
}) => FetchCoinHistoryModel(  status: status ?? _status,
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
      int? payoutStatus, 
      String? reason, 
      int? type, 
      int? coin, 
      String? uniqueId, 
      String? date, 
      String? createdAt, 
      String? senderName, 
      String? receiverName, 
      bool? isIncome,}){
    _id = id;
    _payoutStatus = payoutStatus;
    _reason = reason;
    _type = type;
    _coin = coin;
    _uniqueId = uniqueId;
    _date = date;
    _createdAt = createdAt;
    _senderName = senderName;
    _receiverName = receiverName;
    _isIncome = isIncome;
}

  Data.fromJson(dynamic json) {
    _id = json['_id'];
    _payoutStatus = json['payoutStatus'];
    _reason = json['reason'];
    _type = json['type'];
    _coin = json['coin'];
    _uniqueId = json['uniqueId'];
    _date = json['date'];
    _createdAt = json['createdAt'];
    _senderName = json['senderName'];
    _receiverName = json['receiverName'];
    _isIncome = json['isIncome'];
  }
  String? _id;
  int? _payoutStatus;
  String? _reason;
  int? _type;
  int? _coin;
  String? _uniqueId;
  String? _date;
  String? _createdAt;
  String? _senderName;
  String? _receiverName;
  bool? _isIncome;
Data copyWith({  String? id,
  int? payoutStatus,
  String? reason,
  int? type,
  int? coin,
  String? uniqueId,
  String? date,
  String? createdAt,
  String? senderName,
  String? receiverName,
  bool? isIncome,
}) => Data(  id: id ?? _id,
  payoutStatus: payoutStatus ?? _payoutStatus,
  reason: reason ?? _reason,
  type: type ?? _type,
  coin: coin ?? _coin,
  uniqueId: uniqueId ?? _uniqueId,
  date: date ?? _date,
  createdAt: createdAt ?? _createdAt,
  senderName: senderName ?? _senderName,
  receiverName: receiverName ?? _receiverName,
  isIncome: isIncome ?? _isIncome,
);
  String? get id => _id;
  int? get payoutStatus => _payoutStatus;
  String? get reason => _reason;
  int? get type => _type;
  int? get coin => _coin;
  String? get uniqueId => _uniqueId;
  String? get date => _date;
  String? get createdAt => _createdAt;
  String? get senderName => _senderName;
  String? get receiverName => _receiverName;
  bool? get isIncome => _isIncome;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['payoutStatus'] = _payoutStatus;
    map['reason'] = _reason;
    map['type'] = _type;
    map['coin'] = _coin;
    map['uniqueId'] = _uniqueId;
    map['date'] = _date;
    map['createdAt'] = _createdAt;
    map['senderName'] = _senderName;
    map['receiverName'] = _receiverName;
    map['isIncome'] = _isIncome;
    return map;
  }

}