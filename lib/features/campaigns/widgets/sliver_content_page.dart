import 'package:flutter/material.dart';
import 'package:gruene_app/features/campaigns/widgets/custom_sliver_app_bar.dart';

class SliverContentPage extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SliverContentPage({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.secondary),
      child: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(title: title),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList(delegate: SliverChildListDelegate(children)),
          ),
        ],
      ),
    );
  }
}
