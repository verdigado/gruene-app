import 'package:flutter/material.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class BottomNavigationItem {
  final String label;
  final IconData? icon;
  final String? assetIcon;

  BottomNavigationItem({required this.label, this.icon, this.assetIcon}) : assert(icon != null || assetIcon != null);
}

final List<BottomNavigationItem> bottomNavigationItems = [
  BottomNavigationItem(label: t.news.label, icon: Icons.feed_outlined),
  BottomNavigationItem(label: t.events.label, icon: Icons.event),
  BottomNavigationItem(label: t.campaigns.label, icon: Icons.campaign_outlined),
  BottomNavigationItem(label: t.profiles.label, icon: Icons.group_outlined),
  BottomNavigationItem(label: t.mfa.label, assetIcon: 'assets/icons/mfa.svg'),
  BottomNavigationItem(label: t.tools.label, icon: Icons.menu_outlined),
];
