// ignore_for_file: prefer_null_aware_operators

import 'package:ovorideuser/data/model/global/app/vehicle_brand_model.dart';

class GlobalDriverInfo {
  String? id; //
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  String? avatar;
  String? countryCode;
  String? mobile;
  String? address;
  String? totalReviews; //
  String? avgRating;
  String? onlineStatus; //
  String? status; //
  String? licenseNumber;
  String? licenseExpire;
  String? licensePhoto;
  String? dv; //
  List<String>? riderRuleId;
  String? ev; //
  String? sv; //
  String? profileComplete; //
  String? verCodeSendAt; //
  String? tsc; //
  String? banReason; //
  String? createdAt;
  String? updatedAt;
  String? imageWithPath;
  List<String>? rules;
  Brand? brand;
  GlobalDriverInfo({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.avatar,
    this.countryCode,
    this.mobile,
    this.address,
    this.totalReviews,
    this.avgRating,
    this.onlineStatus,
    this.status,
    this.licenseNumber,
    this.licenseExpire,
    this.licensePhoto,
    this.dv,
    this.riderRuleId,
    this.ev,
    this.sv,
    this.profileComplete,
    this.verCodeSendAt,
    this.tsc,
    this.banReason,
    this.createdAt,
    this.updatedAt,
    this.imageWithPath,
    this.rules,
    this.brand,
  });

  factory GlobalDriverInfo.fromJson(Map<String, dynamic> json) {
    return GlobalDriverInfo(
      id: json["id"].toString(),
      firstname: json["firstname"].toString(),
      lastname: json["lastname"].toString(),
      username: json["username"].toString(),
      email: json["email"].toString(),
      avatar: json["image"].toString(),
      countryCode: json["country_code"].toString(),
      mobile: json["mobile"].toString(),
      address: json["address"].toString(),
      brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
      totalReviews: json["total_reviews"].toString(),
      avgRating: json["avg_rating"].toString(),
      onlineStatus: json["online_status"].toString(),
      status: json["status"].toString(),
      licenseNumber: json["license_number"].toString(),
      licenseExpire: json["license_expire"] == null ? null : json["license_expire"].toString().toString(),
      licensePhoto: json["license_photo"].toString(),
      dv: json["dv"].toString(),
      riderRuleId: json["rider_rule_id"] == null ? [] : List<String>.from(json["rider_rule_id"]!.map((x) => x)),
      ev: json["ev"].toString(),
      sv: json["sv"].toString(),
      profileComplete: json["profile_complete"].toString(),
      verCodeSendAt: json["ver_code_send_at"].toString(),
      tsc: json["tsc"].toString(),
      banReason: json["ban_reason"].toString(),
      createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
      updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
      imageWithPath: json["image_with_path"] == null ? null : json["image_with_path"].toString(),
      rules: json["rules"] == null ? [] : List<String>.from(json["rules"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "username": username,
        "email": email,
        "avatar": avatar,
        "country_code": countryCode,
        "mobile": mobile,
        "address": address,
        "total_reviews": totalReviews,
        "avg_rating": avgRating,
        "online_status": onlineStatus,
        "status": status,
        "license_number": licenseNumber,
        "license_expire": licenseExpire,
        "license_photo": licensePhoto,
        "dv": dv,
        "rider_rule_id": riderRuleId == null ? [] : List<dynamic>.from(riderRuleId!.map((x) => x)),
        "ev": ev,
        "sv": sv,
        "profile_complete": profileComplete,
        "ver_code_send_at": verCodeSendAt,
        "tsc": tsc,
        "ban_reason": banReason,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image_with_path": imageWithPath,
        "rules": rules,
      };
}

class Address {
  String? address;
  String? city;
  String? state;
  String? zip;
  String? country;

  Address({
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        address: json["address"],
        city: json["city"],
        state: json["state"],
        zip: json["zip"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "city": city,
        "state": state,
        "zip": zip,
        "country": country,
      };
}

class Rule {
  String? id;
  String? name;
  String? status;
  String? createdAt;
  String? updatedAt;

  Rule({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        id: json["id"].toString(),
        name: json["name"],
        status: json["status"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
