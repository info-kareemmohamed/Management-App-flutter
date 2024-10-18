import 'package:flutter/material.dart';

import '../../app_colors.dart';

enum TaskFilter { all, done, notDone }

extension TaskFilterExtension on TaskFilter {
  String toText() {
    switch (this) {
      case TaskFilter.done:
        return 'Done';
      case TaskFilter.notDone:
        return 'Not Done';
      default:
        return 'All';
    }
  }
}

class PrimaryChip extends StatelessWidget {
  const PrimaryChip(
      {super.key,
      required this.filter,
      required this.onClick,
      required this.isSelected});

  final TaskFilter filter;
  final VoidCallback onClick;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.green : AppColors.lightGreen,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onClick,
      child: Text(
        filter.toText(),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: isSelected ? Colors.white : AppColors.green,
            ),
      ),
    );
  }
}
