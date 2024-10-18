import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/model/task_model.dart';
import '../../utils/constants.dart';

class LocalDataSource {
  final String _boxName = 'tasks';

  // Box to store the last updated timestamp
  // This is used to compare with the remote data to determine which data is the most recently updated
  final String _lastUpdatedDateBoxName = 'last_updated';

  // Initialize Hive and register TaskModel adapter
  static Future<void> initializeHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(TaskModelAdapter());
  }

  // Open a Hive box
  Future<Box<T>> _openBox<T>(String boxName) async {
    return await Hive.openBox<T>(boxName);
  }

  // Get the last updated date from the last updated box
  Future<int?> getLastUpdatedDate() async {
    var box = await _openBox<int>(_lastUpdatedDateBoxName);
    return box.get(Constants.LAST_UPDATED_DATE_KEY);
  }

  // Add or update a task and the last updated date
  Future<void> upsertTask(TaskModel task, int? lastDate) async {
    final newLastDate = lastDate ?? DateTime
        .now()
        .millisecondsSinceEpoch;
    final taskBox = await _openBox<TaskModel>(_boxName);
    final updatedBox = await _openBox<int>(_lastUpdatedDateBoxName);

    await taskBox.put(task.id, task);
    await updatedBox.put(Constants.LAST_UPDATED_DATE_KEY, newLastDate);

  }

  // Get a task by its ID
  Future<TaskModel?> getTask(String id) async {
    final box = await _openBox<TaskModel>(_boxName);
    return  box.get(id);
  }

  // Get all tasks
  Future<List<TaskModel>> getAllTasks() async {
    final box = await _openBox<TaskModel>(_boxName);
    return box.values.toList();
  }

  // Delete a task by its ID
  Future<void> deleteTask(String id) async {
    final taskBox = await _openBox<TaskModel>(_boxName);
    final updatedBox = await _openBox<int>(_lastUpdatedDateBoxName);

    await updatedBox.put(
        Constants.LAST_UPDATED_DATE_KEY, DateTime
        .now()
        .millisecondsSinceEpoch);
    await taskBox.delete(id);

  }

Future<void> upsertTasksToLocal(List<TaskModel> tasks, int? lastDate) async {
  for (var task in tasks) {
    await upsertTask(task, lastDate);
  }
}


  // Clear all tasks
  Future<void> clearTasks() async {
    await _openBox<TaskModel>(_boxName);
  }
}
