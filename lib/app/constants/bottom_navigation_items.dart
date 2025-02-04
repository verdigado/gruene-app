import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class BottomNavigationItem {
  final String label;
  final String route;
  final IconData? icon;
  final String? assetIcon;

  BottomNavigationItem({
    required this.label,
    required this.route,
    this.icon,
    this.assetIcon,
  }) : assert(icon != null || assetIcon != null);
}

final List<BottomNavigationItem> bottomNavigationItems = [
  BottomNavigationItem(label: t.news.label, route: Routes.news.path, icon: Icons.feed_outlined),
  BottomNavigationItem(label: t.campaigns.label, route: Routes.campaigns.path, icon: Icons.campaign_outlined),
  BottomNavigationItem(label: t.profiles.label, route: Routes.profiles.path, icon: Icons.group_outlined),
  BottomNavigationItem(label: t.mfa.label, route: Routes.mfa.path, assetIcon: 'assets/icons/mfa.svg'),
  BottomNavigationItem(label: t.tools.label, route: Routes.tools.path, icon: Icons.menu_outlined),
];
