import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';

class TabScreen extends StatefulWidget {
  final PreferredSizeWidget Function(PreferredSizeWidget tabBar) appBarBuilder;
  final List<TabModel> tabs;
  final bool scrollableBody;

  const TabScreen({super.key, required this.tabs, required this.appBarBuilder, this.scrollableBody = true});

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
    return Scaffold(
      appBar: widget.appBarBuilder(
        CustomTabBar(
          tabController: _tabController,
          tabs: widget.tabs,
          onTap: (index) => setState(() => _tabController.index = index),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: widget.scrollableBody ? null : NeverScrollableScrollPhysics(),
        children: widget.tabs.map((tab) => tab.view).toList(),
      ),
    );
  }
}
