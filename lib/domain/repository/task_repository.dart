
import '../model/task_model.dart';

abstract class TaskRepository {
  Future<TaskModel?> getTaskById(String taskId) async {}

  Future<List<TaskModel>?> getTasks() async {}

  Future<void> upsertTask(TaskModel task) async {}

  Future<void> deleteTask(String taskId) async {}

  Future<void> refreshTasksOnConnectivity() async{}
}
