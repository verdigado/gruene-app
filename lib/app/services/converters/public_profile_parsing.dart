part of '../converters.dart';

extension PublicProfileParsing on PublicProfile {
  String fullName() {
    return '$firstName $lastName';
  }
}
