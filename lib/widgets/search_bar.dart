import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.onSubmitted,
    required this.isLoading,
  });

  final TextEditingController controller;
  final VoidCallback onPressed;
  final ValueChanged<String> onSubmitted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(32),
      color: Colors.white,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Поиск города',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
