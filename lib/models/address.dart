import 'package:flutter_app/utils/common.dart';

class Address { 
  final String id; 
  final String clientId; 
  final String city; 
  final String? zip;
  Address(this.id, this.clientId, this.city, this.zip);
  
  FormArguments toFormArgs() {
    return FormArguments({
      'clientId': clientId,
      'city': city,
      'zip': zip,
    });
  }
}