// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<User> usersFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJsonLocal(x)));

String usersToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJsonLocal())));

class UserFields {
  static const List<String> values = [createdAt, name, avatar, id];

  static const String createdAt = "createdAt";
  static const String name = "name";
  static const String avatar = "avatar";
  static const String id = "_id";
  static const String isSynced = "isSynced";
}

class User {
  final DateTime createdAt;
  final String name;
  final String? avatar;
  final String? id;
  final bool? isSynced;

  User({
    required this.createdAt,
    required this.name,
    this.avatar,
    this.id,
    this.isSynced,
  });

  User copy({
    DateTime? createdAt,
    String? name,
    String? avatar,
    String? id,
    bool? isSynced,
  }) =>
      User(
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        id: id ?? this.id,
        isSynced: isSynced ?? this.isSynced,
      );

  factory User.fromJsonLocal(Map<String, dynamic> json) => User(
        createdAt: DateTime.parse(json[UserFields.createdAt]),
        name: json[UserFields.name],
        avatar: json[UserFields.avatar],
        isSynced: json[UserFields.isSynced] == 1 ? true : false,
        id: json[UserFields.id].toString(),
      );

  Map<String, dynamic> toJsonLocal() => {
        UserFields.createdAt: createdAt.toIso8601String(),
        UserFields.name: name,
        UserFields.avatar: avatar ?? "",
        UserFields.isSynced: (isSynced != null
            ? isSynced!
                ? 1
                : 0
            : 0),
        UserFields.id: id,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        createdAt: DateTime.parse(json[UserFields.createdAt]),
        name: json[UserFields.name],
        avatar: json[UserFields.avatar],
        id: json[UserFields.id].toString(),
      );

  Map<String, dynamic> toJson() => {
        UserFields.createdAt: createdAt.toIso8601String(),
        UserFields.name: name,
        UserFields.avatar: avatar,
        UserFields.id: id,
      };
}
