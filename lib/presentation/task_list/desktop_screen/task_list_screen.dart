import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ropulva_flutter_task/presentation/task_list/mobile_screen/task_card.dart';
import '../../../di/setup_locator.dart';
import '../../../domain/model/task_model.dart';

import '../../app_colors.dart';
import '../../bloc/task_bloc.dart';
import '../../bloc/task_event.dart';
import '../../bloc/task_state.dart';
import '../../upsert_task/mobile_screen/upsert_task_form.dart';
import '../../widgets/primary_button.dart';
import '../mobile_screen/primary_chip.dart';

class TaskListMobileScreen extends StatefulWidget {
  const TaskListMobileScreen({super.key});

  @override
  _TaskListMobileScreenState createState() => _TaskListMobileScreenState();
}

class _TaskListMobileScreenState extends State<TaskListMobileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskBloc>()..add(GetTasksEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Good Morning',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 30.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.green));
            } else if (state is TaskError) {
              return Center(
                  child: Text('Error loading tasks: ${state.message}'));
            } else if (state is TaskLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: TaskFilter.values.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: PrimaryChip(
                            filter: filter,
                            isSelected: filter == state.selectedFilter,
                            onClick: () => setState(() {
                              BlocProvider.of<TaskBloc>(context)
                                  .add(ChangeTaskFilterEvent(filter));
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(child: _buildTaskList(context, state.tasks)),
                  Padding(
                    padding: EdgeInsets.all(16.h),
                    child: PrimaryButton(
                      onPressed: () {
                        _showUpsertTaskBottomSheet(context, null,
                            (String title, DateTime dateTime) {
                          BlocProvider.of<TaskBloc>(context)
                              .add(AddTaskEvent(title, dateTime));
                        });
                      },
                      text: 'Create Task',
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No tasks available.'));
            }
          },
        ),
      ),
    );
  }

  void _showUpsertTaskBottomSheet(BuildContext context, TaskModel? task,
      Function(String title, DateTime dateTime) onSaveTask) {
    final titleController = TextEditingController();
    final dueDateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (task != null) {
      titleController.text = task.title;
      dueDateController.text = DateFormat.yMMMd().add_jm().format(task.dueDate);
    }

    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: UpsertTaskForm(
            formKey: formKey,
            titleController: titleController,
            dueDateController: dueDateController,
            onSaveTask: (String title, DateTime dateTime) {
              onSaveTask(title, dateTime);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskModel> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: TaskCard(
            task: task,
            onDelete: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
            },
            onChangeTaskState: () {
              context.read<TaskBloc>().add(ChangeIsDoneEvent(task));
            },
            onTask: () {
              _showUpsertTaskBottomSheet(context, task,
                  (String title, DateTime dateTime) {
                BlocProvider.of<TaskBloc>(context).add(UpdateTaskEvent(
                    task.copyWith(title: title, dueDate: dateTime)));
              });
            },
          ),
        );
      },
    );
  }
}
