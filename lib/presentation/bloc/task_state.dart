
import '../../domain/model/task_model.dart';
import '../task_list/mobile_screen/primary_chip.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final TaskFilter selectedFilter;

  TaskLoaded(this.tasks,this.selectedFilter);
}

class TaskError extends TaskState {
  final String message;

  TaskError(this.message);
}

