import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ropulva_flutter_task/TaskApp.dart';
import 'package:ropulva_flutter_task/presentation/task_list/mobile_screen/task_list_screen.dart';
import 'package:ropulva_flutter_task/presentation/task_list/desktop_screen/task_list_screen.dart';


void main() async {
  await TaskApp.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size designSize;
        // Check if the device width is greater than a certain value to determine platform
        if (constraints.maxWidth > 600) {
          // Desktop design size
          designSize = const Size(1440, 1024);
        } else {
          // Mobile design size
          designSize = const Size(375, 812);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Task Management',
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xffFFFFFF),
              ),
              home: Platform.isWindows?const TaskListScreen(): const TaskListScreen(),
            );
          },
        );
      },
    );
  }

}
