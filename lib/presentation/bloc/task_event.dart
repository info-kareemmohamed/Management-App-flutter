import '../../domain/model/task_model.dart';
import '../widgets/primary_chip.dart';

abstract class TaskEvent {}

class GetTasksEvent extends TaskEvent {}

class ChangeTaskFilterEvent extends TaskEvent {
  final TaskFilter filter;

  ChangeTaskFilterEvent(this.filter);
}

class ChangeIsDoneEvent extends TaskEvent {
  final TaskModel task;

  ChangeIsDoneEvent(this.task);
}

class AddTaskEvent extends TaskEvent {
  final String title;
  final DateTime dateTime;

  AddTaskEvent(this.title, this.dateTime);
}

class UpdateTaskEvent extends TaskEvent {
  final TaskModel task;

  UpdateTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent(this.taskId);
}
