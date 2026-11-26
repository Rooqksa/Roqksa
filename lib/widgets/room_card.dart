// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: const Color(0xFF182C3D),
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: .42)),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  color.withValues(alpha: .20),
                  const Color(0xFF182C3D),
                  const Color(0xFF152638),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [color, color.withValues(alpha: .58)],
                    ),
                    borderRadius: BorderRadius.circular(19),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: .22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_external_on_rounded, size: 29, color: Colors.white),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Color(0xFF70E6A8), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          const Text('مباشر الآن', style: TextStyle(color: Color(0xFF70E6A8), fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.headphones_rounded, size: 18, color: Color(0xFF8DEBE2)),
                      const SizedBox(height: 3),
                      Text(
                        '$listeners',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_left_rounded, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
