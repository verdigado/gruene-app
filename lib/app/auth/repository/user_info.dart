// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class UserInfo {
  final String uidnumber;
  final String email;
  final List<String>? groups;
  final List<String>? roles;
  final String name;
  // ignore: non_constant_identifier_names
  final String preferred_username;
  // ignore: non_constant_identifier_names
  final String given_name;
  // ignore: non_constant_identifier_names
  final String family_name;

  UserInfo({
    required this.uidnumber,
    required this.email,
    this.groups,
    this.roles,
    required this.name,
    // ignore: non_constant_identifier_names
    required this.preferred_username,
    // ignore: non_constant_identifier_names
    required this.given_name,
    // ignore: non_constant_identifier_names
    required this.family_name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uidnumber': uidnumber,
      'email': email,
      'groups': groups,
      'roles': roles,
      'name': name,
      'preferred_username': preferred_username,
      'given_name': given_name,
      'family_name': family_name,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      uidnumber: map['uidnumber'] as String,
      email: map['email'] as String,
      groups: map['groups'] != null ? List<String>.from(map['groups'] as List<dynamic>) : null,
      roles: map['roles'] != null ? List<String>.from(map['roles'] as List<dynamic>) : null,
      name: map['name'] as String,
      preferred_username: map['preferred_username'] as String,
      given_name: map['given_name'] as String,
      family_name: map['family_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfo.fromJson(String source) => UserInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
