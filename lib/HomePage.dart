// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:svs/AddNewRegion.dart';
import 'package:svs/AddNewVoter.dart';
import 'package:svs/HomePageAdmin.dart';
import 'package:svs/Regions.dart';

import 'Global.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  PageController _pageController = PageController();
  int _selectedIndex = 0;
  String navBarName = 'Home';

  BottomNavigationBarItem getBottomItem(
      String label, Widget active, Widget inActive) {
    return BottomNavigationBarItem(
        backgroundColor: Colors.grey.shade50,
        label: label,
        icon: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            inActive,
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  height: 7,
                  width: 50,
                ),
              ),
            )
          ],
        ),
        activeIcon: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            active,
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  height: 7,
                  width: 50,
                ),
              ),
            )
          ],
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
      if (index == 0) {
        navBarName = 'Groups';
      } else if (index == 1) {
        navBarName = 'Chats';
      } else if (index == 2) {
        navBarName = 'Voters';
      }
    });
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionBubble(
        // Menu items
        items: <Bubble>[
          Bubble(
            title: "Register New Voting Region",
            iconColor: textColor,
            bubbleColor: Colors.red,
            icon: Icons.group,
            titleStyle: TextStyle(fontSize: 16, color: textColor),
            onPress: () {
              _animationController.reverse();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((BuildContext context) => AddNewRegion())));
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Add New Voter",
            iconColor: textColor,
            bubbleColor: Colors.red,
            icon: Icons.person,
            titleStyle: TextStyle(fontSize: 16, color: textColor),
            onPress: () {
              _animationController.reverse();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((BuildContext context) => AddNewVoter())));
            },
          ),
          //Floating action menu item
        ],

        // animation controller
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),

        // Floating Action button Icon color
        iconColor: Colors.white,

        // Flaoting Action button Icon
        iconData: Icons.add,

        backGroundColor: Colors.red,
      ),
      body: PageView(
          dragStartBehavior: DragStartBehavior.start,
          allowImplicitScrolling: false,
          scrollBehavior: ScrollBehavior(),
          pageSnapping: false,
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: <Widget>[
            HomePageAdmin(),
            Regions(),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.red,
        onTap: _onItemTapped,
        items: [
          getBottomItem(
              'Home',
              Icon(
                Icons.home_filled,
                color: textColor,
                size: 20,
              ),
              Icon(
                Icons.home_filled,
                color: textColor,
                size: 20,
              )),
          getBottomItem(
              'Regions',
              Icon(
                Icons.area_chart_rounded,
                color: textColor,
              ),
              Icon(
                Icons.area_chart_rounded,
                color: textColor,
              )),
        ],
      ),
    );
  }
}
