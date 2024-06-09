import 'package:flutter/material.dart';
import 'package:flutter_demo/page/page1.dart';
import 'package:flutter_demo/page/camera.dart';
import 'package:flutter_demo/page/app_settings.dart';
import 'package:flutter_demo/page/google_map.dart';

class HomeWidget extends StatefulWidget {
  final BuildContext parentCtx;
  HomeWidget({Key? key, required this.parentCtx});

  static int _currentIndex = 0;

  @override
  State createState() => _HomeState();

}

class _HomeState extends State<HomeWidget>{
  final List<Widget> screens = [];
  final pageController = PageController(initialPage: 0);
  bool ready = false;
  String? username = "";

  @override
  void initState(){
    super.initState();
    HomeWidget._currentIndex = 0;
  }

  List<BottomNavigationBarItem> getTabs(BuildContext context) => [
    BottomNavigationBarItem(
        label: "GoogleMap", icon: Icon(Icons.directions_run)),
    BottomNavigationBarItem(
        label: "AppSet", icon: Icon(Icons.directions_run)),
    BottomNavigationBarItem(
        label: "camera", icon: Icon(Icons.list)),
    BottomNavigationBarItem(
        label: "page1", icon: Icon(Icons.directions_run)),
  ];

  List<Widget> _children() => [
    MapsDemo(),
    AppSet(),
    CameraExampleHome(),
    Page1(),
  ];

  changePage(int index){
    setState(() {
      HomeWidget._currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    var tabs = getTabs(context);
    return WillPopScope(
        onWillPop: () async {
        print('home exit!!!');
        return false;
      },
        
      child:Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("DEMO", style: TextStyle(color: Colors.white, fontSize: 20)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey,
        ),
        body: PageView(
            onPageChanged: (index) {
              FocusScope.of(context).unfocus();
              changePage(index);
            },
            controller: pageController,
            children: _children()
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(widget.parentCtx).colorScheme.secondary,
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped, // new
          currentIndex: HomeWidget._currentIndex, // new
          items: tabs,
        ),
      )
    );

  }

  void onTabTapped(int index) {
    setState(() {
      HomeWidget._currentIndex = index;
      pageController.animateToPage(HomeWidget._currentIndex, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }
}