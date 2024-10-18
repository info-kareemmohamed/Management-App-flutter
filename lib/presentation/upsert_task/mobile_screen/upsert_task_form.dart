import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/primary_button.dart';
import '../../widgets/primary_text_field.dart';

class UpsertTaskForm extends StatelessWidget {
  const UpsertTaskForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.dueDateController,
    required this.onSaveTask,
  });

  final Function(String title, DateTime dateTime) onSaveTask;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController dueDateController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCloseButton(context),
            _buildTitle(context),
            const SizedBox(height: 16),
            PrimaryTextField(controller: titleController, hint: "Task title"),
            const SizedBox(height: 8),
            PrimaryTextField(
              controller: dueDateController,
              hint: "Due Date",
              onTap: () => _pickDueDate(context),
            ),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Color(0xffF24E1E)),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Create New Task',
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSaveButton() {
    return PrimaryButton(
      text: "Save Task",
      onPressed: () {
        if (formKey.currentState!.validate()) {
          // Extract title and due date
          final title = titleController.text;
          final dueDateText = dueDateController.text;

          // Parse dueDateText to DateTime using DateFormat
          final DateTime? dueDate =
              DateFormat.yMMMd().add_jm().parse(dueDateText, true);

          // Pass them to the onSaveTask function
          onSaveTask(title, dueDate!);
        }
      },
    );
  }

  void _pickDueDate(BuildContext context) async {
    final dateTime = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(minutes: 10)),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (dateTime != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final selectedDate = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          time.hour,
          time.minute,
        );
        dueDateController.text =
            DateFormat.yMMMd().add_jm().format(selectedDate);
      }
    }
  }
}
