import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ropulva_flutter_task/TaskApp.dart';
import 'package:ropulva_flutter_task/presentation/task_list/mobile_screen/task_list_screen.dart';


void main() async {
  await TaskApp.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      // Base size for scaling (depends on the design)
      minTextAdapt: true,
      // Adapts text size based on device
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Management',
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const TaskListScreen(),
        );
      },
    );
  }
}
