import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/routing/router.dart';

class ScaffoldWithNavbar extends StatefulWidget {
  Widget child;

  String titel;
  final appBarItems = [routes['startScreen'], routes['searchScreen']];

  ScaffoldWithNavbar({
    Key? key,
    required this.child,
    required this.titel,
  }) : super(key: key);

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.titel),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Suche',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 126, 115, 101),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          context.go(widget.appBarItems[index]!);
        },
      ),
    );
  }
}
