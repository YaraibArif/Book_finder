import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search books, authors, ISBN…",
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchTap,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
