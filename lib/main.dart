import 'package:flutter/material.dart';
import 'screens/list_view_screen.dart';
import 'screens/grid_view_screen.dart';
import 'screens/shared_prefs_screen.dart';
import 'screens/async_screen.dart';
import 'screens/isolate_screen.dart';
void main()
{
  runApp(const Week4App());
}
class Week4App extends StatelessWidget
{
  const Week4App({super.key});
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title:'Week 4 Exercises',
      debugShowCheckedModeBanner:false,
      theme:ThemeData(
        useMaterial3:true,
        colorScheme:ColorScheme.fromSeed(
          seedColor:const Color(0xFF6C63FF),
          brightness:Brightness.light,
        ),
        appBarTheme:const AppBarTheme(
          centerTitle:true,
          elevation:0,
          scrolledUnderElevation:1,
        ),
      ),
      home:const MainScreen(),
    );
  }
}
class MainScreen extends StatefulWidget
{
  const MainScreen({super.key});
  @override
  State<MainScreen>createState()=>_MainScreenState();
}
class _MainScreenState extends State<MainScreen>
{
  int _currentIndex=0;
  final List<Widget> _screens=const
  [
    ListViewScreen(),
    GridViewScreen(),
    SharedPrefsScreen(),
    AsyncScreen(),
    IsolateScreen(),
  ];
  final List<NavigationDestination> _destinations=const
  [
    NavigationDestination(
      icon:Icon(Icons.list_outlined),
      selectedIcon:Icon(Icons.list),
      label:'List View',
    ),
    NavigationDestination(
      icon:Icon(Icons.grid_view_outlined),
      selectedIcon:Icon(Icons.grid_view),
      label:'Grid View',
    ),
    NavigationDestination(
      icon:Icon(Icons.save_outlined),
      selectedIcon:Icon(Icons.save),
      label:'SharedPrefs',
    ),
    NavigationDestination(
      icon:Icon(Icons.timer_outlined),
      selectedIcon:Icon(Icons.timer),
      label:'Async',
    ),
    NavigationDestination(
      icon:Icon(Icons.memory_outlined),
      selectedIcon:Icon(Icons.memory),
      label:'Isolates',
    ),
  ];
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body:IndexedStack(
        index:_currentIndex,
        children:_screens,
      ),
      bottomNavigationBar:NavigationBar(
        selectedIndex:_currentIndex,
        onDestinationSelected:(index)
        {
          setState(()=>_currentIndex=index);
        },
        destinations:_destinations,
        labelBehavior:NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}