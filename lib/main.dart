import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mediaconverter/pages/history_page.dart';
import 'pages/images_page.dart';
import 'pages/videos_page.dart';
import 'pages/audios_page.dart';
import 'package:mediaconverter/theme/app_colors.dart';

void main() async {
  await dotenv.load();
  runApp(MediaConverterApp());
}

class MediaConverterApp extends StatelessWidget {
  const MediaConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Converter',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        fontFamily: 'Arial',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    ImagesPage(),
    VideosPage(),
    AudiosPage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.white,
        backgroundColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Images'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.headphones), label: 'Audios'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
