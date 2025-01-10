import 'package:flutter/material.dart';
import 'package:gruene_app/app/screens/error_screen.dart';

class FutureLoadingScreen<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(T data) buildChild;

  const FutureLoadingScreen({super.key, required this.load, required this.buildChild});

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
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (snapshot.hasError || !snapshot.hasData || data == null) {
          return ErrorScreen(
            error: snapshot.error?.toString() ?? 'Unknown error',
            retry: () => setState(() => _data = widget.load()),
          );
        }

        return widget.buildChild(data);
      },
    );
  }
}
