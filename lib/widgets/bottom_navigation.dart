import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.grey.shade800),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.explore,
                label: 'Explore',
                isSelected: provider.seccionActual == 'explore',
                onTap: () => provider.cambiarSeccion('explore'),
              ),
              _buildNavItem(
                icon: Icons.playlist_play,
                label: 'Mis Playlists',
                isSelected: provider.seccionActual == 'playlists',
                onTap: () => provider.cambiarSeccion('playlists'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.deepPurple : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}