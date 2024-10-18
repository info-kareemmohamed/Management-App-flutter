import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ropulva_flutter_task/data/local/local_data_source.dart';
import 'package:ropulva_flutter_task/data/remote/remote_data_source.dart';
import 'package:ropulva_flutter_task/data/repository/task_repository_impl.dart';
import 'package:ropulva_flutter_task/domain/model/task_model.dart';



import 'task_repository_impl_test.mocks.dart';

@GenerateMocks([LocalDataSource, RemoteDataSource])
void main() {
  late TaskRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repository = TaskRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });



  group('getTaskById', () {
    const taskId = '1';
    final task = TaskModel(id: taskId, title: 'Test Task',dueDate: DateTime(2024));

    test('should return task from local data source', () async {
      // Given
      when(mockLocalDataSource.getTask(taskId)).thenAnswer((_) async => task);

      // When
      final result = await repository.getTaskById(taskId);

      // Then
      expect(result, equals(task));
      verify(mockLocalDataSource.getTask(taskId)).called(1);
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });


  group('updateTask', () {
    final task = TaskModel(id: '1', title: 'Updated Task',dueDate: DateTime(2024));

    test('should update task in both local and remote data sources', () async {
      // Given
      // No setup needed for this test.

      // When
      await repository.upsertTask(task);

      // Then
      verify(mockLocalDataSource.upsertTask(task, any)).called(1);
      verify(mockRemoteDataSource.upsertTask(task, any)).called(1);
    });
  });



  group('deleteTask', () {
    const taskId = '1';

    test('should delete task from both local and remote data sources', () async {
      // Given
      // No setup needed for this test.

      // When
      await repository.deleteTask(taskId);

      // Then
      verify(mockLocalDataSource.deleteTask(taskId)).called(1);
      verify(mockRemoteDataSource.deleteTask(taskId)).called(1);
    });
  });



  group('refreshTasksOnConnectivity', () {
    final List<TaskModel> remoteTasks = [
      TaskModel(id: '1', title: 'Remote Task 1',dueDate: DateTime(2024)),
      TaskModel(id: '2', title: 'Remote Task 2',dueDate: DateTime(2024)),
    ];
    final List<TaskModel> localTasks = [
      TaskModel(id: '3', title: 'Local Task 1',dueDate: DateTime(2024)),
      TaskModel(id: '4', title: 'Local Task 2',dueDate: DateTime(2024)),
    ];


    test('should sync tasks from remote when local is older', () async {
      // Given
      when(mockLocalDataSource.getLastUpdatedDate()).thenAnswer((_) async => 1);
      when(mockRemoteDataSource.getLastUpdateDate()).thenAnswer((_) async => 2);
      when(mockRemoteDataSource.getAllTasks()).thenAnswer((_) async => remoteTasks);

      // When
      await repository.refreshTasksOnConnectivity();

      // Then
      verify(mockLocalDataSource.clearTasks()).called(1);
      verify(mockLocalDataSource.upsertTasksToLocal(remoteTasks, 2)).called(1);
    });


    test('should sync tasks from local when remote is older', () async {
      // Given
      when(mockLocalDataSource.getLastUpdatedDate()).thenAnswer((_) async => 3);
      when(mockRemoteDataSource.getLastUpdateDate()).thenAnswer((_) async => 2);
      when(mockLocalDataSource.getAllTasks()).thenAnswer((_) async => localTasks);

      // When
      await repository.refreshTasksOnConnectivity();

      // Then
      verify(mockRemoteDataSource.clearAllUserData()).called(1);
      verify(mockRemoteDataSource.saveCachedTasksToBackend(localTasks, 3)).called(1);
    });



    test('should sync tasks from remote when local is null', () async {
      // Given
      when(mockLocalDataSource.getLastUpdatedDate()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.getLastUpdateDate()).thenAnswer((_) async => 2);
      when(mockRemoteDataSource.getAllTasks()).thenAnswer((_) async => remoteTasks);

      // When
      await repository.refreshTasksOnConnectivity();

      // Then
      verify(mockLocalDataSource.clearTasks()).called(1);
      verify(mockLocalDataSource.upsertTasksToLocal(remoteTasks, 2)).called(1);
    });



    test('should sync tasks from local when remote is null', () async {
      // Given
      when(mockLocalDataSource.getLastUpdatedDate()).thenAnswer((_) async => 3);
      when(mockRemoteDataSource.getLastUpdateDate()).thenAnswer((_) async => null);
      when(mockLocalDataSource.getAllTasks()).thenAnswer((_) async => localTasks);

      // When
      await repository.refreshTasksOnConnectivity();

      // Then
      verify(mockRemoteDataSource.clearAllUserData()).called(1);
      verify(mockRemoteDataSource.saveCachedTasksToBackend(localTasks, 3)).called(1);
    });



    test('should do nothing when local date equals remote date', () async {
      // Given
      when(mockLocalDataSource.getLastUpdatedDate()).thenAnswer((_) async => 3);
      when(mockRemoteDataSource.getLastUpdateDate()).thenAnswer((_) async => 3);

      // When
      await repository.refreshTasksOnConnectivity();

      // Then
      verifyNever(mockRemoteDataSource.clearAllUserData());
      verifyNever(mockLocalDataSource.clearTasks());
      verifyNever(mockRemoteDataSource.saveCachedTasksToBackend(any, any));
      verifyNever(mockLocalDataSource.upsertTasksToLocal(any, any));
    });


  });
}
