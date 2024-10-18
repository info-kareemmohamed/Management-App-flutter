
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import 'data/local/local_data_source.dart';
import 'di/setup_locator.dart';

abstract class TaskApp{
  static Future<void> initializeApp() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await LocalDataSource.initializeHive();
    setupLocator();
  }
}