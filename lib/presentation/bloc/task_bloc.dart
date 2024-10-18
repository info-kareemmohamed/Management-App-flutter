import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../domain/model/task_model.dart';
import '../../domain/repository/task_repository.dart';
import '../widgets/primary_chip.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  final InternetConnection internetConnection;
  TaskFilter _selectedFilter = TaskFilter.all;
  List<TaskModel>? tasks;
  late final StreamSubscription<InternetStatus> _internetSubscription;

  TaskBloc(this.taskRepository, this.internetConnection)
      : super(TaskInitial()) {
    on<GetTasksEvent>(_onGetTasks);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<AddTaskEvent>(_onAddTask);
    on<ChangeIsDoneEvent>(_onChangeIsDone);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ChangeTaskFilterEvent>(_onChangeTaskFilter);

    // Start listening to internet connection changes
    _internetSubscription = internetConnection.onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        add(GetTasksEvent()); // Re-fetch tasks when connected to the internet
      }
    });
  }

  // Dispose the subscription when Bloc is closed
  @override
  Future<void> close() {
    _internetSubscription
        .cancel(); // Cancel the subscription when bloc is closed
    return super.close();
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    await _tryAction(() async {
      final newTask = TaskModel(
          id: ((tasks?.length ?? 0) + 1).toString(),
          title: event.title,
          dueDate: event.dateTime);
      await taskRepository.upsertTask(newTask);
      add(GetTasksEvent()); // Re-fetch tasks after updating
    }, emit, "Failed to add task");
  }

  Future<void> _onChangeIsDone(
      ChangeIsDoneEvent event, Emitter<TaskState> emit) async {
    await _tryAction(() async {
      await taskRepository
          .upsertTask(event.task.copyWith(isDone: !event.task.isDone));
      add(GetTasksEvent()); // Re-fetch tasks after updating
    }, emit, 'Failed to load tasks');
  }

  Future<void> _onChangeTaskFilter(
      ChangeTaskFilterEvent event, Emitter<TaskState> emit) async {
    _selectedFilter = event.filter;
    final filterTasks = _filterTasks(tasks);
    emit(TaskLoaded(filterTasks ?? [], _selectedFilter));
  }

  Future<void> _onGetTasks(GetTasksEvent event, Emitter<TaskState> emit) async {
    await _tryAction(() async {
      await taskRepository.refreshTasksOnConnectivity(); // Fetch latest data
      tasks = await taskRepository.getTasks();
      final filterTasks = _filterTasks(tasks);
      emit(TaskLoaded(filterTasks ?? [], _selectedFilter));
    }, emit, "Failed to load tasks");
  }

  Future<void> _onUpdateTask(
      UpdateTaskEvent event, Emitter<TaskState> emit) async {
    await _tryAction(() async {
      await taskRepository.upsertTask(event.task);
      add(GetTasksEvent()); // Re-fetch tasks after adding
    }, emit, "Failed to add task");
  }

  Future<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<TaskState> emit) async {
    await _tryAction(() async {
      await taskRepository.deleteTask(event.taskId);
      add(GetTasksEvent()); // Re-fetch tasks after deletion
    }, emit, "Failed to delete task");
  }

  Future<void> _tryAction(Future<void> Function() action,
      Emitter<TaskState> emit, String errorMessage) async {
    emit(TaskLoading());
    try {
      await action();
    } catch (e) {
      emit(TaskError(errorMessage));
    }
  }

  List<TaskModel>? _filterTasks(List<TaskModel>? tasks) {
    switch (_selectedFilter) {
      case TaskFilter.done:
        return tasks?.where((task) => task.isDone).toList();
      case TaskFilter.notDone:
        return tasks?.where((task) => !task.isDone).toList();
      default:
        return tasks;
    }
  }
}
