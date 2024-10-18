import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../domain/model/task_model.dart';
import '../../app_colors.dart';
import '../../app_icons.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function onDelete;
  final Function onChangeTaskState;
  final Function onTask;

  const TaskCard(
      {super.key,
      required this.task,
      required this.onDelete,
      required this.onChangeTaskState,
      required this.onTask});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: AppColors.cardColor,
      surfaceTintColor: AppColors.cardColor,
      child: InkWell(
        onTap: () {
          onTask();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title, // Task title from TaskModel
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Due Date: ${DateFormat('E. d/M/yyyy').format(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => {onDelete()},
                    icon: SvgPicture.asset(
                      AppIcons.iconClose,
                      width: 24.h,
                      height: 24.h,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  IconButton(
                    onPressed: () => {onChangeTaskState()},
                    icon: task.isDone
                        ? SvgPicture.asset(
                            AppIcons.iconDone,
                            width: 24.h,
                            height: 24.h,
                          )
                        : SvgPicture.asset(
                            AppIcons.iconNotDone,
                            width: 24.h,
                            height: 24.h,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
