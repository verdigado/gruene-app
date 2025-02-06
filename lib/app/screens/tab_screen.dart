import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/app/widgets/main_layout.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';

class TabScreen extends StatefulWidget {
  final List<TabModel> tabs;

  const TabScreen({super.key, required this.tabs});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: MainAppBar(
        tabBar: CustomTabBar(
          tabController: _tabController,
          tabs: widget.tabs,
          onTap: (index) => setState(() => _tabController.index = index),
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: widget.tabs.map((tab) => tab.view).toList(),
      ),
    );
  }
}
