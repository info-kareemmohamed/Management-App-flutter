import '../../data/local/local_data_source.dart';
import '../../data/remote/remote_data_source.dart';
import '../../domain/model/task_model.dart';
import '../../domain/repository/task_repository.dart';

/// TaskRepositoryImpl implements the TaskRepository interface.
///
/// This class follows the Single Source of Truth (SSOT) principle by
/// synchronizing task data between local and remote sources for consistency.
///
/// - Retrieves tasks from local storage for quick access.
/// - Updates and deletes tasks in both sources to maintain integrity.
/// - Syncs tasks based on connectivity to capture the latest updates.
///
/// This abstraction allows seamless interaction with task data.

class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<TaskModel?> getTaskById(String taskId) {
    // Get task from the local data source
    return localDataSource.getTask(taskId);
  }

  @override
  Future<List<TaskModel>?> getTasks() {
    // Fetch tasks from the local data source
    return localDataSource.getAllTasks();
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    final lastDate = DateTime.now().millisecondsSinceEpoch;
    await Future.wait([
      localDataSource.upsertTask(task, lastDate),
      remoteDataSource.upsertTask(task, lastDate),
    ]);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Delete the task from both local and remote data sources in parallel
    await Future.wait([
      localDataSource.deleteTask(taskId),
      remoteDataSource.deleteTask(taskId),
    ]);
  }

  @override
  Future<void> refreshTasksOnConnectivity() async {
    final localLastDate = await localDataSource.getLastUpdatedDate();
    final remoteLastDate = await remoteDataSource.getLastUpdateDate();

    if (localLastDate == remoteLastDate) return; // No updates needed

    // Sync based on which source is more up-to-date
    if (localLastDate == null) {
      await _syncFromRemote(remoteLastDate);
    } else if (remoteLastDate == null || localLastDate > remoteLastDate) {
      await _syncFromLocal(localLastDate);
    } else {
      await _syncFromRemote(remoteLastDate);
    }
  }

  Future<void> _syncFromRemote(int? remoteLastDate) async {
    await localDataSource.clearTasks();
    final dataRemote = await remoteDataSource.getAllTasks();
    await localDataSource.upsertTasksToLocal(dataRemote, remoteLastDate);
  }

  Future<void> _syncFromLocal(int localLastDate) async {
    await remoteDataSource.clearAllUserData();
    final dataLocal = await localDataSource.getAllTasks();
    await remoteDataSource.saveCachedTasksToBackend(dataLocal, localLastDate);
  }
}