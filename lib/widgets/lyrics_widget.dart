import 'package:flutter/material.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade900,
            Colors.purple.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lyrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We got it through our own valleys\n'
            'Searching for the ghost in the machine\n\n'
            'But the echoes of your digital heart\n'
            'Are the only real things\n'
            "I've seen\n\n"
            'Lost in the static of a neon sky\n'
            'Counting the bytes until we fly',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ethereal Echoes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'The Sonic Collective • Ultraviolet Dreams',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HIGH RES LOSSLESS',
                  style: TextStyle(fontSize: 10, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '2024 • 05:42 • 24-bit/192kHz',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}