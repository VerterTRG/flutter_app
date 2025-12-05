import 'package:equatable/equatable.dart';
import 'package:flutter_app/utils/common.dart';

// --- NESTED MODELS ---

class Agreement extends Equatable {
  final int id;
  final String number;
  final String date;

  const Agreement({
    required this.id,
    required this.number,
    required this.date,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] as int,
      number: json['number'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'date': date,
    };
  }

  @override
  List<Object?> get props => [id, number, date];
}

class Agent extends Equatable {
  final int id;
  final String name;
  final String position;
  final String authorityDoc;
  final String details;

  const Agent({
    required this.id,
    required this.name,
    required this.position,
    required this.authorityDoc,
    required this.details,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      authorityDoc: json['authority_doc'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'authority_doc': authorityDoc,
      'details': details,
    };
  }

  @override
  List<Object?> get props => [id, name, position, authorityDoc, details];
}

class BankAccount extends Equatable {
  final int id;
  final String number;
  final String bank;
  final String bik;
  final String corNumber;

  const BankAccount({
    required this.id,
    required this.number,
    required this.bank,
    required this.bik,
    required this.corNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as int,
      number: json['number'] as String? ?? '',
      bank: json['bank'] as String? ?? '',
      bik: json['bik'] as String? ?? '',
      corNumber: json['cor_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'bank': bank,
      'bik': bik,
      'cor_number': corNumber,
    };
  }

  @override
  List<Object?> get props => [id, number, bank, bik, corNumber];
}

class Contact extends Equatable {
  final int id;
  final String name;
  final List<String> phone;
  final List<String> email;
  final String comment;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.comment,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: (json['phone'] as List?)?.map((e) => e.toString()).toList() ?? [],
      email: (json['email'] as List?)?.map((e) => e.toString()).toList() ?? [],
      comment: json['comment'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => [id, name, phone, email, comment];
}

// --- MAIN MODEL ---

class Company extends Equatable {
  final String id;
  final String companyType; // "Legal" or "Individual"
  final String name;
  final int? mainAgreementId;
  final List<Agreement> agreements;
  final String inn;
  final String kpp;
  final String ogrn;
  final String address;
  final String mailAddress;
  final int? representativeId;
  final List<Agent> agents;
  final int? mainBankAccountId;
  final List<BankAccount> bankAccounts;
  final String comment;
  final List<Contact> contacts;

  const Company({
    required this.id,
    required this.companyType,
    required this.name,
    this.mainAgreementId,
    required this.agreements,
    required this.inn,
    required this.kpp,
    required this.ogrn,
    required this.address,
    required this.mailAddress,
    this.representativeId,
    required this.agents,
    this.mainBankAccountId,
    required this.bankAccounts,
    required this.comment,
    required this.contacts,
  });

  /// Factory for creating a Company from JSON data.
  /// Used for parsing API responses.
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'].toString(),
      companyType: json['company_type'] as String? ?? 'Legal',
      name: json['name'] as String? ?? '',
      mainAgreementId: json['main_agreement'] as int?,
      agreements: (json['agreements'] as List?)
              ?.map((e) => Agreement.fromJson(e))
              .toList() ??
          [],
      inn: json['inn'] as String? ?? '',
      kpp: json['kpp'] as String? ?? '',
      ogrn: json['OGRN'] as String? ?? '',
      address: json['address'] as String? ?? '',
      mailAddress: json['mail_address'] as String? ?? '',
      representativeId: json['representative'] as int?,
      agents: (json['agents'] as List?)
              ?.map((e) => Agent.fromJson(e))
              .toList() ??
          [],
      mainBankAccountId: json['main_bank_account'] as int?,
      bankAccounts: (json['bank_accounts'] as List?)
              ?.map((e) => BankAccount.fromJson(e))
              .toList() ??
          [],
      comment: json['comment'] as String? ?? '',
      contacts: (json['contacts'] as List?)
              ?.map((e) => Contact.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Converts the Company object back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_type': companyType,
      'name': name,
      'main_agreement': mainAgreementId,
      'agreements': agreements.map((e) => e.toJson()).toList(),
      'inn': inn,
      'kpp': kpp,
      'OGRN': ogrn,
      'address': address,
      'mail_address': mailAddress,
      'representative': representativeId,
      'agents': agents.map((e) => e.toJson()).toList(),
      'main_bank_account': mainBankAccountId,
      'bank_accounts': bankAccounts.map((e) => e.toJson()).toList(),
      'comment': comment,
      'contacts': contacts.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper to convert company data to FormArguments for editing or copying.
  FormArguments toFormArgs({bool isCopy = false}) {
    // If copying, we might want to modify the name or clear IDs
    final map = toJson();
    if (isCopy) {
      map['id'] = ''; // New ID will be generated
      map['name'] = '${map['name']} (Копия)';
    }
    return FormArguments(map);
  }

  @override
  List<Object?> get props => [
        id,
        companyType,
        name,
        mainAgreementId,
        agreements,
        inn,
        kpp,
        ogrn,
        address,
        mailAddress,
        representativeId,
        agents,
        mainBankAccountId,
        bankAccounts,
        comment,
        contacts,
      ];
}
