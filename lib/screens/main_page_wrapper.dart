import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/screens/accountPage.dart';
import 'package:job_connect/screens/applicationPages/applicationNotifications.dart';
import 'package:job_connect/screens/home_page.dart';
import 'package:job_connect/screens/myAds_page.dart';
import 'package:job_connect/screens/postAdd_page.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class MainPagesWraper extends StatefulWidget {
  static const id = 'MainPagesWraper';
  const MainPagesWraper({Key? key}) : super(key: key);

  @override
  _MainPagesWraperState createState() => _MainPagesWraperState();
}

class _MainPagesWraperState extends State<MainPagesWraper> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    //_hideNavBar = false;
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      onWillPop: (context) async {
        await showDialog(
          context: context!,
          useSafeArea: true,
          builder: (context) => Container(
            height: 50.0,
            width: 50.0,
            color: Colors.white,
            child: ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
        return false;
      },
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style18, // Choose the nav bar style with this property.
    );
  }

  List<Widget> _buildScreens() {
    return [
      HomePage(),
      ApplicationsNotificationsPage(),
      SellPage(),
      MyAdsPage(),
      AccountPage(),
    ];
  }

  _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: Theme.of(context).iconTheme.color!,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.work),
        title: ("Applications"),
        activeColorPrimary: Theme.of(context).iconTheme.color!,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.add_circled_solid),
        title: ("Sell"),
        activeColorPrimary: Theme.of(context).iconTheme.color!,
        inactiveColorPrimary: Colors.white, //CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.heart_fill),
        title: ("My Ads"),
        activeColorPrimary: Theme.of(context).iconTheme.color!,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person_fill),
        title: ("Account"),
        activeColorPrimary: Theme.of(context).iconTheme.color!,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}
