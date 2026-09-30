import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Image.asset(
            'assets/images/profile.jpg',
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ProfileFont',
                fontSize: 28,
                color: colors.primary,
              ),
            ),
          ),
          Text(
            university,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
