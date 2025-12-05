import 'package:flutter/material.dart';
import 'package:flutter_app/logic/company_cubit.dart';
import 'package:flutter_app/models/company.dart';
import 'package:flutter_app/modules/company/module.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_app/widgets/custom_data_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyListScreen extends StatefulWidget {
  final String tabId;
  final FormArguments? args;

  const CompanyListScreen({super.key, required this.tabId, this.args});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  List<Company> _selectedCompanies = [];

  void _onCreate() {
    CompanyModule().forms.create.openForm(context, sourceTabId: widget.tabId);
  }

  void _onCopy() {
    if (_selectedCompanies.length != 1) return;
    CompanyModule().forms.create.openForm(
      context,
      sourceTabId: widget.tabId,
      args: _selectedCompanies.first.toFormArgs(isCopy: true),
    );
  }

  void _onConfigureColumns() {
    // Placeholder for configuring columns
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Настройка колонок (в разработке)')));
  }

  void _onDetails(Company company) {
    CompanyModule().forms.edit.openForm(
      context,
      sourceTabId: widget.tabId,
      args: company.toFormArgs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyCubit(),
      child: Scaffold(
        body: Column(
          children: [
            // Toolbar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: _onCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Создать'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _selectedCompanies.length == 1 ? _onCopy : null,
                    icon: const Icon(Icons.copy),
                    label: const Text('Скопировать'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _onConfigureColumns,
                    icon: const Icon(Icons.settings),
                    label: const Text('Настроить колонки'),
                  ),
                ],
              ),
            ),
            // Table
            Expanded(
              child: BlocBuilder<CompanyCubit, CompanyState>(
                builder: (context, state) {
                  return CustomDataTable<Company>(
                    columns: const ['Название', 'ИНН', 'Адрес'],
                    data: state.companies,
                    selectedItems: _selectedCompanies,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedCompanies = selected;
                      });
                    },
                    onRowDoubleTap: _onDetails,
                    rowBuilder: (company) {
                      return [
                        Text(company.name),
                        Text(company.inn),
                        Text(company.address),
                      ];
                    },
                    onSort: (columnIndex, ascending) {
                      // Handle sorting
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
