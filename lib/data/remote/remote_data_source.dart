import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/model/task_model.dart';
import '../../utils/constants.dart';

class RemoteDataSource {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection(Constants.FIREBASE_USERS);

  // Add or update a task and the last updated date
  Future<void> upsertTask(TaskModel task, int? lastDate) async {
    await _upsertTask(task);
    await _upsertLastDate(lastDate);
  }

  Future<void> _upsertTask(TaskModel task) async {
    await userCollection
        .doc(Constants.USER_ID)
        .collection(Constants.FIREBASE_TASK)
        .doc(task.id)
        .set(task.toJson());
  }

  Future<void> deleteTask(String taskId) async{
   await userCollection
        .doc(Constants.USER_ID)
        .collection(Constants.FIREBASE_TASK)
        .doc(taskId)
        .delete();
  }

  Future<void> _upsertLastDate(int? lastDate) async {
    final newLastDate = lastDate ?? DateTime.now().millisecondsSinceEpoch;
    await userCollection
        .doc(Constants.USER_ID)
        .collection(Constants.FIREBASE_LAST_UPDATED_DATE)
        .doc(Constants.LAST_UPDATED_DATE_KEY)
        .set({
      Constants.FIREBASE_LAST_UPDATED_DATE: newLastDate,
    });
  }

  Future<int?> getLastUpdateDate() async {
    return await _getDocumentData(
      Constants.FIREBASE_LAST_UPDATED_DATE,
      Constants.LAST_UPDATED_DATE_KEY,
      Constants.FIREBASE_LAST_UPDATED_DATE,
    );
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    return await _getDocumentData(
      Constants.FIREBASE_TASK,
      taskId,
      null,
    ) as TaskModel?;
  }

  Future<T?> _getDocumentData<T>(
      String collection, String docId, String? key) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await userCollection
          .doc(Constants.USER_ID)
          .collection(collection)
          .doc(docId)
          .get();

      if (doc.exists) {
        return key != null ? doc.data()![key] : TaskModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print("Error getting document: $e");
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final querySnapshot = await userCollection
        .doc(Constants.USER_ID)
        .collection(Constants.FIREBASE_TASK)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveCachedTasksToBackend(List<TaskModel> cachedTasks,int? lastDate) async {
    for (var task in cachedTasks) {
      await upsertTask(task,lastDate);
    }
  }

  Future<void> clearAllUserData() async {
    try {
      await userCollection.doc(Constants.USER_ID).delete();
    } catch (e) {
      print("Error clearing user data: $e");
    }
  }
}

