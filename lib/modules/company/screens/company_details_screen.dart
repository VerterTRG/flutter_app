import 'package:flutter/material.dart';
import 'package:flutter_app/models/company.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/custom_data_table.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final String tabId;
  final FormArguments? args;

  const CompanyDetailsScreen({super.key, required this.tabId, this.args});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _innCtrl;
  late TextEditingController _addressCtrl;

  // Nested data for tables
  List<Agreement> _agreements = [];
  List<Agent> _agents = [];
  List<BankAccount> _bankAccounts = [];
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _innCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _loadData();
  }

  void _loadData() {
    if (widget.args != null) {
      final data = widget.args!.data;
      _nameCtrl.text = data['name'] ?? '';
      _innCtrl.text = data['inn'] ?? '';
      _addressCtrl.text = data['address'] ?? '';

      // Load nested lists if available (converting from JSON maps if needed)
      if (data['agreements'] != null) {
        _agreements = (data['agreements'] as List).map((e) => e is Agreement ? e : Agreement.fromJson(e)).toList();
      }
      if (data['agents'] != null) {
        _agents = (data['agents'] as List).map((e) => e is Agent ? e : Agent.fromJson(e)).toList();
      }
      if (data['bank_accounts'] != null) {
        _bankAccounts = (data['bank_accounts'] as List).map((e) => e is BankAccount ? e : BankAccount.fromJson(e)).toList();
      }
      if (data['contacts'] != null) {
        _contacts = (data['contacts'] as List).map((e) => e is Contact ? e : Contact.fromJson(e)).toList();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _innCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка компании'),
        actions: [
          IconButton(
            onPressed: () {
              // Save logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранение...')));
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Fields
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _innCtrl,
                decoration: const InputDecoration(labelText: 'ИНН', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Адрес', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // Agreements Table
              _buildSectionTitle('Договоры'),
              SizedBox(
                height: 200,
                child: CustomDataTable<Agreement>(
                  columns: const ['Номер', 'Дата'],
                  data: _agreements,
                  rowBuilder: (item) => [Text(item.number), Text(item.date)],
                ),
              ),

              const SizedBox(height: 20),

              // Agents Table
              _buildSectionTitle('Представители'),
              SizedBox(
                height: 200,
                child: CustomDataTable<Agent>(
                  columns: const ['Имя', 'Должность', 'Документ'],
                  data: _agents,
                  rowBuilder: (item) => [Text(item.name), Text(item.position), Text(item.authorityDoc)],
                ),
              ),

              const SizedBox(height: 20),

              // Bank Accounts Table
              _buildSectionTitle('Банковские счета'),
              SizedBox(
                height: 200,
                child: CustomDataTable<BankAccount>(
                  columns: const ['Номер', 'Банк', 'БИК'],
                  data: _bankAccounts,
                  rowBuilder: (item) => [Text(item.number), Text(item.bank), Text(item.bik)],
                ),
              ),

              const SizedBox(height: 20),

              // Contacts Table
              _buildSectionTitle('Контакты'),
              SizedBox(
                height: 200,
                child: CustomDataTable<Contact>(
                  columns: const ['Имя', 'Телефон', 'Email'],
                  data: _contacts,
                  rowBuilder: (item) => [
                    Text(item.name),
                    Text(item.phone.join(', ')),
                    Text(item.email.join(', '))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
