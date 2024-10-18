
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import 'data/local/local_data_source.dart';
import 'di/setup_locator.dart';
import 'firebase_options.dart';
abstract class TaskApp{
  static Future<void> initializeApp() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LocalDataSource.initializeHive();
    setupLocator();
  }
}