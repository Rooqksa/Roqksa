import 'package:flutter/material_ui.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.listeners,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int listeners;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: .09)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.mic_external_on_rounded, size: 28),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                Column(children: [
                  const Icon(Icons.headphones_rounded, size: 18, color: Color(0xFFC7A8FF)),
                  const SizedBox(height: 4),
                  Text('$listeners', style: const TextStyle(fontSize: 12)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
