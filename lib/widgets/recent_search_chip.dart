import 'package:flutter/material.dart';

class RecentSearchChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const RecentSearchChip({
    super.key,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(query),
        onPressed: onTap,
      ),
    );
  }
}
