import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/now_playing_bar.dart';
import 'explore_screen.dart';
import 'playlists_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _getIndexFromSeccion(provider.seccionActual),
                  children: const [
                    ExploreScreen(),
                    PlaylistsScreen(),
                  ],
                ),
              ),
              const NowPlayingBar(),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }

  int _getIndexFromSeccion(String seccion) {
    switch (seccion) {
      case 'explore':
        return 0;
      case 'playlists':
        return 1;
      default:
        return 0;
    }
  }
}