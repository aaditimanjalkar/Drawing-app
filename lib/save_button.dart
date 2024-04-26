import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const SaveButton({
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save),
      onPressed: onSave,
    );
  }
}
