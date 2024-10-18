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
import 'primary_chip.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskBloc>()..add(GetTasksEvent()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.white,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 94),
                        child: InkWell(
                          onTap: (){
                         _showUpsertTaskDialog(context, null,(String title, DateTime dateTime){
                           BlocProvider.of<TaskBloc>(context)
                               .add(AddTaskEvent(title, dateTime));
                         });
                          },
                          child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.green,
                              ),
                              child: const Icon(Icons.add,color: Colors.white,size: 47,)),
                        ),
                      )
                    ],
                  ),

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

  void _showUpsertTaskDialog(BuildContext context, TaskModel? task,
      Function(String title, DateTime dateTime) onSaveTask) {
    final titleController = TextEditingController();
    final dueDateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (task != null) {
      titleController.text = task.title;
      dueDateController.text = DateFormat.yMMMd().add_jm().format(task.dueDate);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          surfaceTintColor: AppColors.cardColor,
          content: UpsertTaskForm(
            formKey: formKey,
            titleController: titleController,
            dueDateController: dueDateController,
            onSaveTask: (String title, DateTime dateTime) {
              if (formKey.currentState?.validate() ?? false) {
                onSaveTask(title, dateTime);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }


  Widget _buildTaskList(BuildContext context, List<TaskModel> tasks) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.5,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.all(8.h),
          child: TaskCard(
            task: task,
            onDelete: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
            },
            onChangeTaskState: () {
              context.read<TaskBloc>().add(ChangeIsDoneEvent(task));
            },
            onTask: () {
              _showUpsertTaskDialog(context, task,
                  (String title, DateTime dateTime) {
                final TaskModel newTask =
                    TaskModel(id: task.id, title: title, dueDate: dateTime);
                BlocProvider.of<TaskBloc>(context)
                    .add(UpdateTaskEvent(newTask));
              });
            },
          ),
        );
      },
    );
  }
}
