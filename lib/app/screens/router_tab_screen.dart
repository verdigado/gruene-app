import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/widgets/tab_bar.dart';

class RouterTabScreen extends StatefulWidget {
  final PreferredSizeWidget Function(PreferredSizeWidget tabBar) appBarBuilder;
  final List<TabModelBase> tabs;
  final bool scrollableBody;
  final List<Widget> children;
  final StatefulNavigationShell navigationShell;

  const RouterTabScreen({
    super.key,
    required this.tabs,
    required this.appBarBuilder,
    this.scrollableBody = true,
    required this.children,
    required this.navigationShell,
  });

  @override
  State<RouterTabScreen> createState() => _RouterTabScreenState();
}

class _RouterTabScreenState extends State<RouterTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.navigationShell.currentIndex,
    );
    _tabController.addListener(_switchedTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController.removeListener(_switchedTab);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RouterTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabController.index != widget.navigationShell.currentIndex) {
      _tabController.index = widget.navigationShell.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(
        CustomTabBar(
          tabController: _tabController,
          tabs: widget.tabs,
          onTap: (index) =>
              widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: widget.scrollableBody ? null : NeverScrollableScrollPhysics(),
        children: widget.children,
      ),
    );
  }

  void _switchedTab() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.navigationShell.goBranch(
          _tabController.index,
          initialLocation: _tabController.index == widget.navigationShell.currentIndex,
        );
      });
    });
  }
}
