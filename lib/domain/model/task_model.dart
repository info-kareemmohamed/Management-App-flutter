import 'package:hive/hive.dart';
part "task_model.g.dart" ;

@HiveType(typeId: 0)
class TaskModel{

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime dueDate;
  @HiveField(3)
  late bool isDone;

  TaskModel(  {
    required this.id,
    required this.title,
    required this.dueDate,
    this.isDone = false
  });


  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    bool? isDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
    );
  }


  factory TaskModel.fromJson(Map<String,dynamic> json){
    return TaskModel(
        title: json['title'],
        dueDate: DateTime.tryParse(json['dueDate'])!,
        id: json['id'],
        isDone: json['isDone']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'id': id,
      'isDone': isDone,
      'title':title,
      'dueDate':dueDate.toIso8601String(),
    };
  }

}
