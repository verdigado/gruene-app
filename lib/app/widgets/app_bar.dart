import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/campaigns/helper/campaign_action_cache.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:simple_animations/simple_animations.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? appBarAction;
  final PreferredSizeWidget? tabBar;

  const MainAppBar({super.key, this.appBarAction, this.tabBar});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context);
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is Authenticated;
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        currentRoute.name ?? '',
        style: theme.textTheme.displayMedium?.apply(color: isLoggedIn ? theme.colorScheme.surface : ThemeColors.text),
      ),
      foregroundColor: isLoggedIn ? theme.colorScheme.surface : ThemeColors.text,
      backgroundColor: isLoggedIn ? theme.primaryColor : theme.colorScheme.surfaceDim,
      centerTitle: true,
      bottom: tabBar,
      actions: [
        if (appBarAction != null) appBarAction!,
        if (currentRoute.path == Routes.campaigns.path) RefreshButton(),
        if (currentRoute.path != Routes.settings.path && isLoggedIn)
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.surface),
            onPressed: () => context.push(Routes.settings.path),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (tabBar == null ? 0 : kTextTabBarHeight));
}

class RefreshButton extends StatefulWidget {
  const RefreshButton({
    super.key,
  });

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  int _currentCount = 0;
  final campaignActionCache = GetIt.I<CampaignActionCache>();
  bool _animateIcon = false;

  @override
  void initState() {
    campaignActionCache.getCachedActionCount().then((value) {
      setState(() {
        _currentCount = value;
      });
    });
    campaignActionCache.addListener(_setCurrentCounter);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const maxLabelCount = 99;
    var labelText = _currentCount > maxLabelCount ? '$maxLabelCount+' : _currentCount.toString();

    getIcon() => Icon(Icons.sync_outlined, color: ThemeColors.background);

    var iconAnimated = LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * pi), // 0° to 360° (2π)
      duration: const Duration(seconds: 2), // for 2 seconds per iteration

      builder: (context, value, _) {
        return Transform.rotate(
          angle: value, // use value
          child: getIcon(),
        );
      },
    );

    return InkWell(
      onTap: _flushCachedData,
      onLongPress: _storeCacheDataOnDevice,
      child: Badge(
        label: Text(labelText),
        isLabelVisible: _currentCount != 0,
        child: _animateIcon ? iconAnimated : getIcon(),
      ),
    );
  }

  void _setCurrentCounter() async {
    final newCount = await campaignActionCache.getCachedActionCount();
    final isFlushing = campaignActionCache.isFlushing;
    if (!mounted) return;
    setState(() {
      _currentCount = newCount;
      _animateIcon = isFlushing;
    });
  }

  void _flushCachedData() {
    campaignActionCache.flushCache();
  }

  void _storeCacheDataOnDevice() async {
    final currentCount = await campaignActionCache.getCachedActionCount();
    if (currentCount == 0) return;

    var shouldStoreCache = await _confirmStoreCache();
    if (shouldStoreCache ?? false) {
      var cacheStored = await campaignActionCache.storeCacheOnDevice();
      if (cacheStored) {
        await _showStoreCacheSuccess();
      }
    }
  }

  Future<bool?> _confirmStoreCache() async {
    final theme = Theme.of(context);
    final shouldStoreCache = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.alertBackground,
          content: Text(
            t.campaigns.debug.confirm_storing_cache,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(
              color: theme.colorScheme.surface,
              fontSizeDelta: 1,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.maybePop(context, false),
              child: Text(
                t.common.actions.cancel,
                style: theme.textTheme.labelLarge?.apply(color: ThemeColors.textCancel),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.maybePop(context, true),
              child: Text(
                t.common.actions.save,
                style: theme.textTheme.labelLarge?.apply(
                  color: ThemeColors.textWarning,
                  fontWeightDelta: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
    return shouldStoreCache;
  }

  Future<void> _showStoreCacheSuccess() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.alertBackground,
          content: Text(
            t.campaigns.debug.storing_cache_success,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.apply(
              color: theme.colorScheme.surface,
              fontSizeDelta: 1,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            SizedBox.shrink(),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                t.common.actions.consent,
                style: theme.textTheme.labelLarge?.apply(
                  color: ThemeColors.background,
                  fontWeightDelta: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
