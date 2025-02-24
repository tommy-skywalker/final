import 'package:ovorideuser/data/model/global/user/global_user_model.dart';

class ProfileResponseModel {
  ProfileResponseModel({String? remark, String? status, List<String>? message, Data? data}) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  ProfileResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    _message = json['message'] != null ? List<String>.from(json["message"]!.map((x) => x.toString())) : [];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? _remark;
  String? _status;
  List<String>? _message;
  Data? _data;

  String? get remark => _remark;
  String? get status => _status;
  List<String>? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = _remark;
    map['status'] = _status;
    if (_message != null) {
      map['message'] = _message;
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({GlobalUser? user, String? imagePath}) {
    _user = user;
    _imagePath = imagePath;
  }

  Data.fromJson(dynamic json) {
    _user = json['user'] != null ? GlobalUser.fromJson(json['user']) : null;
    _imagePath = json['image_path'] ?? '';
  }
  GlobalUser? _user;
  String? _imagePath;

  GlobalUser? get user => _user;
  String? get imagePath => _imagePath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['image_path'] = _imagePath;
    return map;
  }
}
