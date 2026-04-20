import 'package:flutter/material.dart';

class MainNavScope extends InheritedWidget {
  final MainNavHostState state;

  const MainNavScope({
    super.key,
    required this.state,
    required super.child,
  });

  static MainNavHostState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavScope>()?.state;
  }

  @override
  bool updateShouldNotify(covariant MainNavScope oldWidget) => false;
}

class MainNavHost extends StatefulWidget {
  final List<Widget> tabs;
  final int initialIndex;
  final List<BottomNavigationBarItem> items;

  const MainNavHost({
    super.key,
    required this.tabs,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  State<MainNavHost> createState() => MainNavHostState();
}

class MainNavHostState extends State<MainNavHost> {
  late int index = widget.initialIndex;

  void goToTab(int i) {
    if (i < 0 || i >= widget.tabs.length) return;
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    return MainNavScope(
      state: this,
      child: Scaffold(
        body: IndexedStack(index: index, children: widget.tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: goToTab,
          type: BottomNavigationBarType.fixed,
          items: widget.items,
        ),
      ),
    );
  }
}
