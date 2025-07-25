import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';

class FutureLoadingScreen<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(T data, void Function(T newData) update) buildChild;
  final Widget Function(Widget child)? loadingLayoutBuilder;

  const FutureLoadingScreen({super.key, required this.load, required this.buildChild, this.loadingLayoutBuilder});

  @override
  State<FutureLoadingScreen<T>> createState() => _FutureLoadingScreenState<T>();
}

class _FutureLoadingScreenState<T> extends State<FutureLoadingScreen<T>> {
  late Future<T> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.load();
  }

  @override
  void didUpdateWidget(covariant FutureLoadingScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.load != oldWidget.load) {
      setState(() {});
      _data = widget.load();
    }
  }

  void _setData(T newData) {
    setState(() {});
    _data = Future.value(newData);
  }

  @override
  Widget build(BuildContext context) {
    final layoutBuilder = widget.loadingLayoutBuilder ?? (Widget child) => child;
    return FutureBuilder<T>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return layoutBuilder(Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data;
        if (snapshot.hasError || !snapshot.hasData || data == null) {
          return layoutBuilder(
            ErrorScreen(
              error: snapshot.error ?? Exception(),
              retry: () {
                setState(() {});
                _data = widget.load();
              },
            ),
          );
        }

        return widget.buildChild(data, _setData);
      },
    );
  }
}
