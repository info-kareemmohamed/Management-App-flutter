import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../presentation/bloc/task_bloc.dart';
import '../data/local/local_data_source.dart';
import '../data/remote/remote_data_source.dart';
import '../data/repository/task_repository_impl.dart';
import '../domain/repository/task_repository.dart';

final GetIt getIt = GetIt.instance;

 void setupLocator() {
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());
  getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());
  getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(
   localDataSource: getIt<LocalDataSource>(),
   remoteDataSource: getIt<RemoteDataSource>(),
  ));
  getIt.registerFactory<TaskBloc>(() => TaskBloc(getIt<TaskRepository>(), InternetConnection()));
}
