// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class SearchActionState {
  final bool isEnabled;
  final String actionText;
  final IconData? icon;

  SearchActionState.enabled({required this.actionText, this.icon}) : isEnabled = true;
  SearchActionState.disabled({required this.actionText, this.icon}) : isEnabled = false;
}
