import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String name;
  final int songCount;
  final Color color;

  const PlaylistCard({
    super.key,
    required this.name,
    required this.songCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.playlist_play, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$songCount songs'),
        trailing: const Icon(Icons.play_arrow, color: Colors.deepPurple),
        onTap: () {},
      ),
    );
  }
}