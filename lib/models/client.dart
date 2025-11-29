import 'package:flutter_app/utils/common.dart';

class Client {
  final String id;
  final String name;
  final String email; 
  Client(this.id, this.name, {this.email = ''});

  FormArguments toFormArgs() {
    return FormArguments({
      'name': '$name (Копия)', // Добавляем пометку
      'email': '',             // Email очищаем при копировании
    });
  }
}