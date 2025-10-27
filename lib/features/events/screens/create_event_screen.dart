import 'package:flutter/material.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/i18n/translations.g.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: t.events.events),
      body: const Center(child: Text('Event erstellen')),
    );
  }
}
